import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
//import { supabaseClient } from "../_shared/supabaseClient.ts";
//import { supabaseClient } from "@supabase/supabase-js";
import { corsHeaders } from "../_shared/cors.ts";
//import { SupabaseVectorStore } from "https://esm.sh/langchain/vectorstores";
import { SupabaseVectorStore } from "https://esm.sh/langchain@0.0.66/vectorstores/supabase";
import { OpenAIEmbeddings } from "https://esm.sh/langchain@0.0.66/embeddings/openai";
//import { RecursiveCharacterTextSplitter } from "https://esm.sh/langchain/dist";
import { RecursiveCharacterTextSplitter } from "https://esm.sh/langchain@0.0.66/text_splitter";
//import { OpenAIEmbeddings } from "https://esm.sh/langchain/embeddings";
//import { TextLoader } from "https://esm.sh/langchain@0.0.66/document_loaders/fs/text";

import { createClient } from 'https://esm.sh/@supabase/supabase-js'

// Supabase API ANON KEY - env var exported by default when deployed.
const anonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
if (!anonKey) throw new Error(`Expected env var SUPABASE_ANON_KEY`);

// Supabase API URL - env var exported by default when deployed.    
const url = Deno.env.get('SUPABASE_URL') ?? '';
if (!url) throw new Error(`Expected env var SUPABASE_URL`);

const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
if (!serviceKey) throw new Error(`Expected env var SUPABASE_SERVICE_ROLE_KEY`);


console.log("Hello from chunking!");
const tempFilePath = "./temp.txt";

serve(async (req) => {
  // This is needed if you're planning to invoke your function from a browser.
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  const { textRequest } = await req.json();
  console.log(textRequest);
  // Create a Supabase client with the Auth context of the logged in user.
  const supabaseClient = createClient(
    // Supabase API URL - env var exported by default.
    url,
    // Supabase API ANON KEY - env var exported by default.
    anonKey,
    // Create client with Auth context of the user that called the function.
    // This way your row-level-security (RLS) policies are applied.
    { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
  );
  const serviceClient = createClient(
    url,
    serviceKey
  );

  var newDocumentId = -1;
  try {

    const date = new Date();
    const user = await supabaseClient.auth.getUser();
    if (user.data) {
      await supabaseClient.from('documents').insert({ user_id: user.data.user?.id, metadata: `{\"name\":\"${date}\"}` });
    }
    else {
      throw new Error("User not found");
    }
    //await serviceClient.from('documents').insert({ user_id: "8378106d-373d-4dce-80f2-518141a460b0", metadata: '{\"name\":\"test\"}' });
    const { data, error } = await serviceClient.from("documents").select("*");
    console.log({ data, error });

    await serviceClient
      .from('documents')
      .select('id')
      .order('id', { ascending: false })
      .limit(1)
      .then(({ data, error }) => {
        if (error) {
          console.log("error", error);
          throw new Error("Failed to get id of the document");
        }
        else if (data) {
          const latestId = data[0].id;
          newDocumentId = latestId;
          console.log('Latest document ID:', latestId);
        }
      });

    //const { dataClient, errorClient } = 
    //await supabaseClient.from("documents").select("*");
    //console.log({ dataClient, errorClient });

    try {
      // Create temporary file
      //await Deno.writeTextFile(tempFilePath, textRequest);

      // Split text into chunks
      const textSplitter = new RecursiveCharacterTextSplitter({
        chunkSize: 2000,
        chunkOverlap: 0,
      });

      // Load temporary file instead of hard-coded file
      //const loader = new TextLoader(tempFilePath);
      //const rawDocs = await loader.load();
      //const docs = await textSplitter.splitDocuments(rawDocs);
      const docs = await textSplitter.createDocuments([textRequest]);
      console.log("created docs", docs);

      //embed the PDF documents
      // Create a vector store from the documents.
      const vectorStore = await SupabaseVectorStore.fromDocuments(docs,
        new OpenAIEmbeddings(),
        {
          client: supabaseClient,
          tableName: "chunks",
          queryName: "match_chunks",
        }
      );
      console.log("created vector store");
      console.log("Id value", newDocumentId);

      await serviceClient
        .from('chunks')
        .update({ document_id: newDocumentId })
        .is('document_id', null)
        .then(({ data, error }) => {
          if (error) {
            console.log("error", error);
            throw new Error("Failed to update your data");
          }
          console.log('Updated rows');
        });

    } catch (error) {
      console.log("error", error);
      throw new Error("Failed to ingest your data");
    }
    // Delete temporary file
    //await Deno.remove(tempFilePath);
    return new Response(JSON.stringify({ newDocumentId, error }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    // Delete temporary file
    //await Deno.remove(tempFilePath);
    // Delete the document with the specified ID value
    const { data: deleteData, error: deleteError } = await serviceClient
      .from('documents')
      .delete()
      .eq('id', newDocumentId);
    if (deleteError) {
      console.log("error", deleteError);
    } else if (deleteData) {
      console.log('Document deleted successfully');
    }

    await serviceClient
      .from('chunks')
      .delete()
      .is('document_id', null)
      .then(({ data: deleteDataChunk, error: deleteChunkError }) => {
        if (deleteError) {
          console.log("error", deleteChunkError);
          throw new Error("Failed to delete your chunks where document_id is null");
        }
        if (deleteDataChunk) {
          console.log('Deleted rows');
        } else {
          console.error("Data is null after deleting chunks.");
        }
      });
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});
