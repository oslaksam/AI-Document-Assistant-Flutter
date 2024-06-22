import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icte21_gpt_ocr/Screen/sign_page.dart';
import 'package:icte21_gpt_ocr/Utils/supabase_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _supabaseClient = SupabaseManager();
  final TextEditingController _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPrivacyPolicyAccepted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return Builder(
      builder: (innerContext) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Login Page"),
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 200,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          hintText: 'Enter a valid email'),
                      validator: (String? value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Email is not valid';
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15, bottom: 0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          hintText: 'Enter secure password'),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Invalid password';
                        }
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password',
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                        });
                        if (_formKey.currentState!.validate()) {
                          _supabaseClient
                              .signInUser(innerContext,
                                  email: _emailController.text,
                                  password: _passwordController.text)
                              .then((_) {
                            setState(() {
                              _isLoading = false;
                            });
                          });
                        }
                      },
                      child: Text(
                        _isLoading ? 'Loading' : 'Login',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                        });
                        _supabaseClient
                            .signInWithGoogle(context: innerContext)
                            .then((_) {
                          setState(() {
                            _isLoading = false;
                          });
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/google_logo.png',
                            // add the Google logo to your assets folder
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sign in with Google',
                            style: GoogleFonts.roboto(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 130,
                  ),
                  TextButton(
                    onPressed: () {
                      if (_isPrivacyPolicyAccepted) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpPage()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please accept the Privacy Policy')),
                        );
                      }
                    },
                    child: const Text('New User? Create Account'),
                  ),
                  Center(
                    child: CheckboxListTile(
                      title: const Text('I agree to the Privacy Policy'),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _isPrivacyPolicyAccepted,
                      onChanged: (bool? value) {
                        setState(() {
                          _isPrivacyPolicyAccepted = value!;
                        });
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: _showPrivacyPolicy,
                    child: const Text('Read Privacy Policy'),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
