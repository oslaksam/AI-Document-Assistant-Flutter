# openai-chat-api

The following Edge function acts as an information and document assistant, making use of OpenAI's language model, either `gpt-3.5-turbo` or `gpt-4`.

## Overview

The function takes in a series of messages, truncates them to fit within the token limit of the OpenAI model, and then generates a response using OpenAI's chat completion. The generated response is then returned in the HTTP response.

## Dependencies

- **OpenAI**: Used to interact with OpenAI's API and generate responses.

- **GPT3Tokenizer**: Used to count the number of tokens in a text string.

- **Deno's standard library**: Used for serving the function over HTTP.

- **xhr**: Used for making HTTP requests.

## Environment Variables

- `OPENAI_API_KEY`: The API key for OpenAI. Used to call the OpenAI API.

- `OPENAI_API_MODEL`: The name of the model to use for the OpenAI API. Defaults to `gpt-3.5-turbo`.

## Functions

- `getModelMaxTokens(modelId: string)`: Gets the maximum number of tokens allowed for the given model. If the model name is `gpt-4`, the maximum is 8190 tokens; otherwise, it's 4096 tokens.

- `countTokens(text: string)`: Counts the number of tokens in the provided text.

- `truncateMessagesToFitTokens(messages: any[], maxTokens: number, tokenBuffer: number)`: Truncates the list of messages so that the total number of tokens fits within `maxTokens` minus `tokenBuffer`.

## How It Works

When an HTTP request is received, the function:

1. Parses the request body to extract the `messages`.

2. Determines the maximum number of tokens for the model defined in the environment variable.

3. Truncates the list of messages so that their total token count, plus a buffer for the completion, fits within the model's maximum tokens.

4. Creates a chat completion with OpenAI's API, using the model defined in the environment variable and the truncated list of messages. The completion is limited to the token buffer and has a temperature of 0.1 for deterministic results.

5. Returns the completion in the HTTP response.

## Error Handling

If an error occurs while getting the model details or generating the completion, the function logs the error message and returns an HTTP response with a status code of 500 and the error message in the response body.

## Usage

To use this function, send a POST request to the endpoint hosting it. The request body should be a JSON object with a `messages` property that is an array of objects. Each object should have a `role` and `content` property. 

A successful response will be a JSON object with a `completion` property, which is the assistant's response to the messages.

## Limitations

The function's performance and accuracy depend on the OpenAI API and the specific model used. The function is designed for the `gpt-3.5-turbo` and `gpt-4` models and may not work as expected with other models. The function also has a token limit for each model, with the limit being 4090 for `gpt-3.5-turbo` and 8190 for `gpt-4`. Additionally, a buffer of tokens is reserved for the completion, with the buffer being 1500 tokens for `gpt-3.5-turbo` and 3000 tokens for `gpt-4`. If the number of tokens in the messages exceeds the model's token limit minus the buffer, the messages will be truncated to fit.