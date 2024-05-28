import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medication_app/Const/texts.dart';
import 'package:medication_app/User/Follower/follow_request_model.dart';
import 'package:medication_app/User/Follower/follower_screen.dart';
import 'package:medication_app/User/patient_detail_screen.dart';

import '../auth_service.dart';

class FollowerApprovedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthService _authService = AuthService();
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: text('Accepted Requests'),
        ),
        body: Center(
          child: text('No user logged in'),
        ),
      );
    }
    Stream<List<FollowRequest>> fetchAcceptedFollowRequests(String doctorId) {
      return FirebaseFirestore.instance.collection('follow_requests').where('patientId', isEqualTo: doctorId).where('status', isEqualTo: 'accepted').snapshots().map((snapshot) => snapshot.docs.map((doc) => FollowRequest.fromDocument(doc)).toList());
    }

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            SizedBox(height: 100, width: 100, child: Image.asset('assets/reminder.png')),
            Divider(
              height: 60,
              color: Colors.grey.shade200,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FollowerScreen()));
              },
              child: text('قائمة المتابعات الجديدة', color: Colors.purple),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                _authService.signOut(context: context);
              },
              child: text('تسجيل الخروج', color: Colors.purple),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: text('مرضى تمت متابعتهم'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: StreamBuilder<List<FollowRequest>>(
          stream: fetchAcceptedFollowRequests(currentUser.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: text('حدث خطأ: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: text('لا توجد متابعات حاليا', fontSize: 16));
            } else {
              List<FollowRequest> requests = snapshot.data!;
              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  FollowRequest request = requests[index];
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.purple.shade100, border: Border.all(color: Colors.purple)),
                    child: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(request.followerId).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return text('جاري التحميل...');
                        } else if (snapshot.hasError) {
                          return text('حدث خطأ: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          var userDoc = snapshot.data!;
                          var userData = userDoc.data() as Map<String, dynamic>;
                          return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientDetailsScreen(
                                      patientId: request.patientId,
                                      followerId: request.followerId,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  text(userData['name']),
                                  text('سنة ${userData['age']} '),
                                ],
                              ));
                        } else {
                          return text('المريض غير موجود');
                        }
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
