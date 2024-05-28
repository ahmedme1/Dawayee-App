import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medication_app/Const/texts.dart';
import 'package:medication_app/User/Follower/follow_request_model.dart';

class FollowerScreen extends StatelessWidget {
  User? currentUser = FirebaseAuth.instance.currentUser;
  Future<void> updateFollowRequestStatus(String requestId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('follow_requests').doc(requestId).update({
        'status': status,
      });
      print('Follow request $requestId updated to $status');
    } catch (e) {
      print('Error updating follow request: $e');
    }
  }

  Stream<QuerySnapshot> _fetchFollowRequests() {
    return FirebaseFirestore.instance.collection('follow_requests').where('patientId', isEqualTo: currentUser!.uid).where('status', isEqualTo: 'pending').snapshots();
  }

  void _acceptRequest(String requestId) async {
    await updateFollowRequestStatus(requestId, 'accepted');
  }

  void _denyRequest(String requestId) async {
    await updateFollowRequestStatus(requestId, 'rejected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('طلبات المتابعة', fontSize: 20),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _fetchFollowRequests(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final followRequests = snapshot.data!.docs.map((doc) {
              return FollowRequest.fromDocument(doc);
            }).toList();

            if (followRequests.isEmpty) {
              return const Center(child: Text('لا توجد طلبات متابعة حاليا'));
            }
            return ListView.builder(
              itemCount: followRequests.length,
              itemBuilder: (context, index) {
                FollowRequest request = followRequests[index];
                return ListTile(
                  title: text(request.followerName),
                  subtitle: text('الحالة: ${request.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _acceptRequest(request.followerId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _denyRequest(request.followerId),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
