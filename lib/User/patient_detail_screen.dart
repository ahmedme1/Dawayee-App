import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medication_app/Const/texts.dart';
import 'package:medication_app/Doctors/doctor_visit_model.dart';
import 'package:medication_app/Medication/medication_model.dart';
import 'package:medication_app/User/Follower/follow_service.dart';
import 'package:medication_app/User/previw_image.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientId;
  final String followerId;

  PatientDetailsScreen({required this.patientId, required this.followerId});

  @override
  _PatientDetailsScreenState createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final FollowService _followService = FollowService();
  bool _isFollower = false;

  @override
  void initState() {
    super.initState();
    _checkIfFollower();
  }

  Future<void> _checkIfFollower() async {
    bool isFollower = await _followService.isFollower(widget.patientId, widget.followerId);
    setState(() {
      _isFollower = isFollower;
    });
  }

  bool showMed = false;
  bool showDoc = false;
  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('معلومات المريض', fontSize: 20),
        centerTitle: true,
      ),
      body: _isFollower ? _buildFollowerView() : _buildNonFollowerView(),
    );
  }

  Widget _buildFollowerView() {
    // This is where you build the view for a follower who can see the patient's details
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                showMed = !showMed;
                showDoc = false;
              });
            },
            child: Container(
              height: 40,
              width: 250,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.purple.shade100,
                border: Border.all(color: Colors.purple),
              ),
              child: text('ادوية المريض', color: Colors.purple),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Visibility(
          visible: showMed,
          child: Expanded(
            child: FutureBuilder<List<Medications>>(
              future: _fetchMedications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('حدث خطأ: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  List<Medications> medications = snapshot.data!;

                  return ListView.builder(
                    itemCount: medications.length,
                    itemBuilder: (context, index) {
                      Medications medication = medications[index];
                      DateTime nextMedicationTime = medication.getNextMedicationTime();
                      int remainingPieces = medication.getRemainingPieces();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            isOpen = !isOpen;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.purple)),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  text(medication.name),
                                  text('اسم الدواء'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  text(medication.dose),
                                  text('التركيز '),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  text('${'كل'} ${medication.frequencyDuration.inHours.toString()} ${'ساعة'}'),
                                  text('تكرار الجرعة'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  text(medication.pieces.toString()),
                                  text('عدد الحبوب'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  text(remainingPieces.toString()),
                                  text('المتبقي من الحبوب'),
                                ],
                              ),
                              const SizedBox(height: 10),
                              text('(${DateFormat('HH:mm a').format(nextMedicationTime)}) :  موعد الجرعة القادمة '),
                              const SizedBox(height: 10),
                              Visibility(
                                visible: isOpen,
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
                  );
                } else {
                  return text('المريض ليس لديه اي ادوية حاليا');
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                showMed = false;
                showDoc = !showDoc;
              });
            },
            child: Container(
              height: 40,
              width: 250,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.purple.shade100,
                border: Border.all(color: Colors.purple),
              ),
              child: text('زيارات المريض', color: Colors.purple),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Visibility(
          visible: showDoc,
          child: Expanded(
            child: FutureBuilder<List<DoctorVisits>>(
              future: _fetchDoctorVisits(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return text('حدث خطأ ${snapshot.error}');
                } else if (snapshot.hasData) {
                  List<DoctorVisits> visits = snapshot.data!;
                  return ListView.builder(
                    itemCount: visits.length,
                    itemBuilder: (context, index) {
                      DoctorVisits visit = visits[index];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.purple)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text(visit.doctorName),
                                text('اسم الطبيب'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text(visit.result),
                                text('النتيجة '),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text(visit.xrayOrLabResult),
                                text('إشاعة ام نتائج معملية'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text(DateFormat('yyy-MM-dd').format(visit.visitDate)),
                                text('تاريخ الزيارة '),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text(DateFormat('yyy-MM-dd').format(visit.revisitDate)),
                                text('تاريخ إعادة الزيارة'),
                              ],
                            ),
                            if (visit.imageUrls.isNotEmpty)
                              SizedBox(
                                height: 50,
                                width: 250,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: visit.imageUrls.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewImageScreen(imageUrl: visit.imageUrls[index])));
                                        },
                                        child: SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: Image.network(visit.imageUrls[index]),
                                        ),
                                      );
                                    }),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return text('لا توجد زيارات للطبيب');
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNonFollowerView() {
    // This is where you build the view for a user who is not a follower
    return Center(
      child: text('ليس لديك صلاحية الوصول لمعلومات المريض'),
    );
  }

  Future<List<Medications>> _fetchMedications() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.followerId).collection('medications').get();

      return querySnapshot.docs.map((doc) => Medications.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching medications: $e');
      return [];
    }
  }

  Future<List<DoctorVisits>> _fetchDoctorVisits() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.followerId).collection('doctorVisits').get();

      return querySnapshot.docs.map((doc) => DoctorVisits.fromDocument(doc)).toList();
    } catch (e) {
      print('Error fetching doctor visits: $e');
      return [];
    }
  }
}
