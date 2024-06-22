# chunk-text

This is a Deno-based edge function for Supabase that handles text chunking and embedding. It uses the Langchain library for text splitting and embedding, and Supabase for data storage and retrieval.

## Dependencies

- Deno Standard Library
- Supabase JavaScript Client
- Langchain Library

## Environment Variables

The function requires the following environment variables:

- `SUPABASE_ANON_KEY`: The anonymous key for your Supabase project.
- `SUPABASE_URL`: The URL of your Supabase project.
- `SUPABASE_SERVICE_ROLE_KEY`: The service role key for your Supabase project.

## Functionality

The function is designed to be invoked with an HTTP request containing a JSON payload with a `textRequest` property. This text is then split into chunks and embedded using the Langchain library. The resulting chunks are stored in a Supabase table.

The function performs the following steps:

1. Receives an HTTP request and extracts the `textRequest` from the JSON payload.
2. Creates a Supabase client with the authentication context of the logged-in user.
3. Inserts a new document record in the `documents` table in Supabase.
4. Retrieves the ID of the newly inserted document.
5. Splits the `textRequest` into chunks using the Langchain `RecursiveCharacterTextSplitter`.
6. Creates a vector store from the chunks using the Langchain `SupabaseVectorStore`.
7. Updates the `chunks` table in Supabase with the document ID.
8. Returns a response with the document ID.

## Error Handling

The function has extensive error handling:

- If any of the required environment variables are not set, the function throws an error.
- If the Supabase client cannot be created, the function throws an error.
- If the document cannot be inserted into the `documents` table, the function throws an error.
- If the text cannot be split into chunks, the function throws an error.
- If the vector store cannot be created, the function throws an error.
- If the `chunks` table cannot be updated, the function throws an error.

In the event of an error, the function attempts to clean up by deleting the temporary file and the document record in the `documents` table.

## CORS

The function includes CORS headers in its responses, and handles OPTIONS requests, making it suitable for invocation from a web browser.

## Usage

To use this function, send an HTTP request with a JSON payload containing a `textRequest` property to the function's URL. The function will return a JSON response containing the ID of the new document record.