# home_page.dart

## MyOcrApp Class

`MyOcrApp` is a `StatelessWidget` that returns a `MaterialApp`. It's the home page of the application after the user is authenticated.

```dart
class MyOcrApp extends StatelessWidget {
  const MyOcrApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI document assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'AI document assistant'),
    );
  }
}
```

## MyHomePage Class

`MyHomePage` is a `StatefulWidget` that creates an instance of `_MyHomePageState`. It requires a `title` parameter.

```dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
```

## _MyHomePageState Class

`_MyHomePageState` is the state associated with the `MyHomePage` widget.

```dart
class _MyHomePageState extends State<MyHomePage> {
  // ...
}
```

This state class defines several private variables:

- `text`: a `String` that will contain text input by the user.
- `controller`: a `StreamController` that will emit `String` values.
- `textEditingController`: a `TextEditingController` instance for text field input.
- `_isConfirmed`: a `bool` that indicates whether a user action has been confirmed.
- `_supabaseManager`: an instance of `SupabaseManager` to interact with Supabase API.
- `_paths`: a `List<String>` that will contain paths to image files.

The class also defines several methods:

- `setText`: a method that adds a `value` to the `controller` stream if `_isConfirmed` is `false`.
- `_showPrivacyPolicy`: a method that loads a privacy policy from a text file and displays it in an `AlertDialog`.
- `_showChatList`: a method that displays a `ChatListDialog`.
- `handleClick`: a method that handles user selection from a `PopupMenuButton`.
- `_requestPermissions`: a method that requests necessary permissions and returns a `Future<bool>` that indicates whether all permissions were granted.

The `dispose` method cleans up the controller and textEditingController when the `Widget` is disposed.

The `build` method describes the part of the user interface represented by the `MyHomePage` widget. It returns a `Builder` widget that creates a `Scaffold` containing an `AppBar` and several buttons that trigger different functionalities like starting a new scan, loading previous conversation, chatting with scanned document, showing the privacy policy, and quitting the application.

```dart
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (innerContext) {
        return Scaffold(
          // ...
        );
      },
    );
  }
```

The `_styledButton` method creates a styled `ElevatedButton` widget with the given `onPressed` callback and `text`.

```dart
  Widget _styledButton(
      {required VoidCallback onPressed, required String text}) {
    return Container(
      // ...
    );
  }
```