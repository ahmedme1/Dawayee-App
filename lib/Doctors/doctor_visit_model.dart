import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorVisits {
  String id;
  String doctorName;
  String result;
  String xrayOrLabResult;
  DateTime visitDate;
  DateTime revisitDate;
  List<String> imageUrls;

  DoctorVisits({
    required this.id,
    required this.doctorName,
    required this.result,
    required this.xrayOrLabResult,
    required this.visitDate,
    required this.revisitDate,
    required this.imageUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'result': result,
      'xrayOrLabResult': xrayOrLabResult,
      'visitDate': visitDate,
      'revisitDate': revisitDate,
      'imageUrls': imageUrls,
    };
  }

  factory DoctorVisits.fromMap(String id, Map<String, dynamic> map) {
    return DoctorVisits(
      id: id,
      doctorName: map['doctorName'] ?? '',
      result: map['result'] ?? '',
      xrayOrLabResult: map['xrayOrLabResult'] ?? '',
      visitDate: (map['visitDate'] as Timestamp).toDate(),
      revisitDate: (map['revisitDate'] as Timestamp).toDate(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }
  factory DoctorVisits.fromDocument(DocumentSnapshot doc) {
    return DoctorVisits(
      id: doc.id,
      doctorName: doc['doctorName'] ?? '',
      result: doc['result'] ?? '',
      xrayOrLabResult: doc['xrayOrLabResult'] ?? '',
      visitDate: (doc['visitDate'] as Timestamp).toDate(),
      revisitDate: (doc['revisitDate'] as Timestamp).toDate(),
      imageUrls: List<String>.from(doc['imageUrls'] ?? []),
    );
  }
  factory DoctorVisits.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return DoctorVisits(
      id: doc.id,
      doctorName: doc['doctorName'] ?? '',
      result: doc['result'] ?? '',
      xrayOrLabResult: doc['xrayOrLabResult'] ?? '',
      visitDate: (doc['visitDate'] as Timestamp).toDate(),
      revisitDate: (doc['revisitDate'] as Timestamp).toDate(),
      imageUrls: List<String>.from(doc['imageUrls'] ?? []),
    );
  }
}
