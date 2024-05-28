import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medication_app/Doctors/doctor_visit_model.dart';
import 'package:medication_app/Notification/notification.dart';
import 'package:medication_app/main.dart';

class DoctorVisitProvider with ChangeNotifier {
  final List<DoctorVisits> _doctorVisits = [];
  final NotificationService _notificationService = NotificationService();

  DoctorVisitProvider() {
    _notificationService.initialize();
    fetchDoctorVisits(pref!.getString('userToken')!);
  }

  List<DoctorVisits> get doctorVisits => _doctorVisits;

  Future<void> fetchDoctorVisits(String patientId) async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(patientId).collection('doctorVisits').get();

    _doctorVisits.clear();
    snapshot.docs.forEach((doc) {
      _doctorVisits.add(DoctorVisits.fromMap(doc.id, doc.data() as Map<String, dynamic>));
    });
    notifyListeners();
  }

  Future<void> addDoctorVisit(String patientId, DoctorVisits visit, List<String> imageUrls) async {
    final docRef = await FirebaseFirestore.instance.collection('users').doc(patientId).collection('doctorVisits').add(visit.toMap());

    visit.id = docRef.id;
    _doctorVisits.add(visit);
    notifyListeners();

    scheduleRevisitNotification(visit);
  }

  void scheduleRevisitNotification(DoctorVisits visit) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'doctor_visit_channel',
        title: 'تذكير بموعد اعادة زيارة الطبيب',
        body: 'لديك اعادة مع دكتور ${visit.doctorName} في موعد ${visit.revisitDate}',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: visit.revisitDate.year,
        month: visit.revisitDate.month,
        day: visit.revisitDate.day,
        hour: visit.revisitDate.hour,
        minute: visit.revisitDate.minute,
        second: 0,
        millisecond: 0,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: false,
      ),
    );
  }

  int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  Future<void> updateDoctorVisit(String patientId, DoctorVisits visit, List<String> imageUrls) async {
    await FirebaseFirestore.instance.collection('users').doc(patientId).collection('doctorVisits').doc(visit.id).update(visit.toMap());

    final index = _doctorVisits.indexWhere((v) => v.id == visit.id);
    if (index != -1) {
      _doctorVisits[index] = visit;
      notifyListeners();

      scheduleRevisitNotification(visit);
    }
  }

  Future<void> deleteDoctorVisit(String patientId, String visitId) async {
    await FirebaseFirestore.instance.collection('users').doc(patientId).collection('doctorVisits').doc(visitId).delete();

    _doctorVisits.removeWhere((visit) => visit.id == visitId);
    notifyListeners();

    await AwesomeNotifications().cancel(visitId.hashCode);
  }
}
