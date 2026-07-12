import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? user;
  String role = '';
  String name = '';
  bool loading = false;
  String error = '';

  AuthProvider() {
    _auth.authStateChanges().listen((u) async {
      user = u;
      if (u != null) {
        await fetchUserData();
      } else {
        role = '';
        name = '';
      }
      notifyListeners();
    });
  }

  bool get isLoggedIn => user != null;

  Future<void> fetchUserData() async {
    try {
      var doc = await _db.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        role = doc['role'] ?? '';
        name = doc['name'] ?? '';
        notifyListeners();
      }
    } catch (e) {
      print('error fetching user data: $e');
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String selectedRole, {
    String startupName = '',
    String startupOneLiner = '',
    String startupWebsite = '',
  }) async {
    try {
      loading = true;
      error = '';
      notifyListeners();

      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // base user data
      Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'role': selectedRole,
        'verified': true,
        'createdAt': DateTime.now().toString(),
      };

      // add startup specific data
      if (selectedRole == 'startup') {
        userData['startupName'] = startupName;
        userData['startupOneLiner'] = startupOneLiner;
        userData['startupWebsite'] = startupWebsite;
      }

      await _db.collection('users').doc(result.user!.uid).set(userData);

      role = selectedRole;
      this.name = name;
      loading = false;
      notifyListeners();
      return true;

    } catch (e) {
      loading = false;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      loading = true;
      error = '';
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      loading = false;
      notifyListeners();
      return true;

    } catch (e) {
      loading = false;
      error = 'Wrong email or password';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    role = '';
    name = '';
    notifyListeners();
  }
}