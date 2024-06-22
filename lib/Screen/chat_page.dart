import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:icte21_gpt_ocr/Screen/home_page.dart';
import 'package:icte21_gpt_ocr/Utils/message.dart';
import 'package:icte21_gpt_ocr/Utils/message_history.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ChatWindow extends StatefulWidget {
  final String builtPrompt;
  final String keyToLoad;

  const ChatWindow(
      {Key? key, required this.builtPrompt, required this.keyToLoad})
      : super(key: key);

  @override
  _ChatWindowState createState() => _ChatWindowState();

// Define your sendMessage function here, or pass it as a parameter to ChatWindow constructor
}

class _ChatWindowState extends State<ChatWindow> {
  final TextEditingController _controller = TextEditingController();
  List<Message> _messages = [];
  String? responseText;
  String? requestText;
  bool showSaveOption = false;
  bool _isBusy = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    if (widget.builtPrompt == "") {
      // do load
      _loadChatHistory(widget.keyToLoad);
    }
    requestText = widget.builtPrompt;
    _controller.text = requestText!;
    _handleSendMessage();
  }

  void _loadChatHistory(String key) async {
    List<Message> history = await ChatHistory.loadChatHistory(key);
    setState(() {
      _messages = history;
    });
  }

  void _handleSendMessage() async {
    if (_controller.text.isNotEmpty) {
      requestText = _controller.text;
      setState(() {
        _messages.add(Message(role: 'user', content: requestText!));
      });
      _controller.clear();
      setState(() {
        _isBusy = true;
      });
      try {
        final response = await _getSupabaseChatResponse(requestText!);
        if (mounted) {
          setState(() {
            _messages.add(Message(role: 'assistant', content: response));
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _messages.removeLast();
          });
        }
        log(e.toString());
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
              content: Text(
                  "Unexpected error happened try logging out and in again. If the issue persists, please contact the support."),
              backgroundColor: Colors.red),
        );
      }
      setState(() {
        _isBusy = false;
      });
    }
  }

  Future<String> _getSupabaseChatResponse(String prompt) async {
    log(prompt);
    final res = await supabase.functions
        .invoke('openai-chat-api', headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    }, body: {
      'messages': _messages.map((message) => message.toJson()).toList(),
    });

    if (res.status == 200) {
      log(res.data.toString());
      String generatedText = res.data['completion']['content'];
      log(_messages.toString());
      setState(() {
        responseText = generatedText;
        showSaveOption = true;
      });
      return generatedText;
    } else {
      log(res.status.toString());
      log(res.data.toString());

      String errorMessage = 'There Was an Error Generating a Response';
      /*   if (res.data.containsKey('error')) {
        errorMessage = res.data['error'];
      }*/

      /*   ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );*/
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );

      throw Exception(errorMessage);
    }
  }

  Future<void> _saveChat() async {
    TextEditingController _keyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Save Chat History'),
          content: TextField(
            controller: _keyController,
            decoration:
                InputDecoration(hintText: 'Enter a key to save chat history'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                await ChatHistory.saveChatHistory(
                    'chat_${_keyController.text}', _messages);
                // Dismiss the dialog before showing SnackBar
                Navigator.popUntil(context, (route) => route.isFirst);
                /*ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat history saved')),
                );*/
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                      content: Text('Chat history saved'),
                      backgroundColor: Colors.lightBlue),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadChat() async {
    List<String> savedChats = await ChatHistory.listSavedChats();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Load Chat History'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: savedChats.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(savedChats[index]),
                  onTap: () async {
                    List<Message> loadedMessages =
                        await ChatHistory.loadChatHistory(savedChats[index]);
                    setState(() {
                      _messages = loadedMessages;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
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
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                // Chat history with scrollable messages
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
                // Message input and send button
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
              ],
            ),
          );
        }),
      ),
    );
  }
}
