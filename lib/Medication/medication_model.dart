import 'package:cloud_firestore/cloud_firestore.dart';

class Medications {
  String id;
  String name;
  String dose;
  int pieces;
  String imageUrl;
  DateTime startDate;
  String frequency;

  Medications({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.dose,
    required this.pieces,
    required this.startDate,
    required this.frequency,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dose': dose,
      'pieces': pieces,
      'startDate': startDate,
      'imageUrl': imageUrl,
      'frequency': frequency,
    };
  }

  static Medications fromMap(Map<String, dynamic> map, String id) {
    return Medications(
      id: id,
      name: map['name'],
      dose: map['dose'],
      pieces: map['pieces'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      frequency: map['frequency'],
      imageUrl: map['imageUrl'],
    );
  }

  factory Medications.fromDocument(DocumentSnapshot doc) {
    return Medications(
      id: doc.id,
      name: doc['name'],
      dose: doc['dose'],
      pieces: doc['pieces'],
      startDate: (doc['startDate'] as Timestamp).toDate(),
      frequency: doc['frequency'],
      imageUrl: doc['imageUrl'],
    );
  }

  factory Medications.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Medications(
      id: doc.id,
      name: data['name'] ?? '',
      dose: data['dose'] ?? '',
      pieces: data['pieces'] ?? 0,
      startDate: (data['startDate'] as Timestamp).toDate(),
      frequency: data['frequency'] ?? 24,
      imageUrl: data['imageUrl'],
    );
  }

  Duration get frequencyDuration {
    switch (frequency) {
      case '4 hours':
        return const Duration(hours: 4);
      case '8 hours':
        return const Duration(hours: 8);
      case '12 hours':
        return const Duration(hours: 12);
      case '24 hours':
        return const Duration(hours: 24);
      default:
        return const Duration(hours: 24);
    }
  }

  DateTime getNextMedicationTime() {
    DateTime now = DateTime.now();
    Duration frequencyDuration = this.frequencyDuration;

    DateTime nextMedicationTime = startDate;

    while (nextMedicationTime.isBefore(now)) {
      nextMedicationTime = nextMedicationTime.add(frequencyDuration);
    }

    return nextMedicationTime;
  }

  int getRemainingPieces() {
    DateTime now = DateTime.now();
    Duration frequencyDuration = this.frequencyDuration;
    DateTime current = startDate;

    int dosesTaken = 0;

    while (current.isBefore(now)) {
      dosesTaken++;
      current = current.add(frequencyDuration);
    }

    int remainingPieces = pieces - dosesTaken;
    return remainingPieces >= 0 ? remainingPieces : 0;
  }
}
