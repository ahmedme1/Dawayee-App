import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medication_app/Const/texts.dart';
import 'package:medication_app/User/Follower/followe_model.dart';

import 'follow_request_model.dart';

class FollowersList extends StatelessWidget {
  FollowersList({super.key});
  Future<List<Follower>> _fetchFollowers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Follower').get();
      return querySnapshot.docs.map((doc) {
        return Follower.fromDocument(doc);
      }).toList();
    } catch (e) {
      print('Error fetching followers: $e');
      return [];
    }
  }

  bool isSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: text('قائمة المتابعين', fontSize: 20),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: FutureBuilder<List<Follower>>(
          future: _fetchFollowers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: text('حدث خطأ: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: text('لا يوجد متابعين مسجلين', fontSize: 16));
            } else {
              List<Follower> followers = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: followers.length,
                itemBuilder: (context, index) {
                  Follower follower = followers[index];
                  return Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.purple)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FollowButton(doctorId: follower.id),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            text(follower.name),
                            text(follower.email),
                            text(follower.notes),
                          ],
                        ),
                      ],
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

  void _sendFollowRequest(String followerId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('follow_requests').add({
          'patientId': currentUser.uid,
          'followerId': followerId,
          'status': 'pending', // 'pending', 'accepted', 'rejected'
        });
        isSent = true;
        print('Follow request sent to follower with ID: $followerId');
      }
    } catch (e) {
      print('Error sending follow request: $e');
    }
  }
}

class FollowButton extends StatefulWidget {
  final String doctorId;

  FollowButton({required this.doctorId});

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  FollowRequest? _followRequest;
  bool _isLoading = true;

  Future<void> sendFollowRequest(String doctorId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    // Retrieve user details
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    String followerName = userSnapshot['name'];

    // Retrieve doctor details
    DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance.collection('users').doc(doctorId).get();
    String doctorName = doctorSnapshot['name'];

    await FirebaseFirestore.instance.collection('follow_requests').doc(currentUser.uid).set({
      'patientId': doctorId,
      'followerId': currentUser.uid,
      'status': 'pending',
      'followerName': followerName,
      'parentName': doctorName,
    });

    print('Follow request sent successfully');
  }

  Future<void> removeFollowRequest(String uid) async {
    await FirebaseFirestore.instance.collection('follow_requests').doc(uid).delete();
  }

  Future<FollowRequest?> fetchFollowRequestStatus(String doctorId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return null;
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('follow_requests').where('followerId', isEqualTo: currentUser.uid).where('patientId', isEqualTo: doctorId).get();

    if (querySnapshot.docs.isNotEmpty) {
      return FollowRequest.fromDocument(querySnapshot.docs.first);
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFollowRequestStatus();
  }

  Future<void> _fetchFollowRequestStatus() async {
    FollowRequest? followRequest = await fetchFollowRequestStatus(widget.doctorId);
    setState(() {
      _followRequest = followRequest;
      _isLoading = false;
    });
  }

  Future<void> _sendFollowRequest() async {
    setState(() {
      _isLoading = true;
    });
    await sendFollowRequest(widget.doctorId);
    await _fetchFollowRequestStatus();
  }

  Future<void> _removeFollowRequest() async {
    if (_followRequest != null) {
      setState(() {
        _isLoading = true;
      });
      await removeFollowRequest(_followRequest!.followerId);
      await _fetchFollowRequestStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_followRequest == null) {
      return ElevatedButton(
        onPressed: _sendFollowRequest,
        child: text('متابعة'),
      );
    }

    if (_followRequest!.status == 'pending') {
      return ElevatedButton(
        onPressed: _removeFollowRequest,
        child: text('تحت الطلب'),
      );
    }

    if (_followRequest!.status == 'accepted') {
      return ElevatedButton(
        onPressed: _removeFollowRequest,
        child: text('متابع'),
      );
    }

    return ElevatedButton(
      onPressed: _sendFollowRequest,
      child: text('متابعة'),
    );
  }
}
