import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../../Const/texts.dart';

Future<void> sendNotification(String fcmToken, String message) async {
  final String oneSignalAppId = oneSignal_app_Id;
  final String oneSignalRestApiKey = oneSignal_api_key;

  final Map<String, dynamic> notification = {
    'app_id': oneSignalAppId,
    'include_player_ids': [fcmToken],
    'contents': {'en': message},
  };

  final response = await http.post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Basic $oneSignalRestApiKey',
    },
    body: jsonEncode(notification),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully.');
    log(response.body.toString());
  } else {
    print('Failed to send notification: ${response.body}');
  }
}
