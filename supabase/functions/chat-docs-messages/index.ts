// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import 'https://deno.land/x/xhr@0.2.1/mod.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.5.0'
import GPT3Tokenizer from 'https://esm.sh/gpt3-tokenizer@1.1.5'
import { Configuration, OpenAIApi } from "https://esm.sh/openai@3.2.1"
//import { stripIndent } from 'https://esm.sh/common-tags@1.8.2'
import { stripIndent, oneLine } from 'https://esm.sh/common-tags@1.8.2'

// Define an interface for the message object
interface Message {
  role: string;
  content: string;
}

// Update the formatMessages function with the Message type
function formatMessages(messages: Message[]): string {
  return messages.map((message: Message) => {
    const { role, content } = message;
    return `${role}: ${content}`;
  }).join(' ');
}

// Add a function to generate the prompt
function generatePrompt(contextText: string, input: string, summary: string): string {
  return stripIndent`${oneLine`
    `}
    Summary of previous conversation:
    "${summary}"

    Context sections:
    ${contextText}

    Question: """
    ${input}
    """
  `;
}

// Add a function to trim the contextText
function trimContextToFit(tokenizer: GPT3Tokenizer, contextText: string, prompt: string, maxLength: number, input: string, summary: string): string {
  while (true) {
    const encoded = tokenizer.encode(prompt);
    if (encoded.text.length <= maxLength) {
      break;
    }
    contextText = contextText.slice(0, -1); // Remove the last character from contextText
    prompt = generatePrompt(contextText, input, summary);
  }
  return contextText;
}


// Add a function to trim the chat history
function trimChatHistoryToFit(tokenizer: GPT3Tokenizer, chatHistory: string, maxLength: number): string {
  while (true) {
    const encoded = tokenizer.encode(chatHistory);
    if (encoded.text.length <= maxLength) {
      break;
    }
    chatHistory = chatHistory.slice(1); // Remove the first character from chatHistory
  }
  return chatHistory;
}


export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const configuration = new Configuration({
  organization: Deno.env.get("OPENAI_ORG_ID"),
  apiKey: Deno.env.get("OPENAI_API_KEY"),
});
const modelName: string = Deno.env.get("OPENAI_API_MODEL") as string || "gpt-3.5-turbo";
const matchLimit = 10;
const tokenSafety = 50;
const maxModelTokens = modelName === "gpt-4" ? 8190 : modelName === "gpt-3.5-turbo" ? 4090 : 4090;


// Supabase API ANON KEY - env var exported by default when deployed.
const anonKey = Deno.env.get('BASE_ANON_KEY') ?? '';
if (!anonKey) throw new Error(`Expected env var SUPABASE_ANON_KEY`);

// Supabase API URL - env var exported by default when deployed.    
const url = Deno.env.get('BASE_URL') ?? '';
if (!url) throw new Error(`Expected env var SUPABASE_URL`);

const serviceKey = Deno.env.get('BASE_ROLE_KEY') ?? '';
if (!serviceKey) throw new Error(`Expected env var SUPABASE_SERVICE_ROLE_KEY`);

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }
  try {
    // Search documentId and user prompt is passed in request payload
    const { messages, documentId, query, organizeDocs } = await req.json();
    console.log(messages);
    console.log(documentId + query);
    console.log(organizeDocs);
    const serviceClient = createClient(
      url,
      serviceKey
    );

    // OpenAI recommends replacing newlines with spaces for best results
    var originalInput = query.replace(/\n/g, ' ')
    const openai = new OpenAIApi(configuration)
    const tokenizer = new GPT3Tokenizer({ type: 'gpt3' })

    let chat_history = '';
    let trimmedChatHistory = '';
    if (messages) {
      chat_history = formatMessages(messages);
      console.log(chat_history);
      // Trim chat_history if its encoded length is greater than 3500 tokens
      trimmedChatHistory = trimChatHistoryToFit(tokenizer, chat_history, 3500);
    }

    // Summarize the historiy of the conversation before creating the standalone question.
    //Given the following conversation and a follow up input,
    //rephrase the follow up input to be a standalone question.
    const standaloneQuestion = stripIndent`${oneLine`
  Given the following conversation and a follow up question, rephrase the follow up question to be a standalone question.`}
  
  Chat History:
  -
  ${trimmedChatHistory}
  -
  Follow Up Input: ${originalInput}
  Standalone question:
  `
    console.log(standaloneQuestion);

    const historyPrompt = stripIndent`${oneLine`
  Given the following conversation history provide a short summary of the conversation to be used for future context.`}
  Chat History:
  -
  ${trimmedChatHistory}
  -
  Summary:
  \n
  `

    const systemMessage = "You are a helpful assistant that can rephrase questions and summarize chat history.";
    const encodedSystemPrompt = tokenizer.encode(systemMessage);
    const systemMessageLength = encodedSystemPrompt.text.length;


    // Calculate max_tokens for standaloneQuestionResponse
    const encodedStandaloneQuestion = tokenizer.encode(standaloneQuestion);
    const standaloneLength = encodedStandaloneQuestion.text.length;
    const maxStandaloneTokens = maxModelTokens - standaloneLength - systemMessageLength - tokenSafety;

    // Calculate max_tokens for summaryResponse
    const encodedHistoryPrompt = tokenizer.encode(historyPrompt);
    const historyLength = encodedHistoryPrompt.text.length;
    const maxHistoryTokens = maxModelTokens - historyLength - systemMessageLength - tokenSafety;



    let standaloneQuestionCompletion;
    let summaryCompletion;
    try {
      standaloneQuestionCompletion = await openai.createChatCompletion({
        model: modelName,
        messages: [
          { role: "system", content: systemMessage },
          { role: "user", content: standaloneQuestion },
        ],
        max_tokens: maxStandaloneTokens, // Choose the max allowed tokens in completion
        temperature: 0.1, // Set to 0 for deterministic results
      });
      //await new Promise((resolve) => setTimeout(resolve, 100));
      summaryCompletion = await openai.createChatCompletion({
        model: modelName,
        messages: [
          { role: "system", content: systemMessage },
          { role: "user", content: historyPrompt },
        ],
        max_tokens: maxHistoryTokens, // Choose the max allowed tokens in completion
        temperature: 0.1, // Set to 0 for deterministic results
      });

    } catch (error) {
      console.log(error);
      throw new Error(error.message);
    }

    const text = (standaloneQuestionCompletion.data.choices?.[0]?.message?.content ?? "").trim();
    console.log("text");
    console.log(text);
    const summary = (summaryCompletion.data.choices?.[0]?.message?.content ?? "").trim();
    //const summary = "";
    console.log("summary");
    console.log(summary);

    // Rename the variable to avoid conflict
    const rephrasedInput = text.replace(/\n/g, ' ');
    const summaryInput = summary.replace(/\n/g, ' ');
    // Generate a one-time embedding for the query itself
    const embeddingResponse = await openai.createEmbedding({
      model: 'text-embedding-ada-002',
      input: rephrasedInput, // Use the rephrasedInput variable here
    })

    const [{ embedding }] = embeddingResponse.data.data
    /*   console.log(`Embedding length: ${embedding.length}`);
      console.log(`Embedding content: ${embedding}`); */

    const { data: documents, error: errorMatch } = await serviceClient.rpc('match_chunks_with_doc_id ', {
      query_embedding: embedding,
      match_count: matchLimit, // Choose the number of matches
      target_document_id: documentId
    });
    if (errorMatch) {
      console.error(errorMatch);
      throw new Error(errorMatch.message);
    }
    //console.log(documents);

    let tokenCount = 0
    let contextText = ''

    // Concat matched documents
    for (let i = 0; i < documents.length; i++) {
      const document = documents[i]
      const content = document.content
      const encoded = tokenizer.encode(content)
      tokenCount += encoded.text.length

      // Set max tokens based on the model
      const maxTokens = modelName === 'gpt-3.5-turbo' ? 2000 : modelName === 'gpt-4' ? 5500 : 2000;
      //contextText += `${content.trim()}\n---\n`
      contextText += `${content.trim()} `
      // Limit context to max tokens
      if (tokenCount > maxTokens) {
        console.log(`Breaking at document ${i}`);
        break;
      }
    }
    console.log(`Context length: ${tokenCount}`);
    //console.log(contextText);

    // Use the new functions to generate the prompt and trim the contextText if necessary
    var prompt = generatePrompt(contextText, rephrasedInput, summaryInput);
    //console.log("First version of prompt");
    //console.log(prompt);
    contextText = trimContextToFit(tokenizer, contextText, prompt, 2000, rephrasedInput, summaryInput);
    //console.log("Second version of prompt");
    //console.log(prompt);

    const encodedContext = tokenizer.encode(contextText)
    console.log(`Context length after trim: ${encodedContext.text.length}`);

    if (organizeDocs) {
      // Organize the documents by relevance
      // Create a new messages array for reorganization
      const organizationMessage = "You are a helpful assistant that can perfectly reorganize text logically while keeping the same meaning and facts.";
      const encodedOrganizationMessage = tokenizer.encode(organizationMessage);
      const organizationMessageLength = encodedOrganizationMessage.text.length;
      // Calculate max_tokens for completion
      const encodedContext = tokenizer.encode(contextText);
      const contextLength = encodedContext.text.length;
      const maxContextCompletionTokens = maxModelTokens - contextLength - organizationMessageLength - tokenSafety;

      const messagesForReorganization = [
        { role: "system", content: organizationMessage },
        { role: "user", content: `Reorganize the following text: ${contextText}` },
      ];

      let reorganizationCompletion;
      try {
        //await new Promise((resolve) => setTimeout(resolve, 100));
        reorganizationCompletion = await openai.createChatCompletion({
          model: modelName,
          messages: [
            { role: "system", content: organizationMessage },
            { role: "user", content: `Only reorganize the following text do not tell me how you did it: ${contextText}` },
          ],
          max_tokens: maxContextCompletionTokens,
          temperature: 0, // Set to 0 for deterministic results
        });

      } catch (error) {
        console.log(error);
        throw new Error(error.message);
      }

      const reorganizedText = (reorganizationCompletion.data.choices?.[0]?.message?.content ?? "").trim();
      console.log("reorganizedText");
      console.log(reorganizedText);
      contextText = reorganizedText;


      prompt = generatePrompt(contextText, rephrasedInput, summaryInput);
      console.log("Prompt gen again after reorganization");
      console.log(prompt);
      contextText = trimContextToFit(tokenizer, contextText, prompt, 2000, rephrasedInput, summaryInput);
    }

    //const systemSettingMessage = "You are an AI assistant providing helpful advice. You can also search through documents and answer questions based on the provided context.";
    const systemSettingMessage = stripIndent`${oneLine`
    As an AI assistant, provide concise advice based on given context or answer questions.
    Engage in a chat with the user, and if the context doesn't contain the answer or is unrelated, acknowledge it and respond anyway.
    `}
  `
    // Calculate tokens for systemSettingMessage
    const encodedPromptSystem = tokenizer.encode(systemSettingMessage);
    const encodedPromptSystemLength = encodedPromptSystem.text.length;
    // Calculate max_tokens for completion
    const encodedPrompt = tokenizer.encode(prompt);
    const promptLength = encodedPrompt.text.length;
    const maxCompletionTokens = maxModelTokens - promptLength - encodedPromptSystemLength - tokenSafety;


    const encoded = tokenizer.encode(prompt);
    console.log(`Prompt length: ${encoded.text.length}`);
    console.log(prompt);
    try {

      //await new Promise((resolve) => setTimeout(resolve, 100));
      const completionResponse = await openai.createChatCompletion({
        model: modelName,
        messages: [
          { role: "system", content: systemSettingMessage },
          { role: "user", content: prompt },
        ],
        max_tokens: maxCompletionTokens,
        temperature: 0.1, // Set to 0 for deterministic results
      });

      const assistantContent = completionResponse.data.choices[0]?.message?.content;

      if (assistantContent === undefined) {
        throw new Error("Text is undefined in the completion response.");
      }

      // Remove leading newline characters
      const cleanedText = assistantContent.trim().replace(/^\n+/, '');

      return new Response(JSON.stringify({ completion: cleanedText }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    } catch (error) {
      console.error(error);
      throw new Error(error.message);
    }

  } catch (error) {
    console.error(error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})

// To invoke:
// curl -i --location --request POST 'http://localhost:54321/functions/v1/' \
//   --header 'Authorization: Bearer exxx' \
//   --header 'Content-Type: application/json' \
//   --data '{"name":"Functions"}'
