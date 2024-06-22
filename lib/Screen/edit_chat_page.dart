import 'package:flutter/material.dart';
import 'package:icte21_gpt_ocr/Utils/message.dart';

class EditChatPage extends StatefulWidget {
  final String keyToEdit;
  final List<Message> initialMessages;

  EditChatPage(
      {Key? key, required this.keyToEdit, required this.initialMessages})
      : super(key: key);

  @override
  _EditChatPageState createState() => _EditChatPageState();
}

class _EditChatPageState extends State<EditChatPage> {
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages = widget.initialMessages;
  }

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
                  _messages.add(Message(
                      role: role, content: _textEditingController.text));
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

  Future<void> _showMessageEditor(int index) async {
    TextEditingController _textEditingController =
        TextEditingController(text: _messages[index].content);
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
                  _messages[index] = Message(
                      role: _messages[index].role,
                      content: _textEditingController.text);
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

  void _removeMessage(int index) {
    setState(() {
      _messages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Chat History'),
      ),
      body: Stack(
        children: [
          ReorderableListView.builder(
            itemCount: _messages.length,
            itemBuilder: (BuildContext context, int index) {
              Message message = _messages[index];
              return LongPressDraggable<int>(
                key: ValueKey(message.hashCode),
                data: index,
                axis: Axis.vertical,
                child: Card(
                  elevation: 4,
                  child: ListTile(
                    onTap: () {
                      _showMessageEditor(index);
                    },
                    title: Text(message.content),
                    subtitle: Text(message.role),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _removeMessage(index);
                      },
                    ),
                  ),
                ),
                feedback: Material(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    child: Card(
                      child: ListTile(
                        title: Text(message.content),
                        subtitle: Text(message.role),
                      ),
                    ),
                  ),
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                childWhenDragging: Container(),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final Message item = _messages.removeAt(oldIndex);
                _messages.insert(newIndex, item);
              });
            },
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
}
