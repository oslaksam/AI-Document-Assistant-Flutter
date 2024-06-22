# AI Document Assistant (icte21_gpt_ocr)

A useful app for document Q&A using OpenAI API. Made by me as part of a group project at AAU Copenhagen.
Backend was managed by Supabase which used Edge functions to handle document processing and conversations.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Documentation

Documentation for different components of this application can be found in the *docs* folder.

# Below is the structure of the project:

## Screen

This directory contains the main screens of the Flutter application.

- `chat_docs_page.dart`: This file handles the operations related to the Chat with your docs functionality.
- `chat_page.dart`: This file contains the UI and logic for the simple chat page.
- `chat_scanned_document.dart`: This file deals with the operations chat operations on already scanned documents.
- `edit_chat_page.dart`: This file is used for editing chat page operations.
- `home_page.dart`: This file represents the home page of the application.
- `login_page.dart`: This file handles the login operations of the application.
- `options_page.dart`: This file is used for managing options of operating on the scanned text within the application.
- `recognition_page.dart`: This file is responsible for operations related to OCR functionality.
- `sign_page.dart`: This file is used for handling user sign-in/sign-up operations.

## Utils

This directory contains utility files that provide various helper functions and classes to the project.

- `image_cropper_page.dart`: This utility file provides functionality related to image cropping.
- `image_picker_class.dart`: This utility file helps in image picking operations.
- `message.dart`: This file contains the `Message` class, which defines the structure and operations of a message.
- `message_history.dart`: This utility file helps in dealing with message history operations.
- `supabase_utils.dart`: This file contains utility functions for interacting with Supabase.

## Widgets

This directory contains various reusable widgets for the application.

- `chat_selecting.dart`: This widget is used for selecting chat operations.
- `modal_dialog.dart`: This widget is used to display modal dialog boxes.

## Root

- `main.dart`: This is the entry point of the Flutter application. It is responsible for running the whole application.
