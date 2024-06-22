# main.dart

This is the entry point of the Flutter application.

## main() Function

The `main()` function is the entry point of the application.

- `WidgetsFlutterBinding.ensureInitialized()`: This line makes sure that the widget binding is initialized. This needs to be done before any other operation.
- `await dotenv.load(fileName: "assets/.env")`: This line loads the environment variables from the `.env` file in the assets directory.
- `await Supabase.initialize()`: This line initializes the Supabase client with the URL pointing to the Supabase project management endpoint and anonymous key obtained from the environment variables.

## MyApp Class

This class extends `StatelessWidget`, which means this widget describes part of the user interface which can depend on configuration but cannot change over time.

The `build` method returns a `MaterialApp` widget. The `MaterialApp` widget is a convenience widget that wraps a number of widgets that are commonly required for applications implementing Material Design.

- `title`: The title of the application.
- `debugShowCheckedModeBanner`: If set to false, it disables the display of the debug banner even when running in a debug mode.
- `initialRoute`: The name of the first route to show.
- `routes`: Defines the available named routes and the widgets to build when navigating to those routes.
- `theme`: The theming of the application.
- `home`: The widget for the default route of the app (`/`).

```dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of the application.
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
```