import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AuthProvider_ extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late User? _loggedInUser;

  User? get loggedInUser => _loggedInUser;

  bool get isLoggedIn => _auth.currentUser != null;

  // Function to get the username for the logged-in user
  Future<String> getUsername() async {
    if (_auth.currentUser != null) {
      final userId = _auth.currentUser!.uid;
      final userRef = FirebaseDatabase.instance.ref().child('users').child(userId);
      final snapshot = await userRef.get();
      if (snapshot.exists) {
        return snapshot.child('name').value.toString(); // Fetch username
      }
    }
    return 'Anonymous'; // Default if no username found
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String mobileNumber,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store the user details in the database
      final DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(_auth.currentUser!.uid);
      await userRef.set({
        'email': email,
        'name': name,
        'mobileNumber': mobileNumber,
      });
      _loggedInUser = _auth.currentUser;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _loggedInUser = _auth.currentUser;
      notifyListeners();
      return true; // Return true if sign-in is successful
    } catch (e) {
      return false; // Return false if sign-in fails
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();

      _loggedInUser = null;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
