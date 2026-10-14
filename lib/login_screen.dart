import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Login user
      UserCredential userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );

      // Fetch additional data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception("User data not found in Firestore.");
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final userName = userData['name'] ?? 'User';
      final userType = userData['userType'] ?? 'Farmer';

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userName: userName, userType: userType),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? 'Login failed');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF005C1F);
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.eco, color: Color(0xFF005C1F), size: 60),
              const SizedBox(height: 12),
              Text("Agri AI",
                  style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.w600, color: green)),
              const SizedBox(height: 28),

              // Toggle Tabs
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: green.withOpacity(.05),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text("Sign In",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, color: green)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text("Sign Up",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600])),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null)
                Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14)),

              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _isLoading ? null : _loginUser,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Sign In"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
