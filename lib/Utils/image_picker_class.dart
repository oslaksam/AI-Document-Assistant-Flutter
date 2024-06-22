import 'dart:developer';

import 'package:image_picker/image_picker.dart';

Future<String> pickImage({ImageSource? source}) async {
  final picker = ImagePicker();

  String path = '';

  try {
    final getImage = await picker.pickImage(source: source!);

    if (getImage != null) {
      path = getImage.path;
    } else {
      path = '';
    }
  } catch (e) {
    log(e.toString());
  }

  return path;
}

Future<List<String>> pickMultipleImages() async {
  final picker = ImagePicker();
  List<String> paths = [];

  try {
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      for (XFile file in pickedFiles) {
        paths.add(file.path);
      }
    } else {
      paths = [];
    }
  } catch (e) {
    log(e.toString());
  }

  return paths;
}
