import 'package:flutter/material.dart';
import 'package:medication_app/Const/texts.dart';

import '../Doctors/doctor_visit_model.dart';

class DoctorVisitDetailsScreen extends StatelessWidget {
  final DoctorVisits visit;

  DoctorVisitDetailsScreen({required this.visit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('تفاصيل زيارة الطبيب'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            text('تاريخ الزيارة: ${visit.visitDate.toString()}'),
            if (visit.revisitDate != null) text('تاريخ الاعاده: ${visit.revisitDate.toString()}'),
            if (visit.imageUrls.isNotEmpty)
              Column(
                children: visit.imageUrls.map((imageUrl) {
                  return Image.network(imageUrl);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
