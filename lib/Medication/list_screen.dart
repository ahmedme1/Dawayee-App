import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medication_app/Const/texts.dart';
import 'package:medication_app/Medication/add_medication.dart';
import 'package:medication_app/User/auth_service.dart';
import 'package:medication_app/main.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'medication_provider.dart';

class MedicationListScreen extends StatefulWidget {
  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  List<bool> isOpen = [];
  @override
  Widget build(BuildContext context) {
    final medicationProvider = Provider.of<MedicationProvider>(context);
    AuthService _authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: text('الأدوية', fontSize: 20),
        centerTitle: true,
      ),
      body: medicationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: medicationProvider.medications.length,
              itemBuilder: (ctx, i) {
                isOpen.add(false);
                final medication = medicationProvider.medications[i];
                DateTime nextMedicationTime = medication.getNextMedicationTime();
                int remainingPieces = medication.getRemainingPieces();
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isOpen[i] = !isOpen[i];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.purple.shade100, border: Border.all(color: Colors.purple)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.share, color: Colors.purple),
                                  onPressed: () async {
                                    String dataToShare = '''
                     ${medication.name},
                              تركيز الدواء: ${medication.dose},
                                عدد الحبوب : ${medication.pieces},
                                المتبقي من الحبوب: ${medication.pieces - ((DateTime.now().difference(medication.startDate).inHours / medication.frequencyDuration.inHours).floor())},
                            ''';
                                    XFile file = await _authService.createFileWithData(dataToShare, '${'علاج'} ${medication.name}');
                                    _authService.shareFile(file, '${'علاج'} ${medication.name}');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.purple),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AddMedicationScreen(medication: medication),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.purple),
                                  onPressed: () {
                                    medicationProvider.deleteMedication(pref!.getString('userToken')!, medication.id);
                                  },
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                text(medication.name),
                                text('تركيز الدواء: ${medication.dose}'),
                                text('عدد الحبوب : ${medication.pieces}'),
                                text('المتبقي من الحبوب: $remainingPieces'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        text('(${DateFormat('HH:mm a').format(nextMedicationTime)}) :  موعد الجرعة القادمة '),
                        const SizedBox(height: 10),
                        Visibility(
                          visible: isOpen[i],
                          child: Column(
                            children: [
                              text('صورة الدواء'),
                              const SizedBox(height: 10),
                              Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    image: DecorationImage(
                                      image: NetworkImage(medication.imageUrl),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddMedicationScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
