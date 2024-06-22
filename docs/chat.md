# ChatWindow Page Documentation

The `ChatWindow` page in Flutter Dart serves as a chat interface between the user and the assistant. This page presents several core functionalities:

## Message Class

The `Message` class is a simple data structure that models a message within the chat system. It includes two properties:

- `role`: This indicates the sender of the message. Typically, the `role` can be either `user` (indicating the message is from the user) or `assistant` (indicating the message is from the AI assistant).
- `content`: This stores the actual text of the message.

```dart
class Message {
  final String role;
  final String content;

  Message({required this.role, required this.content});
}
```

## Serialization and Deserialization

The `Message` class also includes methods for converting to and from a `Map<String, dynamic>` representation, which is useful when storing or retrieving messages from a database or an API.

- `toJson`: This method converts the `Message` instance into a `Map<String, dynamic>`.

```dart
Map<String, dynamic> toJson() => {'role': role, 'content': content};
```

- `fromJson`: This factory constructor creates a new `Message` instance from a `Map<String, dynamic>`.

```dart
factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
    );
  }
```

In practice, these methods allow easy conversion between `Message` objects and JSON-formatted data, which is a common format for transmitting data in many applications.

## ChatWindow Class Definition

`ChatWindow` is a `StatefulWidget` that requires two parameters: `builtPrompt` and `keyToLoad`.

- `builtPrompt`: This is the text that the user will send as the first message.
- `keyToLoad`: This key is used to load a previously saved chat history.

```dart
class ChatWindow extends StatefulWidget {
  final String builtPrompt;
  final String keyToLoad;

  const ChatWindow(
      {Key? key, required this.builtPrompt, required this.keyToLoad})
      : super(key: key);

  @override
  _ChatWindowState createState() => _ChatWindowState();
}
```

## State Initialization

The state of the `ChatWindow` is initialized in the `initState` function. This function checks if the `builtPrompt` is empty. If it's empty, it loads the chat history using the `keyToLoad`. The `builtPrompt` is then set as the initial text in the text controller and the `_handleSendMessage` function is called to send this message.

```dart
void initState() {
  super.initState();
  if (widget.builtPrompt == "") {
    _loadChatHistory(widget.keyToLoad);
  }
  requestText = widget.builtPrompt;
  _controller.text = requestText!;
  _handleSendMessage();
}
```

## Message Handling

The `_handleSendMessage` function manages sending messages. It first checks if the text field isn't empty. If it isn't, it adds the message to the `_messages` list with the role set as 'user', clears the text field, and sets `_isBusy` to true. It then fetches the chat response from Supabase and adds it to the `_messages` list with the role set as 'assistant'.

```dart
void _handleSendMessage() async {
  // ...
}
```

## Supabase Chat Response

The `_getSupabaseChatResponse` function is responsible for making requests to the Supabase function and handling the response. If the request is successful, it sets `responseText` to the generated text, `showSaveOption` to true, and returns the generated text. If an error occurs, it shows a SnackBar with an error message.

```dart
Future<String> _getSupabaseChatResponse(String prompt) async {
  // ...
}
```

## Chat History Saving and Loading

The `_saveChat` and `_loadChat` functions handle saving and loading chat history. `_saveChat` shows a dialog to input a key, and saves the chat history using this key. `_loadChat` shows a dialog with a list of saved chats. When a chat is selected, it loads the chat history.

```dart
Future<void> _saveChat() async {
  // ...
}

Future<void> _loadChat() async {
  // ...
}
```

## UI Design

The `build` function sets up the UI of the `ChatWindow`. It includes an AppBar with a home button and a popup menu to save and load chat history. The body contains a list of messages and a text field to input messages. The send button sends the message when pressed.

```dart
Widget build(BuildContext context) {
  // ...
}
```

The chat messages are displayed in a `ListView.builder`. Each message is displayed in a `ListTile` with an icon indicating the sender (user or assistant), the sender's role, the message content, and a `CircularProgressIndicator` if the message is the last user message and `_isBusy` is true.

```dart
ListView.builder(
  itemCount: _messages.length,
  itemBuilder: (context, index) {
    final message = _messages[index];
    final isLastUserMessage = message.role == 'user' &&
        index == _messages.length - 1;
    return ListTile(
      leading: Icon(
        message.role == 'user'
            ? Icons.person
            : Icons.assistant,
        color: Theme.of(context).primaryColor,
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${message.role.toUpperCase()}:\n',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color,
              ),
            ),
            TextSpan(
              text: '${message.content}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: message.role == 'user'
                    ? FontWeight.normal
                    : FontWeight.normal,
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color,
              ),
            ),
          ],
        ),
      ),
      trailing: isLastUserMessage && _isBusy
          ? const CircularProgressIndicator()
          : null,
    );
  },
)
```

## Message Input and Sending

The user can input their message in a TextField. When they press the send button, the `_handleSendMessage` function is called to send the message.

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8.0),
  child: Row(
    children: [
      Expanded(
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
              hintText: 'Enter your message here'),
          onSubmitted: (_) => _handleSendMessage(),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.send),
        onPressed: _handleSendMessage,
      ),
    ],
  ),
)
```

## Error Handling

Errors are handled in various functions. In the `_handleSendMessage` function, an error is handled by removing the last message (the user's message that caused the error), logging the error, and showing a SnackBar with an error message. Similarly, the `_getSupabaseChatResponse` function handles errors by logging them and throwing an exception with an error message.

```dart
void _handleSendMessage() async {
  // Error handling...
}

Future<String> _getSupabaseChatResponse(String prompt) async {
  // Error handling...
}
```

## Saving and Loading Chat History

The `_saveChat` function saves the chat history. It opens a dialog box where the user can enter a key to save the chat history. The chat history is saved under the key 'chat_`<key>`'.

```dart
Future<void> _saveChat() async {
  // ...
}
```

The `_loadChat` function loads the saved chat history. It opens a dialog box displaying the saved chats. When a chat is selected, it loads the chat history.

```dart
Future<void> _loadChat() async {
  // ...
}
```

The `_loadChatHistory` function loads the chat history for a given key. The loaded chat history is set as the `_messages` list.

```dart
void _loadChatHistory(String key) async {
  // ...
}
```

## ScaffoldMessenger and Scaffold

The `ScaffoldMessenger` widget is used to manage and display `SnackBar`s. Its key is `_scaffoldMessengerKey`.

Inside `ScaffoldMessenger`, there's a `Scaffold` widget that holds the whole structure of the chat window. The `AppBar` of the scaffold contains the title 'Chat Window', a home icon button that navigates to the `MyOcrApp` page, and a `PopupMenuButton` for saving and loading chat history.

```dart
ScaffoldMessenger(
  key: _scaffoldMessengerKey,
  child: Scaffold(
    appBar: AppBar(
      title: const Text('Chat Window'),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.home),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyOcrApp()),
            (Route<dynamic> route) => false,
          );
        },
      ),
      actions: [
        PopupMenuButton<int>(
          onSelected: (value) async {
            if (value == 0) {
              _saveChat();
            } else if (value == 1) {
              _loadChat();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            const PopupMenuItem<int>(
              value: 0,
              child: Text('Save Chat History'),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Text('Load Chat History'),
            ),
          ],
        ),
      ],
    ),
    body: Builder(builder: (BuildContext scaffoldContext) {
      // ...
    }),
  ),
)
```

## Body of Scaffold

The body of the scaffold is a `Container` that contains a `Column` with the chat history and the message input.

```dart
body: Builder(builder: (BuildContext scaffoldContext) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: Column(
      children: [
        // Chat history with scrollable messages
        Expanded(
          child: ListView.builder(
            // ...
          ),
        ),
        // Message input and send button
        Container(
          // ...
        ),
      ],
    ),
  );
}),
```

The chat history is a `ListView.builder` that creates a `ListTile` for each message in `_messages`.

The message input is a `Container` with a `Row` that contains a `TextField` for inputting the message and an `IconButton` for sending the message. When the send button is pressed, `_handleSendMessage` is called to handle sending the message.

## ListView.builder for Displaying Messages

The `ListView.builder` widget creates a scrollable list of `ListTile` widgets that represent chat messages. The number of `ListTile` widgets is determined by the length of the `_messages` list. Each `ListTile` includes an icon indicating whether the message is from the user or the assistant, a `RichText` widget for displaying the message, and a loading indicator if the last message from the user is being processed.

```dart
Expanded(
  child: ListView.builder(
    itemCount: _messages.length,
    itemBuilder: (context, index) {
      final message = _messages[index];
      final isLastUserMessage = message.role == 'user' &&
          index == _messages.length - 1;
      return ListTile(
        leading: Icon(
          message.role == 'user'
              ? Icons.person
              : Icons.assistant,
          color: Theme.of(context).primaryColor,
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${message.role.toUpperCase()}:\n',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color,
                ),
              ),
              TextSpan(
                text: '${message.content}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: message.role == 'user'
                      ? FontWeight.normal
                      : FontWeight.normal,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color,
                ),
              ),
            ],
          ),
        ),
        trailing: isLastUserMessage && _isBusy
            ? const CircularProgressIndicator()
            : null,
      );
    },
  ),
),
```

## TextField and IconButton for Sending Messages

The `TextField` widget provides a place for the user to enter their message. The `IconButton` widget, which displays an icon of a paper plane, is used to send the user's message when pressed. The `_handleSendMessage` method is called whenever the user presses the send button or submits the form in the `TextField`.

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8.0),
  child: Row(
    children: [
      Expanded(
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
              hintText: 'Enter your message here'),
          onSubmitted: (_) => _handleSendMessage(),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.send),
        onPressed: _handleSendMessage,
      ),
    ],
  ),
),
```

# ChatHistory Class

The `ChatHistory` class provides utilities to manage the chat history of the application. It uses `SharedPreferences` to persist and retrieve chat histories locally.

```dart
import 'dart:convert';
import 'package:icte21_gpt_ocr/Utils/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistory {
...
}
```

## Methods

- `saveChatHistory(String key, List<Message> messages)`: This asynchronous method saves the given list of messages under the provided key in `SharedPreferences`. It first converts each `Message` to a JSON string, and then stores them as a string list.

```dart
static Future<void> saveChatHistory(
      String key, List<Message> messages) async {...}
```

- `loadChatHistory(String key)`: This asynchronous method retrieves the chat history associated with the given key from `SharedPreferences`. It fetches the JSON string list, decodes each JSON string into a `Message`, and returns the list of messages.

```dart
static Future<List<Message>> loadChatHistory(String key) async {...}
```

- `listSavedChats()`: This asynchronous method returns a list of all keys in `SharedPreferences`.

```dart
static Future<List<String>> listSavedChats() async {...}
```

- `getAvailableKeys()`: This asynchronous method returns a list of all keys in `SharedPreferences` that start with the prefix `chat_`.

```dart
static Future<List<String>> getAvailableKeys() async {...}
```

- `editChatHistory(String key, List<Message> messages)`: This asynchronous method updates the chat history associated with the given key in `SharedPreferences` with the provided list of messages.

```dart
static Future<void> editChatHistory(
      String key, List<Message> messages) async {...}
```

- `deleteChatHistory(String key)`: This asynchronous method deletes the chat history associated with the given key from `SharedPreferences`.

```dart
static Future<void> deleteChatHistory(String key) async {...}
```

## File: chat_selecting.dart

This file defines a `ChatListDialog` widget that displays a list of chat conversations stored in the device's memory. It allows the user to select a conversation to view, edit, delete, or share.

### Class: ChatListDialog

The `ChatListDialog` is a `StatefulWidget` that creates an instance of `_ChatListDialogState`.

```dart
class ChatListDialog extends StatefulWidget {
  @override
  _ChatListDialogState createState() => _ChatListDialogState();
}
```

### Class: _ChatListDialogState

`_ChatListDialogState` is a `State` object for `ChatListDialog`. It holds a list of keys for accessing the saved chat histories, and manages the lifecycle of the `ChatListDialog` widget.

Upon initialization (`initState`), it calls the `_loadKeys` function to fetch the list of keys representing the saved chats.

```dart
void _loadKeys() async {
  keys = await ChatHistory.getAvailableKeys();
  setState(() {});
}
```

In the `build` method, it returns an `AlertDialog` containing a `ListView.builder` to generate a `ListTile` for each saved chat.

```dart
AlertDialog(
  title: const Text('Select a conversation'),
  content: Container(
    width: double.maxFinite,
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: keys.length,
      itemBuilder: (BuildContext context, int index) { ... }
    ),
  ),
);
```

Each `ListTile` represents a saved chat and contains:

- A title displaying the key of the chat.
- An `onTap` function that navigates to the `ChatWindow` for the selected chat.
- A trailing `Row` of `IconButton` widgets for editing, deleting, and sharing the chat.

### Function: itemBuilder

The `itemBuilder` function inside the `ListView.builder` creates a `ListTile` for each key in the `keys` list. The `ListTile` has the following functionality:

- **View**: Tapping on the `ListTile` navigates to the `ChatWindow` of the selected chat.
- **Edit**: Tapping the "Edit" `IconButton` navigates to the `EditChatPage` with the selected chat.
- **Delete**: Tapping the "Delete" `IconButton` deletes the selected chat history and updates the state to remove the key from the list.
- **Share**: Tapping the "Share" `IconButton` shares the selected chat history as text. Each message is formatted as '[Role] Content' and joined with a newline.

Here is the code for the `ListTile`:

```dart
ListTile(
  title: Text(keys[index]),
  onTap: () { ... },
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(icon: Icon(Icons.edit), onPressed: () { ... }),
      IconButton(icon: Icon(Icons.delete), onPressed: () { ... }),
      IconButton(icon: Icon(Icons.share), onPressed: () { ... }),
    ],
  ),
);
```

# EditChatPage.dart

This file contains the code for the `EditChatPage` class, which is a `StatefulWidget`. It allows users to edit a chat history.

## Class: EditChatPage

The `EditChatPage` class accepts two required parameters: `keyToEdit`, which is the key of the chat history to be edited, and `initialMessages`, which is the list of `Message` objects that are part of the initial chat history.

```dart
class EditChatPage extends StatefulWidget {
  final String keyToEdit;
  final List<Message> initialMessages;

  EditChatPage({Key? key, required this.keyToEdit, required this.initialMessages}) : super(key: key);

  @override
  _EditChatPageState createState() => _EditChatPageState();
}
```

## Class: _EditChatPageState

The `_EditChatPageState` class is the `State` object associated with `EditChatPage`. It maintains a list of `Message` objects, `_messages`, which are modified based on user interactions.

```dart
class _EditChatPageState extends State<EditChatPage> {
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages = widget.initialMessages;
  }
  //...
}
```

### Function: _addMessage

The `_addMessage` function opens a dialog box that allows users to input a new message. The new message's `role` is passed as a parameter. The function creates a `TextEditingController` to handle the user input and uses it to create a new `Message` object when the user taps the 'Add' button in the dialog.

```dart
Future<void> _addMessage(String role) async {
  TextEditingController _textEditingController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add $role Message'),
        content: TextField(
          controller: _textEditingController,
          maxLines: 10,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                _messages.add(Message(role: role, content: _textEditingController.text));
              });
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}
```

### Function: _showMessageEditor

The `_showMessageEditor` function opens a dialog box that allows users to edit an existing message. The message to be edited is identified by its index in the `_messages` list.

```dart
Future<void> _showMessageEditor(int index) async {
  TextEditingController _textEditingController = TextEditingController(text: _messages[index].content);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Message'),
        content: TextField(
          controller: _textEditingController,
          maxLines: 10,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                _messages[index] = Message(role: _messages[index].role, content: _textEditingController.text);
              });
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}
```

### Function: _removeMessage

The `_removeMessage` function removes a message from the `_messages` list. The message to be removed is identified by its index in the list.

```dart
void _removeMessage(int index) {
  setState(() {
    _messages.removeAt(index);

### Function: build

The `build` function defines the UI of the `EditChatPage`. The body of the page is a `Stack` widget that contains a `ReorderableListView.builder` and a `Column` of two `FloatingActionButton` widgets.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Edit Chat History'),
    ),
    body: Stack(
      children: [
        ReorderableListView.builder(
          //...
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: 'add_message_user',
                onPressed: () {
                  _addMessage('user');
                },
                child: const Icon(Icons.person_add),
              ),
              SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'add_message_assistant',
                onPressed: () {
                  _addMessage('assistant');
                },
                child: const Icon(Icons.assistant),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

#### ReorderableListView.builder

The `ReorderableListView.builder` is used to create a list of messages that can be rearranged by long-pressing and dragging the messages. The `builder` function for the list view creates a `LongPressDraggable` widget for each message. Each `LongPressDraggable` widget contains a `Card` widget that displays the message and a delete button. When the delete button is pressed, the `_removeMessage` function is called to remove the message.

The `onReorder` callback function is called when a message is moved. It removes the message from its old position and inserts it at the new position.

*It is important to note that reorder does not work properly and the fix will note be part of the project hand in*

#### FloatingActionButtons

The `Align` widget aligns its child, a `Column` of `FloatingActionButton` widgets, to the center-right of the screen. The first `FloatingActionButton` adds a new user message when pressed, and the second one adds a new assistant message when pressed. The `heroTag` property is used to distinguish between the two buttons since each `FloatingActionButton` in a single tree should have a unique `heroTag`.

# TL;DR

The user input is collected, processed, and sent to the assistant. The assistant's response is then displayed in the chat window. The user also has the ability to save and load chat histories.