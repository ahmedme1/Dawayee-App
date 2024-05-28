import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:medication_app/main.dart';
import 'dart:async';
import 'medication_model.dart';

class MedicationProvider with ChangeNotifier {
  List<Medications> _medications = [];
  bool _isLoading = true;

  List<Medications> get medications => _medications;
  bool get isLoading => _isLoading;

  MedicationProvider() {
    fetchMedications(pref!.getString('userToken')!);
  }

  Future<void> fetchMedications(String patientId) async {
    _isLoading = true;
    notifyListeners();

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(patientId).collection('medications').get();
    _medications = snapshot.docs.map((doc) => Medications.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateMedication(String patientId, Medications medication) async {
    await FirebaseFirestore.instance
      ..collection('users').doc(patientId).collection('medications').doc(medication.id).update(medication.toMap());
    fetchMedications(patientId);
  }

  void deleteMedication(String patientId, String medicationId) {
    FirebaseFirestore.instance.collection('users').doc(patientId).collection('medications').doc(medicationId).delete();
    fetchMedications(patientId);
  }

  void addMedication(
    Medications medication,
    String patientId,
  ) {
    FirebaseFirestore.instance..collection('users').doc(patientId).collection('medications').add(medication.toMap());
    fetchMedications(patientId);
    _scheduleReminder(patientId, medication);
  }

  void _scheduleReminder(String patientID, Medications medication) {
    DateTime nextReminderTime = medication.startDate;
    while (nextReminderTime.isBefore(DateTime.now())) {
      nextReminderTime = nextReminderTime.add(medication.frequencyDuration);
    }

    int notificationId = _medications.indexOf(medication);

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'medication_channel',
        title: 'هذا وقت دوائك',
        body: 'هذا وقت دوائك : ${medication.name}.',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: nextReminderTime, allowWhileIdle: true, preciseAlarm: true, repeats: true),
    );

    Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      _checkMedicationIntake(patientID, medication);
    });
  }

  void _checkMedicationIntake(String patientID, Medications medication) {
    DateTime now = DateTime.now();
    DateTime nextIntakeTime = medication.startDate;
    while (nextIntakeTime.isBefore(now)) {
      nextIntakeTime = nextIntakeTime.add(medication.frequencyDuration);
    }
    if (now.hour == nextIntakeTime.hour && now.minute == nextIntakeTime.minute) {
      if (medication.pieces > 0) {
        medication.pieces--;
        notifyListeners();
        _updateMedicationInDatabase(patientID, medication);
        if (medication.pieces < 10) {
          _scheduleLowStockNotification(medication);
        }
      }
    }
  }

  void decrementMedicationPieces(String patientID, String medicationId) async {
    final medication = _medications.firstWhere((med) => med.id == medicationId);
    if (medication.pieces > 0) {
      medication.pieces--;
      notifyListeners();
      await _updateMedicationInDatabase(patientID, medication);
      if (medication.pieces < 10) {
        _scheduleLowStockNotification(medication);
      }
    }
  }

  Future<void> _updateMedicationInDatabase(String patientID, Medications medication) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(patientID).collection('medications').doc(medication.id).get();
      if (docSnapshot.exists) {
        await docSnapshot.reference.update({
          'pieces': medication.pieces,
        });
      } else {
        // Handle the case where the document does not exist
        print('Error: Document with ID ${medication.id} does not exist in the database.');
      }
    } catch (error) {
      print('Error updating medication in database: $error');
    }
  }

  void _scheduleLowStockNotification(Medications medication) {
    int notificationId = _medications.indexOf(medication) + 1000; // Ensure unique ID

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'medication_channel',
        title: 'انخفاض المتبقي من الحبوب',
        body: 'انخفض المتبقي عن 10 حبوب من هذا الدواء ${medication.name}',
        notificationLayout: NotificationLayout.Default,
        payload: {'id': medication.id},
      ),
    );
  }

  void checkMedicationIntake(String patientID) {
    final currentTime = DateTime.now();
    _medications.forEach((medication) {
      if (_isTimeToTakeMedication(currentTime, medication)) {
        decrementMedicationPieces(patientID, medication.id);
      }
    });
  }

  bool _isTimeToTakeMedication(DateTime currentTime, Medications medication) {
    // Check if current time matches the scheduled time for taking medication
    final int hoursDifference = currentTime.difference(medication.startDate).inHours;
    return (hoursDifference % medication.frequencyDuration.inHours == 0) && (hoursDifference >= 0); // Ensure medication time has passed
  }
}
