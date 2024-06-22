import 'dart:async';

import 'package:flutter/material.dart';
import 'package:icte21_gpt_ocr/Screen/home_page.dart';
import 'package:icte21_gpt_ocr/Screen/login_page.dart';
import 'package:icte21_gpt_ocr/Screen/sign_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  String? supabaseUrl = dotenv.env['supabaseUrl'];
  String? supabaseAnonKey = dotenv.env['supabaseAnonKey'];
  await Supabase.initialize(
    url: supabaseUrl!,
    anonKey: supabaseAnonKey!,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI document assistant',
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',
      routes: {
        'login': (_) => const LoginPage(),
        '/signup': (_) => const SignUpPage(),
        '/home': (_) => const MyOcrApp(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyOcrApp(),
    );
  }
}
