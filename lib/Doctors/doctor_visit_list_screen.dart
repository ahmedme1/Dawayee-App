import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medication_app/Const/texts.dart';
import 'package:medication_app/User/auth_service.dart';
import 'package:medication_app/main.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'doctor_visit_provider.dart';
import 'add_doctor_visit_screen.dart';

class DoctorVisitListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DoctorVisitProvider>(context);
    AuthService _authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: text('زيارات الطبيب'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: provider.doctorVisits.length,
        itemBuilder: (context, index) {
          final visit = provider.doctorVisits[index];
          return Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.purple.shade100, border: Border.all(color: Colors.purple)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.purple),
                      onPressed: () async {
                        String dataToShare = '''
                     زيارة دكتور. ${visit.doctorName},
                    النتيجة: ${visit.result},
                    موعد الاعادة : ${DateFormat('yyyy-MM-dd').format(visit.revisitDate)},
                      ''';
                        XFile file = await _authService.createFileWithData(dataToShare, '${'زيارة دكتور'} ${visit.doctorName}');
                        _authService.shareFile(file, '${'زيارة دكتور'} ${visit.doctorName}');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.purple),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddDoctorVisitScreen(
                              visit: visit,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.purple),
                      onPressed: () {
                        provider.deleteDoctorVisit(pref!.getString('userToken')!, visit.id);
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    text('زيارة دكتور. ${visit.doctorName}'),
                    text('النتيجة: ${visit.result}'),
                    const SizedBox(height: 10),
                    text('موعد الاعادة', color: Colors.purple),
                    text(DateFormat('yyyy-MM-dd HH:mm a').format(visit.revisitDate)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDoctorVisitScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
