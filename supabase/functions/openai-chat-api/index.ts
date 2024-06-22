import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { Configuration, OpenAIApi } from "https://esm.sh/openai@3.2.1";
import "https://deno.land/x/xhr@0.3.0/mod.ts";
import GPT3Tokenizer from "https://esm.sh/gpt3-tokenizer@1.1.5";

console.log("Hello from OpenAI!");

const configuration = new Configuration({
  organization: Deno.env.get("OPENAI_ORG_ID"),
  apiKey: Deno.env.get("OPENAI_API_KEY"),
});

const modelName: string =
  (Deno.env.get("OPENAI_API_MODEL") as string) || "gpt-3.5-turbo";

const openai = new OpenAIApi(configuration);

const tokenizer = new GPT3Tokenizer({ type: "gpt3" });

const getModelMaxTokens = async (modelId: string) => {
  try {
    const maxModelTokens = modelName === "gpt-4" ? 8190 : modelName === "gpt-3.5-turbo" ? 4096 : 4096;
    return maxModelTokens;
    //const model = await openai.getModel({ model: modelId });
    //return model.data.max_tokens;
  } catch (error) {
    console.log(`Error getting model details: ${error.message}`);
    return 4096; // Fallback value if unable to get model details
  }
};

const countTokens = (text: string) => {
  const encodedText = tokenizer.encode(text);
  return encodedText.text.length;
};


const truncateMessagesToFitTokens = (
  messages: any[],
  maxTokens: number,
  tokenBuffer: number
) => {
  let messageTokens = messages.reduce(
    (acc, message) => acc + countTokens(message.content),
    0
  );

  let index = 0;
  while (messageTokens + tokenBuffer > maxTokens && index < messages.length) {
    const removedTokens = countTokens(messages[index].content);
    messageTokens -= removedTokens;
    messages.shift();
    index++;
  }

  return messages;
};

serve(async (req) => {
  const { messages } = await req.json();

  const maxTokens = await getModelMaxTokens(modelName);
  // Reserve some tokens for the completion
  const tokenBuffer = modelName === "gpt-4" ? 3000 : modelName === "gpt-3.5-turbo" ? 1500 : 1500;

  const truncatedMessages = truncateMessagesToFitTokens(
    messages,
    maxTokens,
    tokenBuffer
  );
  console.log(`Truncated messages: ${JSON.stringify(truncatedMessages)}`);
  try {
    const completion = await openai.createChatCompletion({
      model: modelName,
      messages: [
        {
          role: "system",
          content:
            "You are a helpful information and document assistant you can also do other tasks.",
        },
        ...truncatedMessages,
      ],
      max_tokens: tokenBuffer, // Choose the max allowed tokens in completion
      temperature: 0.1, // Set to 0 for deterministic results
    });
    console.log(JSON.stringify({
      completion: completion.data.choices[0].message,
    }));
    return new Response(
      JSON.stringify({
        completion: completion.data.choices[0].message,
      }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.log(`Error generating completion: ${error.message}`);
    return new Response(
      JSON.stringify({
        error: error.message
      }),
      {
        headers: { "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});