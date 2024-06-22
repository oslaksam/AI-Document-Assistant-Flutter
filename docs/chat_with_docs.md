# ChatDocsWindow

The `ChatDocsWindow` class is a specialized version of the `ChatPage` class, designed for generating responses related to specific documents.

## Constructor

`ChatDocsWindow` accepts additional parameters compared to `ChatPage`, including:

- `builtPrompt`: This argument is used to initialize the chat with a certain document-associated prompt.
- `documentId`: This argument represents the ID of the document in question.

```dart
const ChatDocsWindow(
      {Key? key,
      required this.builtPrompt,
      required this.keyToLoad,
      this.documentId = -1})
      : super(key: key);
```

## Initial State

In the `initState` method, the chat history is loaded conditionally based on `builtPrompt`. Also, `documentId` is initialized based on the constructor argument or by calling the `_initializeDocumentId` method.

## Chunking Text

The `chunkIt` method is used to break down large texts into manageable chunks. This method calls a Supabase function named 'chunk-text'.

```dart
Future<String> chunkIt(String prompt) async {...}
```

## Chat Response

The `_getSupabaseChatResponse` method takes three parameters and invokes a different Supabase function ('chat-docs-messages') with a different set of data.

This function generates the assistant's response, taking into account the document and its details.

```dart
Future<String> _getSupabaseChatResponse(
      String prompt, int documentId, bool organizeDocs) async {...}
```

## Text Field Hint

The text field hint is specifically asking for questions regarding scanned documents, suggesting this page is intended for document-specific inquiries.

```dart
decoration: const InputDecoration(
    hintText: 'Ask a question regarding your scanned documents')
```

## Home Button

This page has a home button (a leading icon in the AppBar), which navigates back to a `MyOcrApp` page.

```dart
IconButton(
    icon: const Icon(Icons.home),
    onPressed: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyOcrApp()),
            (Route<dynamic> route) => false,
        );
    },
),
```

## Conclusion

While `chat_page.dart` handles a general chat functionality, `chat_docs_page.dart` is tailored for generating responses related to specific documents, which makes it suitable for a document management or OCR application.