# chat-docs-messages

This Deno function operates as an AI assistant, utilizing OpenAI's language model to provide concise advice or answer questions based on a given context. The function is specifically designed to interact with the Supabase database and handle document matching based on a user's query. 

The function uses OpenAI to rephrase a user's question into a standalone question, summarizes the chat history, and then generates an embedding for the rephrased query. It then matches the query with documents in a Supabase database and generates a context from the matched documents. The function organizes the documents by relevance if requested, and finally, generates a response from the AI model based on the assembled context.

The function also includes CORS handling capabilities and error checking to ensure a smooth execution process.

## Requirements

Make sure to have the following environment variables set:

- `OPENAI_API_KEY`: The OpenAI API key.
- `OPENAI_API_MODEL`: The OpenAI model to be used (e.g., 'gpt-3.5-turbo', 'gpt-4').
- `BASE_ANON_KEY`: The Supabase API anonymous key.
- `BASE_URL`: The Supabase API URL.
- `BASE_ROLE_KEY`: The Supabase service role key.

## Usage

This function is designed to be used as a serverless function with Deno deployment. It listens for incoming HTTP requests, which should include a JSON payload with `messages`, `documentId`, `query`, and `organizeDocs` fields.

- `messages` is an array of messages with `role` and `content` fields.
- `documentId` is the target document ID to match the query with.
- `query` is the user's question.
- `organizeDocs` is a boolean indicating whether the documents should be organized by relevance.

The function will respond with a JSON object containing the AI-generated response.

```javascript
{
  "completion": "AI generated response"
}
```

## Function Structure

The function is organized into the following sections:

- **Imports**: Importing necessary libraries and modules.
- **Interface and Helper Functions**: Definition of the `Message` interface and various helper functions.
- **CORS and Configurations**: Setting up CORS headers and OpenAI configurations.
- **Supabase Client Initialization**: Initialization of the Supabase client using environment variables.
- **HTTP Server**: The main function that listens to HTTP requests, processes them, and responds with an AI-generated completion.

## Function Details

Here is a brief description of some key elements of the function:

- **Message Formatting**: The function formats the messages and generates a standalone question and summary of the conversation.
- **Text Processing**: The function trims the chat history and context text to fit the model's token limit.
- **OpenAI Interactions**: The function interacts with OpenAI to rephrase questions, summarize the conversation, generate embeddings, and create chat completions.
- **Document Matching**: The function matches the query with documents in the Supabase database and organizes the documents by relevance if requested.
- **Response Generation**: The function generates a response from the AI model based on the assembled context and returns it in the HTTP response.

## Error Handling

The function includes error checking for missing environment variables and unsuccessful interactions with the OpenAI API or Supabase database. If an error occurs, the function will respond with a JSON object containing the error message.