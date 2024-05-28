import 'package:flutter/material.dart';

Text text(String title, {double fontSize = 16, Color color = Colors.black}) {
  return Text(
    title,
    style: TextStyle(fontFamily: 'tajwal', fontSize: fontSize, color: color),
  );
}

const String oneSignal_app_Id = '50ca78c8-88cc-4679-9121-f410ed5f2107';
const String oneSignal_api_key = 'OWNiOTgxMTQtZjY0Ny00NmY2LThkMDQtZjdiZjhiMjYzMzc0';
