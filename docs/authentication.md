# login_page.dart

## LoginPage Class

`LoginPage` is a `StatefulWidget` that creates an instance of `_LoginPageState`.

```dart
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}
```

## _LoginPageState Class

`_LoginPageState` class is the state associated with the `LoginPage` widget.

It defines several private variables:

- `_supabaseClient`: Instance of `SupabaseManager` to interact with Supabase API.
- `_emailController` and `_passwordController`: `TextEditingController` instances for email and password text fields.
- `_formKey`: A `GlobalKey` that uniquely identifies the `Form` widget and allows validation of the form.
- `_isLoading`: A boolean to indicate if the app is currently processing a user action.
- `_isPrivacyPolicyAccepted`: A boolean to indicate if the user has accepted the privacy policy.

The `dispose` method cleans up the controller when the `Widget` is disposed.

The `_showPrivacyPolicy` method is a method to display the privacy policy in a dialog box.

The `build` method describes the part of the user interface represented by the `LoginPage` widget. It returns a `Builder` widget that creates a `Scaffold` containing a `Form` with email and password fields, a login button, a Google sign-in button, and a new user button. It also includes a checkbox to accept the privacy policy and a button to read the privacy policy.

```dart
class _LoginPageState extends State<LoginPage> {
  final _supabaseClient = SupabaseManager();
  final TextEditingController _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPrivacyPolicyAccepted = false;

  // ...
  
  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

`'images/google_logo.png'` is the path to the Google logo in the assets directory.

# sign_page.dart

## SignUpPage Class

`SignUpPage` is a `StatefulWidget` that creates an instance of `_SignUpPageState`.

```dart
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}
```

## _SignUpPageState Class

`_SignUpPageState` class is the state associated with the `SignUpPage` widget.

It defines several private variables:

- `_supabaseClient`: Instance of `SupabaseManager` to interact with Supabase API.
- `_emailController` and `_passwordController`: `TextEditingController` instances for email and password text fields.
- `_formKey`: A `GlobalKey` that uniquely identifies the `Form` widget and allows validation of the form.
- `_isLoading`: A boolean to indicate if the app is currently processing a user action.

The `dispose` method cleans up the controller when the `Widget` is disposed.

The `build` method describes the part of the user interface represented by the `SignUpPage` widget. It returns a `Builder` widget that creates a `Scaffold` containing a `Form` with email and password fields, a sign-up button, and a button to switch to the login page.

```dart
class _SignUpPageState extends State<SignUpPage> {
  final _supabaseClient = SupabaseManager();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ...
  
  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

## supabase_utils.dart

This Dart file contains the `SupabaseManager` class, which is responsible for managing Supabase operations, such as signing up users, signing in users, signing in with Google, and logging out.

```dart
import 'package:flutter/material.dart';
import 'package:icte21_gpt_ocr/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseManager {
  final client = supabase;
  ...
}
```

### signUpUser

This method is responsible for signing up a user with an email and password. If the sign-up process is successful, it navigates to the 'login' screen. If any errors occur, it shows an error message using a `SnackBar`.

```dart
Future<void> signUpUser(BuildContext context,
    {String? email, String? password}) async {
  ...
}
```

### signInUser

This method is responsible for signing in a user with an email and password. If the sign-in process is successful, it navigates to the '/home' screen. If any errors occur, it shows an error message using a `SnackBar`.

```dart
Future<void> signInUser(BuildContext context,
    {String? email, String? password}) async {
  ...
}
```

### signInWithGoogle

This method is responsible for signing in a user with Google OAuth. If the sign-in process is successful, it navigates to the '/home' screen. If any errors occur, it shows an error message using a `SnackBar`.

```dart
Future<bool> signInWithGoogle({
  required BuildContext context,
  String? redirectTo,
  String? scopes,
  LaunchMode authScreenLaunchMode = LaunchMode.externalApplication,
  Map<String, String>? queryParams,
}) async {
  ...
}
```

### logout

This method is responsible for logging out the user. After the logout process, it navigates to the `MyApp` widget, which is the root widget of the application.

```dart
Future<void> logout(BuildContext context) async {
  ...
}
```

### Class Property: client

The class `SupabaseManager` uses a `client` property that is assigned the instance of the `Supabase` client.

```dart
final client = supabase;
```

This `client` is used in multiple methods for different Supabase operations such as signup, signin, and logout.

### Debugging

For debugging purposes, the `debugPrint()` function is used to print the email and password of the user during signup and signin operations. It's also used to print errors when they occur.

```dart
debugPrint("email:$email password:$password");
debugPrint(result.toString());
debugPrint(error.toString());
```

### Error Handling

Errors during Supabase operations are handled in two ways:

- By catching `AuthException` which is a specific type of exception that could occur during authentication operations.

- By catching other exceptions that could occur during these operations. This is done using a general `catch` block.

When an error is caught, a `SnackBar` is displayed to the user with an error message.

```dart
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
```

### Navigation

Navigation is handled using the `Navigator` class in Flutter. For instance, after a successful signup or signin, the user is navigated to a different screen using `Navigator.pushReplacementNamed(context, 'login')` or `Navigator.pushReplacementNamed(context, '/home')` respectively.

```dart
Navigator.pushReplacementNamed(context, 'login');
Navigator.pushReplacementNamed(context, '/home');
```

In the case of logout, `Navigator.pushAndRemoveUntil()` is used to remove all routes and return to the root widget (`MyApp`).

```dart
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => MyApp()),
  (Route<dynamic> route) => false,
);
```