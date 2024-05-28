import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medication_app/Const/texts.dart';
import 'package:medication_app/main.dart';
import 'package:provider/provider.dart';
import 'medication_provider.dart';
import 'medication_model.dart';

class AddMedicationScreen extends StatefulWidget {
  final Medications? medication;

  AddMedicationScreen({this.medication});

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _dose;
  late int _pieces;
  late DateTime _startDate;
  late String _frequency;
  late String _imageUrl;
  XFile? pickedFile = XFile('');

  Future<void> _getImage() async {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageUrl = pickedFile!.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _name = widget.medication!.name;
      _dose = widget.medication!.dose;
      _pieces = widget.medication!.pieces;
      _startDate = widget.medication!.startDate;
      _frequency = widget.medication!.frequency;
      _imageUrl = widget.medication!.imageUrl;
    } else {
      _name = '';
      _dose = '';
      _pieces = 0;
      _startDate = DateTime.now();
      _frequency = '24 hours';
      _imageUrl = '';
    }
  }

  void _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDate),
      );
      if (pickedTime != null) {
        setState(() {
          _startDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<String> uploadImage(XFile imageFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = storage.ref().child('images/$fileName');
      UploadTask uploadTask = reference.putFile(File(imageFile.path));
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String imageUrl = _imageUrl != '' && !_imageUrl.contains('data') ? '' : await uploadImage(pickedFile!);
      final newMedication = Medications(
        id: widget.medication?.id ?? DateTime.now().toString(),
        name: _name,
        dose: _dose,
        imageUrl: _imageUrl != '' && !_imageUrl.contains('data')
            ? widget.medication!.imageUrl
            : _imageUrl == ''
                ? ''
                : imageUrl,
        pieces: _pieces,
        startDate: _startDate,
        frequency: _frequency,
      );
      if (widget.medication != null) {
        Provider.of<MedicationProvider>(context, listen: false).updateMedication(pref!.getString('userToken')!, newMedication);
      } else {
        Provider.of<MedicationProvider>(context, listen: false).addMedication(newMedication, pref!.getString('userToken')!);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text(widget.medication == null ? 'إضافة جرعة دواء' : 'تعديل جرعة دواء', fontSize: 20),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'اسم الدواء',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'برجاء ادخال اسم الدواء';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                initialValue: _dose,
                decoration: InputDecoration(
                  labelText: 'تركيز الدواء',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'برجاء ادخال تركيز الدواء';
                  }
                  return null;
                },
                onSaved: (value) {
                  _dose = value!;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                initialValue: _pieces.toString(),
                decoration: InputDecoration(
                  labelText: 'عدد الحبوب في الدواء',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'برجاء ادخال عدد الحبوب في الدواء';
                  }
                  return null;
                },
                onSaved: (value) {
                  _pieces = int.parse(value!);
                },
              ),
              const SizedBox(height: 15),
              ListTile(
                title: text("تاريخ بداية جرعة الدواء"),
                subtitle: text("${_startDate.toLocal()}".split(' ')[0] + ' ' + "${_startDate.hour}:${_startDate.minute}"),
                trailing: const Icon(
                  Icons.calendar_today,
                  color: Colors.purple,
                ),
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _frequency,
                items: [
                  DropdownMenuItem(child: text('كل 4 ساعات'), value: '4 hours'),
                  DropdownMenuItem(child: text('كل 8 ساعات'), value: '8 hours'),
                  DropdownMenuItem(child: text('كل 12 ساعة'), value: '12 hours'),
                  DropdownMenuItem(child: text('كل 24 ساعة'), value: '24 hours'),
                ],
                decoration: InputDecoration(
                  labelText: 'التكرار',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onChanged: (value) {
                  setState(() {
                    _frequency = value!;
                  });
                },
                onSaved: (value) {
                  _frequency = value!;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _getImage,
                child: text('ارفق صورة الدواء'),
              ),
              const SizedBox(height: 10),
              _imageUrl != null && _imageUrl != '' && !_imageUrl.contains('data')
                  ? SizedBox(width: 100, height: 100, child: Image.network(_imageUrl))
                  : _imageUrl == ''
                      ? Container()
                      : SizedBox(width: 100, height: 100, child: Image.file(File(_imageUrl))),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: text('إضافة الدواء', color: Colors.purple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
