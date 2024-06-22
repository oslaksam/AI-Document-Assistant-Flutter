# Options Page Documentation

The `OptionsPage` is a Flutter Dart widget that serves as an interface for users to select how they want to process a given text, which is typically scanned from a document. This page provides several functionalities:

## Option Selection
The page first presents users with two main options:

1. **Simple request**
2. **Chat with your docs**

### Simple Request
If 'Simple request' is selected, a dropdown menu is displayed with various actions that can be applied to the scanned text. Available actions are:

- Summarise
- Answer questions
- Free prompt
- Clarify
- Exemplify
- Expand
- Explain
- Rewrite
- Shorten

For the 'Free prompt' option, additional fields and dropdown menus appear for users to specify the tone, writing style, and output language of the response.

### Chat With Your Docs
If 'Chat with your docs' is selected, the user is directly navigated to the `ChatDocsWindow` with the scanned text as the prompt.

## Text Field and Dropdown Inputs
When the 'Free prompt' option is chosen under 'Simple request', the user can input their own prompt, and select a tone, writing style, and output language. There are preset tones, writing styles, and languages provided in the dropdown menus for user selection.

## Navigation
Once users have made their selections and pressed 'Send', they are navigated to a chat window. The code is set up to navigate to either a `ChatWindow` or `ChatDocsWindow`, depending on the selected option.

## State Management
`OptionsPage` is a StatefulWidget, which means it has mutable state that can change over time. The `setState` function is used to update the state of the widget and re-render it when the user interacts with it.

## Building the Chat Prompt
The `_buildPrompt` function is used to construct the chat prompt based on the user's selections from the UI. This function is called before navigating to the chat window to provide the chat window with the appropriate text.