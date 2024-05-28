import 'dart:async';
import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medication_app/Const/texts.dart';
import 'package:medication_app/Doctors/doctor_visit_provider.dart';
import 'package:medication_app/Medication/medication_model.dart';
import 'package:medication_app/Medication/medication_provider.dart';
import 'package:medication_app/User/auth_service.dart';
import 'package:medication_app/User/login.dart';
import 'package:medication_app/User/main_app.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

SharedPreferences? pref;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(oneSignal_app_Id);
  OneSignal.Notifications.requestPermission(true);
  OneSignal.User.getOnesignalId();
  AwesomeNotifications().initialize(
    '',
    [
      NotificationChannel(
        channelKey: 'medication_channel',
        channelName: 'Medication Channel',
        channelDescription: 'Channel for Medication Reminders',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
      ),
      NotificationChannel(
        channelKey: 'doctor_visit_channel',
        channelName: 'Doctor Visit Notifications',
        channelDescription: 'Notification channel for doctor visit reminders',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
      ),
    ],
  );
  pref = await SharedPreferences.getInstance();
  await Permission.notification.request();
  await Permission.storage.request();

  String? token = pref!.getString('userToken');
  if (token != null) {
    final medicationProvider = MedicationProvider();

    // Run the checkMedicationIntake method periodically
    Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      medicationProvider.checkMedicationIntake(token);
    });

    runApp(
      ChangeNotifierProvider(
        create: (context) => medicationProvider,
        child: MyApp(),
      ),
    );
  } else {
    runApp(
      MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();
  String? token = pref!.getString('userToken');
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => DoctorVisitProvider()),
      ],
      child: MaterialApp(
        title: 'دوائي',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        home: token == null ? LoginScreen() : MainAppScreen(),
      ),
    );
  }
}

Future<void> _takeMedication(String medicationId) async {
  DocumentSnapshot medicationSnapshot = await FirebaseFirestore.instance.collection('medications').doc(medicationId).get();
  if (medicationSnapshot.exists) {
    Medications medication = Medications.fromMap(medicationSnapshot.data() as Map<String, dynamic>, medicationId);

    if (medication.pieces > 0) {
      medication.pieces--;
      await FirebaseFirestore.instance.collection('medications').doc(medicationId).update({'pieces': medication.pieces});
    }
  }
}
