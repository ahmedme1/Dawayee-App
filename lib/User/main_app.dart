import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medication_app/Const/texts.dart';
import 'package:medication_app/User/Follower/follow_approved_screen.dart';
import 'package:medication_app/User/Follower/follower_screen.dart';
import 'package:medication_app/User/patient_screen.dart';
import 'package:medication_app/main.dart';

class MainAppScreen extends StatelessWidget {
  String? token = pref!.getString('userToken');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(token).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: text('خطأ: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            var userDoc = snapshot.data!;
            var userData = userDoc.data() as Map<String, dynamic>;
            String role = userData['role'];
            if (role == 'Patient') {
              return PatientScreen();
            } else if (role == 'Follower') {
              return FollowerApprovedScreen();
            } else {
              return Center(child: text('صلاحية غير معروفة'));
            }
          } else {
            return Center(child: text('مستخدم غير موجود'));
          }
        },
      ),
    );
  }
}
