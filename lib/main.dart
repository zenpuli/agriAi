import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AgriAIApp());
}

class AgriAIApp extends StatelessWidget {
  const AgriAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agri AI',
      theme: ThemeData(
        primaryColor: const Color(0xFF005C1F),
        useMaterial3: false,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
      },
    );
  }
}

//
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Widget> _checkUserStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const LoginScreen();
    }

    // Fetch user data (name and userType) from Firestore
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final name = data['name'] ?? 'User';
        final type = data['userType'] ?? 'Farmer';
        return HomeScreen(userName: name, userType: type);
      } else {
        await FirebaseAuth.instance.signOut();
        return const LoginScreen();
      }
    } catch (e) {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _checkUserStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Simple splash/loading screen
          return const Scaffold(
            backgroundColor: Color(0xFFF9FBF9),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF005C1F)),
            ),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong. Please restart.")),
          );
        } else {
          return snapshot.data!;
        }
      },
    );
  }
}
