import 'package:creovate/user/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:creovate/user/admin.dart';
import 'package:creovate/user/homepage.dart';
import 'package:creovate/user/loginscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures binding is initialized before Firebase
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(), // Ensure Firebase is initialized
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading screen
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error initializing Firebase"));
          }
          return LoginScreen(); // Show login screen when Firebase is ready
        },
      ),
    );
  }
}
