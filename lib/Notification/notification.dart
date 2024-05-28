import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  Future<void> initialize() async {
    AwesomeNotifications().initialize(
      '',
      [
        NotificationChannel(
          channelKey: 'medication_channel',
          channelName: 'Medication Channel',
          channelDescription: 'Notification channel for medication reminders',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
        ),
        NotificationChannel(
          channelKey: 'doctor_visit_channel',
          channelName: 'Doctor Visit Notifications',
          channelDescription: 'Notification channel for doctor visit reminders',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
        ),
      ],
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'medication_channel',
        title: title,
        body: body,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledDate),
    );
  }

  Future<void> cancel(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}
