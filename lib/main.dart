import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'services/flight_api_service.dart';
import 'services/flight_checker.dart';
import 'services/notification_service.dart';
import 'pages/home_page.dart';
import 'pages/new_trip_form_page.dart';
import 'pages/login_page.dart';
import 'pages/trip_details_page.dart';
import 'models/trip_model.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize services
    final notificationService = NotificationService();
    await notificationService.init();

    // Initialize API service
    const apiKey = String.fromEnvironment('TRAVELPAYOUTS_API_KEY');
    final apiService = FlightApiService(apiKey);

    runApp(
      MultiProvider(
        providers: [
          // Provide FlightChecker once
          ChangeNotifierProvider(
            create: (_) => FlightChecker(apiService, notificationService),
          ),
          // Provide NotificationService for direct access if needed
          Provider(create: (_) => notificationService),
        ],
        child: const MyApp(),
      ),
    );
  } catch (error) {
    debugPrint('Initialization error: $error');
    runApp(const ErrorApp());
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to initialize app. Please restart.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAuthListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initializeAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'À Bientôt',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      initialRoute: '/',
      routes: _buildAppRoutes(),
      onGenerateRoute: (settings) {
        if (settings.name == '/trip-details') {
          final trip = settings.arguments as TripModel?;
          if (trip != null) {
            return MaterialPageRoute(
              builder: (context) => TripDetailsPage(trip: trip),
            );
          }
        }
        return null;
      },
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: Colors.grey[900]!,
        onPrimary: Colors.white,
        background: Colors.white,
        onBackground: Colors.grey[800]!,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey),
        titleTextStyle: TextStyle(
          color: Colors.grey[900],
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme().copyWith(
        displayLarge: TextStyle(color: Colors.grey[900]),
        displayMedium: TextStyle(color: Colors.grey[800]),
        bodyLarge: TextStyle(color: Colors.grey[900]),
        bodyMedium: TextStyle(color: Colors.grey[800]),
        labelLarge: TextStyle(color: Colors.grey[800]),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(color: Colors.grey[800]),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildAppRoutes() {
    return {
      '/': (context) => const HomePage(),
      '/new-trip': (context) => const NewTripFormPage(),
      '/login': (context) => const LoginPage(),
    };
  }
}
