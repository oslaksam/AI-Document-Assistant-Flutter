import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:icte21_gpt_ocr/Screen/home_page.dart';
import 'package:icte21_gpt_ocr/Screen/options_page.dart';
import 'package:icte21_gpt_ocr/Utils/image_cropper_page.dart';
import 'package:icte21_gpt_ocr/Utils/image_picker_class.dart';
import 'package:icte21_gpt_ocr/Widgets/modal_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> _requestStoragePermission() async {
  PermissionStatus status;
  status = await Permission.storage.request();
  status = await Permission.photosAddOnly.request();
  status = await Permission.photos.request();
  status = await Permission.manageExternalStorage.request();
  status = await Permission.camera.request();
  return true;
}

class RecognizePage extends StatefulWidget {
  final List<String> paths;
  final int initialIndex;

  const RecognizePage({Key? key, required this.paths, this.initialIndex = 0})
      : super(key: key);

  @override
  State<RecognizePage> createState() => _RecognizePageState();
}

class _RecognizePageState extends State<RecognizePage> {
  bool _isBusy = false;
  int _currentIndex = 0;
  List<TextEditingController> _controllers = [];

  Future<void> _addPage(BuildContext context) async {
    imagePickerModal(context, onCameraTap: () async {
      String value = await pickImage(source: ImageSource.camera);
      await _handleAddPage(value, context);
    }, onGalleryTap: () async {
      bool isGranted = await _requestStoragePermission();
      if (isGranted) {
        List<String> pickedFiles = await pickMultipleImages();

        if (pickedFiles.isNotEmpty) {
          for (String filePath in pickedFiles) {
            await _handleAddPage(filePath, context);
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission is required.')),
        );
      }
    });
  }

  Future<void> _handleAddPage(String value, BuildContext context) async {
    if (value != '') {
      String croppedValue = await imageCropperView(value, context);
      if (croppedValue != '') {
        setState(() {
          widget.paths.add(croppedValue);
          _controllers.add(TextEditingController());
          _currentIndex = widget.paths.length - 1;
        });

        final InputImage inputImage = InputImage.fromFilePath(croppedValue);
        processImage(inputImage, _currentIndex);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;
    widget.paths.forEach((_) => _controllers.add(TextEditingController()));

    final InputImage inputImage =
        InputImage.fromFilePath(widget.paths[_currentIndex]);
    processImage(inputImage, _currentIndex);
  }

  // ...

  void _navigateToOptions(BuildContext context) {
    String combinedText =
        _controllers.map((controller) => controller.text).join('\n');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => OptionsPage(scannedText: combinedText)),
    );
  }

  // ...

  void _nextPage() {
    setState(() {
      _currentIndex++;
      if (_currentIndex < widget.paths.length) {
        if (_controllers[_currentIndex].text.isEmpty) {
          final InputImage inputImage =
              InputImage.fromFilePath(widget.paths[_currentIndex]);
          processImage(inputImage, _currentIndex);
        }
      } else {
        _currentIndex = widget.paths.length - 1;
      }
    });
  }

  void _previousPage() {
    setState(() {
      _currentIndex--;
      if (_currentIndex >= 0) {
        if (_controllers[_currentIndex].text.isEmpty) {
          final InputImage inputImage =
              InputImage.fromFilePath(widget.paths[_currentIndex]);
          processImage(inputImage, _currentIndex);
        }
      } else {
        _currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Recognized page ${_currentIndex + 1}"),
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
            )),
        body: _isBusy == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _currentIndex > 0 ? _previousPage : null,
                          child: const Text("Previous"),
                        ),
                        ElevatedButton(
                          onPressed: () => _navigateToOptions(context),
                          child: const Text("Submit"),
                        ),
                        ElevatedButton(
                          onPressed: _currentIndex < widget.paths.length - 1
                              ? _nextPage
                              : null,
                          child: const Text("Next"),
                        ),
                      ],
                    ),
                    FloatingActionButton(
                      backgroundColor: Colors.blue,
                      onPressed: () => _addPage(context),
                      child: const Icon(Icons.add),
                    ),
                    TextFormField(
                      maxLines: MediaQuery.of(context).size.height.toInt(),
                      controller: _controllers[_currentIndex],
                      decoration:
                          const InputDecoration(hintText: "Text goes here..."),
                    )
                  ],
                ),
              ));
  }

  void processImage(InputImage image, int index) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    setState(() {
      _isBusy = true;
    });

    log(image.filePath!);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(image);
    await textRecognizer.close();

    _controllers[index].text = recognizedText.text;

    ///End busy state
    setState(() {
      _isBusy = false;
    });
  }
}
