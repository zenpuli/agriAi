import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new user
  Future<String> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Check if email already registered
      final existingUsers = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (existingUsers.docs.isNotEmpty) {
        return 'User already exists';
      }

      // Create user in FirebaseAuth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': DateTime.now(),
      });

      return 'Registration successful';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return 'The password is too weak.';
      if (e.code == 'email-already-in-use') return 'Email already registered.';
      return e.message ?? 'Registration failed.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Login user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return 'Login successful';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'No user found with this email.';
      if (e.code == 'wrong-password') return 'Incorrect password.';
      return e.message ?? 'Login failed.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
