import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medication_app/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'login.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');

  Future<User?> signUpWithEmailAndPassword(String email, String password, String name, String age, String notes, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Save user data to Firestore
        await _usersCollection.doc(user.uid).set({
          'email': email,
          'name': name,
          'age': age,
          'notes': notes,
          'role': role,
        });

        // Update user model with ID
        await user.updateDisplayName(name); // Optional: Update user display name
        return user;
      }

      return null;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<void> signOut({required BuildContext context}) async {
    await _auth.signOut();
    pref!.remove('userToken');

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  Future<bool> isUserLoggedIn() async {
    return pref!.containsKey('userToken');
  }

  Future<String?> getUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _usersCollection.doc(user.uid).get();
      return doc['role'];
    }
    return null;
  }

  Future<XFile> createFileWithData(String data, fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName.txt';
    final file = File(path);
    await file.writeAsString(data);
    return XFile(path);
  }

  void shareFile(XFile file, hintText) {
    Share.shareXFiles([file], text: hintText);
  }

  removeToken() {
    pref!.remove('userToken');
  }
}
