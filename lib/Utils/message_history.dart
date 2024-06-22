import 'dart:convert';

import 'package:icte21_gpt_ocr/Utils/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistory {
  static Future<void> saveChatHistory(
      String key, List<Message> messages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedChatsJson =
        messages.map((message) => json.encode(message.toJson())).toList();
    await prefs.setStringList(key, savedChatsJson);
  }

  static Future<List<Message>> loadChatHistory(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedChatsJson = prefs.getStringList(key);
    if (savedChatsJson == null) return [];
    return savedChatsJson
        .map((messageJson) => Message.fromJson(json.decode(messageJson)))
        .toList();
  }

  static Future<List<String>> listSavedChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().toList();
  }

  static Future<List<String>> getAvailableKeys() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final chatKeys = keys.where((key) => key.startsWith('chat_')).toList();
    return chatKeys;
  }

  static Future<void> editChatHistory(
      String key, List<Message> messages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedChatsJson =
        messages.map((message) => json.encode(message.toJson())).toList();
    await prefs.setStringList(key, savedChatsJson);
  }

  static Future<void> deleteChatHistory(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
