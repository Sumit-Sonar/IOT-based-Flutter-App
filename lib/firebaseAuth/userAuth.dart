import 'package:firebase_auth/firebase_auth.dart';

class UserAuth {
  final FirebaseAuth _firebaseUserAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseUserAuth.currentUser;

  Stream<User?> get userAuthStateChanges => _firebaseUserAuth.authStateChanges();

  Future<void> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseUserAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  Future<void> signOut() async {
    await _firebaseUserAuth.signOut(); 
  }
}
