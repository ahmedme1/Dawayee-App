import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medication_app/Doctors/doctor_visit_model.dart';
import 'package:medication_app/Medication/medication_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<List<Medications>> fetchMedications(String patientId) async {
    QuerySnapshot snapshot = await _db.collection('users').doc(patientId).collection('medications').get();

    return snapshot.docs.map((doc) => Medications.fromFirestore(doc)).toList();
  }

  Future<List<DoctorVisits>> fetchDoctorVisits(String patientId) async {
    QuerySnapshot snapshot = await _db.collection('users').doc(patientId).collection('doctorVisits').get();

    return snapshot.docs.map((doc) => DoctorVisits.fromFirestore(doc)).toList();
  }

  // Create user profile in Firestore
  Future<void> createUserProfile(User user, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(data);
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }
}
