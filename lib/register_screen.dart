import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final green = const Color(0xFF005C1F);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? region;
  String? userType = 'Farmer';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception("Please fill all required fields");
      }

      // Create user
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
        'uid': userCred.user!.uid,
        'name': name,
        'email': email,
        'userType': userType ?? 'Farmer',
        'region': region ?? 'Not selected',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userName: name, userType: userType ?? 'Farmer'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? 'Registration failed');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tabs
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text("Sign In",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600])),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: green.withOpacity(.05),
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text("Sign Up",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, color: green)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              Text("Create account",
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.w600)),
              Text("Join Agri AI to start smarter farming",
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 20),

              _field("Full Name", _nameController),
              const SizedBox(height: 14),
              _dropdown("User Type", ["Farmer", "Expert"], userType,
                  (v) => setState(() => userType = v)),
              const SizedBox(height: 14),
              _dropdown("Region", [
                "North Region",
                "South Region",
                "East Region",
                "West Region"
              ], region, (v) => setState(() => region = v)),
              const SizedBox(height: 14),
              _field("Email", _emailController),
              const SizedBox(height: 14),
              _field("Password", _passwordController, obscure: true),
              const SizedBox(height: 20),

              if (_errorMessage != null)
                Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14)),

              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48)),
                onPressed: _isLoading ? null : _registerUser,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
          labelText: label, border: const OutlineInputBorder()),
    );
  }

  Widget _dropdown(String label, List<String> items, String? value,
      Function(String?) onChanged) {
    return InputDecorator(
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text("Select your ${label.toLowerCase()}"),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
