import 'package:cloud_firestore/cloud_firestore.dart';

class Follower {
  final String id;
  final String name;
  final String email;
  final String notes;

  Follower({
    required this.id,
    required this.name,
    required this.email,
    required this.notes,
  });

  // Factory method to create a Follower from Firestore document data
  factory Follower.fromDocument(DocumentSnapshot doc) {
    return Follower(
      id: doc.id,
      name: doc['name'],
      email: doc['email'],
      notes: doc['notes'],
    );
  }

  // Method to convert Follower to Firestore document data
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'notes': notes,
    };
  }
}
