import 'package:flutter/material.dart';
import 'package:medication_app/Const/texts.dart';
import 'package:medication_app/Doctors/doctor_visit_list_screen.dart';
import 'package:medication_app/Medication/list_screen.dart';
import 'package:medication_app/User/Follower/followers_list.dart';
import 'auth_service.dart';

class PatientScreen extends StatelessWidget {
  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            SizedBox(height: 100, width: 100, child: Image.asset('assets/reminder.png')),
            Divider(
              height: 60,
              color: Colors.grey.shade200,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FollowersList()));
              },
              child: text('قائمة المتابعين', color: Colors.purple),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                _authService.signOut(context: context);
              },
              child: text('تسجيل الخروج', color: Colors.purple),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: text('حسابي', fontSize: 20),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 120, width: 120, child: Image.asset('assets/reminder.png')),
            const SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicationListScreen(),
                  ),
                );
              },
              child: Container(
                height: 50,
                width: 250,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.purple.shade200),
                child: text('الأدوية', color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorVisitListScreen(),
                  ),
                );
              },
              child: Container(
                height: 50,
                width: 250,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.purple.shade200),
                child: text('زيارات الطبيب', color: Colors.white),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
