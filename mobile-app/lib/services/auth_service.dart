import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  Future<User?> signUp(String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if needed
      if (result.user != null) {
        await result.user!.updateDisplayName(username);
      }

      return result.user;
    } catch (e) {
      print("Signup error: $e");
      return null;
    }
  }

  // Add this logout method
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Logout error: $e");
    }
  }

  // Add this getter for current user
  User? get currentUser => _auth.currentUser;
}