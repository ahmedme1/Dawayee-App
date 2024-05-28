// // MedicationUpdateScreen.dart

// import 'package:flutter/material.dart';
// import 'package:medication_app/medication_model.dart';
// import 'package:medication_app/medication_provider.dart';
// import 'package:provider/provider.dart';

// class MedicationUpdateScreen extends StatefulWidget {
//   final String medicationId;

//   MedicationUpdateScreen({required this.medicationId});

//   @override
//   _MedicationUpdateScreenState createState() => _MedicationUpdateScreenState();
// }

// class _MedicationUpdateScreenState extends State<MedicationUpdateScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _doseController = TextEditingController();
//   DateTime _selectedDate = DateTime.now();
//   MedicationFrequency _selectedFrequency = MedicationFrequency.every_24_hours;

//   @override
//   void initState() {
//     super.initState();
//     // Fetch the medication details and set the initial values in the form fields
//     _fetchMedicationDetails();
//   }

//   void _fetchMedicationDetails() {
//     final medicationProvider = Provider.of<MedicationProvider>(context, listen: false);
//     final medication = medicationProvider.getMedicationById(widget.medicationId);
//     _nameController.text = medication.name;
//     _doseController.text = medication.dose;
//     _selectedDate = medication.startDate;
//     _selectedFrequency = medication.frequency;
//   }

//   void _updateMedication() {
//     if (_formKey.currentState!.validate()) {
//       final medicationProvider = Provider.of<MedicationProvider>(context, listen: false);
//       medicationProvider.updateMedication(
//         widget.medicationId,
//         _nameController.text,
//         _doseController.text,
//         _selectedDate,
//         _selectedFrequency,
//       );
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Update Medication')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(labelText: 'Medication Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the medication name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _doseController,
//                 decoration: InputDecoration(labelText: 'Dose'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the dose';
//                   }
//                   return null;
//                 },
//               ),
//               // Date picker for selecting start date
//               // Dropdown for selecting frequency
//               // Update button to trigger the updateMedication method
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
