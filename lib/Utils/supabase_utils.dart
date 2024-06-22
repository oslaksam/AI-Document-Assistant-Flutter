import 'package:flutter/material.dart';
import 'package:icte21_gpt_ocr/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseManager {
  final client = supabase;

  Future<void> signUpUser(BuildContext context,
      {String? email, String? password}) async {
    debugPrint("email:$email password:$password");
    try {
      final result =
          await client.auth.signUp(email: email!, password: password!);
      debugPrint(result.toString());
      Navigator.pushReplacementNamed(context, 'login');
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } catch (error) {
      debugPrint(error.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Unexpected error occurred'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> signInUser(BuildContext context,
      {String? email, String? password}) async {
    debugPrint("email:$email password:$password");
    try {
      final result = await client.auth
          .signInWithPassword(email: email!, password: password!);
      debugPrint(result.toString());
      if (result.user == null) {
        debugPrint("User is null");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result.toString()), backgroundColor: Colors.red),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } catch (error) {
      debugPrint(error.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unexpected error occurred'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> signInWithGoogle({
    required BuildContext context,
    String? redirectTo,
    String? scopes,
    LaunchMode authScreenLaunchMode = LaunchMode.externalApplication,
    Map<String, String>? queryParams,
  }) async {
    const provider = Provider.google;
    final response = await supabase.auth.signInWithOAuth(provider);

    if (response) {
      // Handle successful login, for example, navigate to the home screen
      Navigator.pushReplacementNamed(context, '/home');
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Google login failed'), backgroundColor: Colors.red),
      );
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await client.auth.signOut();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false,
      );
    }
  }
}
