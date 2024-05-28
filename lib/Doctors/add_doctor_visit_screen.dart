import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medication_app/Const/texts.dart';
import 'package:medication_app/Doctors/doctor_visit_model.dart';
import 'package:medication_app/main.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'doctor_visit_provider.dart';

class AddDoctorVisitScreen extends StatefulWidget {
  final DoctorVisits? visit;

  AddDoctorVisitScreen({this.visit});

  @override
  _AddDoctorVisitScreenState createState() => _AddDoctorVisitScreenState();
}

class _AddDoctorVisitScreenState extends State<AddDoctorVisitScreen> {
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  final TextEditingController _xrayOrLabResultController = TextEditingController();
  DateTime _visitDate = DateTime.now();
  DateTime _revisitDate = DateTime.now();
  List<String> _imageUrls = [];
  @override
  void initState() {
    super.initState();
    if (widget.visit != null) {
      _doctorNameController.text = widget.visit!.doctorName;
      _resultController.text = widget.visit!.result;
      _xrayOrLabResultController.text = widget.visit!.xrayOrLabResult;
      _visitDate = widget.visit!.visitDate;
      _revisitDate = widget.visit!.revisitDate;
      _imageUrls = List.from(widget.visit!.imageUrls);
    }
  }

  Widget _buildImagePreview() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imageUrls.length,
        itemBuilder: (context, index) {
          final url = _imageUrls[index];
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Image.network(
                  url,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _imageUrls.removeAt(index);
                    });
                  },
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return ElevatedButton(
      onPressed: () async {
        final pickedImages = await ImagePicker().pickMultiImage(
          imageQuality: 50,
          maxWidth: 800,
        );
        if (pickedImages != null) {
          final urls = await _uploadImages(pickedImages.map((image) => File(image.path)).toList());
          setState(() {
            _imageUrls.addAll(urls);
          });
        }
      },
      child: text('إضافة صور', color: Colors.purple),
    );
  }

  Future<List<String>> _uploadImages(List<File> images) async {
    final storage = FirebaseStorage.instance;
    final imageUrls = <String>[];
    for (final image in images) {
      final ref = storage.ref().child('doctor_visit_images/${const Uuid().v4()}');
      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => null);
      final url = await snapshot.ref.getDownloadURL();
      imageUrls.add(url);
    }
    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text(widget.visit == null ? 'إضافة موعد زيارة الطبيب' : 'تعديل بيانات زيارة الطبيب'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _doctorNameController,
              decoration: InputDecoration(
                labelText: 'اسم الطبيب',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _resultController,
              decoration: InputDecoration(
                labelText: 'النتيجة',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _xrayOrLabResultController,
              decoration: InputDecoration(
                labelText: 'إشاعة ام نتائج معملية',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text('${_visitDate.year}-${_visitDate.month}-${_visitDate.day}'),
                text('تاريخ الزيارة:'),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _visitDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_visitDate),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _visitDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: text('اختر تاريخ الزيارة', color: Colors.purple),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text('${_revisitDate.year}-${_revisitDate.month}-${_revisitDate.day}'),
                text('موعد الاعادة:'),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _revisitDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_revisitDate),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _revisitDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: text('اختر موعد الاعادة', color: Colors.purple),
              ),
            ),
            const SizedBox(height: 20),
            _buildImagePreview(),
            _buildImagePicker(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final doctorName = _doctorNameController.text;
                final result = _resultController.text;
                final xrayOrLabResult = _xrayOrLabResultController.text;

                final visit = DoctorVisits(
                  id: widget.visit?.id ?? '',
                  doctorName: doctorName,
                  result: result,
                  xrayOrLabResult: xrayOrLabResult,
                  visitDate: _visitDate,
                  revisitDate: _revisitDate,
                  imageUrls: _imageUrls,
                );

                if (widget.visit == null) {
                  Provider.of<DoctorVisitProvider>(context, listen: false).addDoctorVisit(pref!.getString('userToken')!, visit, _imageUrls);
                } else {
                  Provider.of<DoctorVisitProvider>(context, listen: false).updateDoctorVisit(pref!.getString('userToken')!, visit, _imageUrls);
                }

                Navigator.pop(context);
              },
              child: text(widget.visit == null ? 'إضافة الزيارة' : 'تعديل الزيارة', color: Colors.purple),
            ),
          ],
        ),
      ),
    );
  }
}
