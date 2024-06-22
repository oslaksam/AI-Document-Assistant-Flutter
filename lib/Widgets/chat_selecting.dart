import 'package:flutter/material.dart';
import 'package:icte21_gpt_ocr/Screen/chat_page.dart';
import 'package:icte21_gpt_ocr/Screen/edit_chat_page.dart';
import 'package:icte21_gpt_ocr/Utils/message.dart';
import 'package:icte21_gpt_ocr/Utils/message_history.dart';
import 'package:share_plus/share_plus.dart';

class ChatListDialog extends StatefulWidget {
  @override
  _ChatListDialogState createState() => _ChatListDialogState();
}

class _ChatListDialogState extends State<ChatListDialog> {
  List<String> keys = []; // Initialize keys with an empty list

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  void _loadKeys() async {
    keys = await ChatHistory.getAvailableKeys();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select a conversation'),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: keys.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(keys[index]),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatWindow(builtPrompt: "", keyToLoad: keys[index]),
                  ),
                );
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      List<Message> initialMessages =
                          await ChatHistory.loadChatHistory(keys[index]);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditChatPage(
                            keyToEdit: keys[index],
                            initialMessages: initialMessages,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await ChatHistory.deleteChatHistory(keys[index]);
                      setState(() {
                        keys.removeAt(index);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () async {
                      List<Message> messages =
                          await ChatHistory.loadChatHistory(keys[index]);
                      String conversationText = messages
                          .map((message) =>
                              '[${message.role}] ${message.content}')
                          .join('\n');
                      Share.share(conversationText,
                          subject: 'Conversation from ChatGPT');
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
