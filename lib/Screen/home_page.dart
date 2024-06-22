import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icte21_gpt_ocr/Screen/chat_scanned_document.dart';
import 'package:icte21_gpt_ocr/Screen/recognization_page.dart';
import 'package:icte21_gpt_ocr/Utils/image_cropper_page.dart';
import 'package:icte21_gpt_ocr/Utils/image_picker_class.dart';
import 'package:icte21_gpt_ocr/Utils/supabase_utils.dart';
import 'package:icte21_gpt_ocr/Widgets/chat_selecting.dart';
import 'package:icte21_gpt_ocr/Widgets/modal_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MyOcrApp extends StatelessWidget {
  const MyOcrApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Document Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'AI Document Assistant'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text = "";
  final StreamController<String> controller = StreamController<String>();
  final TextEditingController textEditingController = TextEditingController();
  bool _isConfirmed = false;
  final _supabaseManager = SupabaseManager();
  List<String> _paths = [];

  void setText(value) {
    if (!_isConfirmed) {
      controller.add(value);
    }
  }

  Future<void> _showPrivacyPolicy() async {
    String privacyPolicy =
        await rootBundle.loadString('assets/privacy_policy.txt');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Privacy Policy'),
          content: SingleChildScrollView(child: Text(privacyPolicy)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.close();
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> _showChatList(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChatListDialog();
      },
    );
  }

  void handleClick(BuildContext context, String value) {
    switch (value) {
      case 'Logout':
        _supabaseManager.logout(context);
        break;
    }
  }

  Future<bool> _requestPermissions() async {
    return true;
    // Request the necessary permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
      Permission.mediaLibrary,
    ].request();

    // Check if all permissions are granted
    bool allGranted = statuses.values.every((status) => status.isGranted);

    // Show a warning message if permissions are not granted
    if (!allGranted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Camera and Gallery access permissions are required.'),
      ));
    }

    return allGranted;
  }

  Future<void> _showHelpMessage() async {
    String helpMessage = """
With the Login and Sign Up pages, creating a new account or accessing an existing one is just a few taps away. Simply provide your email and password, and rest assured that your information is secure and will not be shared with third parties.

Once logged in, the Home Page serves as your control center. From here, you can scan documents, revisit past conversations, or engage with scanned documents. All functions are clearly labeled, ensuring ease of use. You can also quickly access the privacy policy and exit the app as needed.

When ready to scan, our Image Picker tool lets you choose images from your gallery or take new photos. You can also use the Image Cropper tool to fine-tune your images. If you're dealing with multiple images, no problem - we can handle that too.

The Recognize Page utilizes Google ML Kit Text Recognition, giving you the power to identify and process text from your images. Switching between multiple images is as straightforward as clicking the next or previous buttons.

The OptionsPage offers flexibility in processing your text. Whether you want a straightforward request, a custom prompt, or a document-specific chat, we've got you covered. You can select actions from a dropdown menu, input your own prompt, and even customize the tone, writing style, and output language of the response.

The Simple request feature allows you to chat with our AI assistant, ensuring you don't miss any details. You can manually save your chat history for future reference, or revisit previous chats at any time.

For document-specific inquiries, the Chat with your docs feature allows targeted interaction with the AI assistant, enhancing your understanding of your documents.

In the Edit Chat Page, you can modify your chats to better represent your ideas. Add new messages, edit existing ones, delete unnecessary ones, or even reorder your messages for improved clarity.
  """;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help'),
          content: SingleChildScrollView(child: Text(helpMessage)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (innerContext) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: (value) => handleClick(innerContext, value),
                itemBuilder: (BuildContext context) {
                  return {
                    'Logout',
                  }.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _styledButton(
                    onPressed: () async {
                      if (await _requestPermissions()) {
                        imagePickerModal(context, onCameraTap: () async {
                          log("Camera");
                          String value =
                              await pickImage(source: ImageSource.camera);
                          if (value != '') {
                            String croppedValue =
                                await imageCropperView(value, context);
                            if (croppedValue != '') {
                              setState(() {
                                _paths.add(croppedValue);
                              });
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => RecognizePage(
                                    paths: _paths,
                                    initialIndex: _paths.length - 1,
                                  ),
                                ),
                              );
                            }
                          }
                        }, onGalleryTap: () async {
                          log("Gallery from home");

                          List<XFile>? pickedFiles =
                              await ImagePicker().pickMultiImage();

                          if (pickedFiles != null && pickedFiles.isNotEmpty) {
                            for (XFile file in pickedFiles) {
                              String value = file.path;
                              if (value != '') {
                                String croppedValue =
                                    await imageCropperView(value, context);
                                if (croppedValue != '') {
                                  setState(() {
                                    _paths.add(croppedValue);
                                  });
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => RecognizePage(
                                        paths: _paths,
                                        initialIndex: _paths.length - 1,
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        });
                      }
                    },
                    text: 'New Scan',
                  ),
                  SizedBox(height: 16),
                  _styledButton(
                    onPressed: () {
                      _showChatList(context);
                    },
                    text: 'Load Previous Conversation',
                  ),
                  SizedBox(height: 16),
                  _styledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScannedDocumentPage()),
                      );
                    },
                    text: 'Chat with Scanned Document',
                  ),
                  SizedBox(height: 16),
                  _styledButton(
                    onPressed: _showHelpMessage,
                    text: 'Help',
                  ),
/*
                    SizedBox(height: 16),
                    _styledButton(
                      onPressed: () {
                        // TODO: Implement Upload PDF document feature
                      },
                      text: 'Upload PDF document',
                    ),

 */
                  SizedBox(height: 16),
                  _styledButton(
                    onPressed: _showPrivacyPolicy,
                    text: 'Privacy Policy',
                  ),
                  SizedBox(height: 16),
                  _styledButton(
                    onPressed: () {
                      //Logout
                      _supabaseManager.logout(context);
                      // Terminate the application
                      SystemNavigator.pop();
                    },
                    text: 'Quit',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _styledButton(
      {required VoidCallback onPressed, required String text}) {
    return Container(
      width: 220,
      height: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          textStyle: TextStyle(fontSize: 18),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
