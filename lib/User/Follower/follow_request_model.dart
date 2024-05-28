import 'package:cloud_firestore/cloud_firestore.dart';

class FollowRequest {
  final String patientId;
  final String followerId;
  final String status; // 'pending', 'accepted', 'rejected'
  final String followerName;
  final String parentName;

  FollowRequest({
    required this.patientId,
    required this.followerId,
    required this.status,
    required this.followerName,
    required this.parentName,
  });

  factory FollowRequest.fromDocument(DocumentSnapshot doc) {
    return FollowRequest(
      patientId: doc['patientId'],
      followerId: doc['followerId'],
      status: doc['status'],
      followerName: doc['followerName'],
      parentName: doc['parentName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'followerId': followerId,
      'status': status,
      'followerName': followerName,
      'parentName': parentName,
    };
  }
}
