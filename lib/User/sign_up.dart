import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medication_app/Const/texts.dart';
import 'package:medication_app/User/auth_service.dart';
import 'package:medication_app/User/main_app.dart';
import 'package:medication_app/main.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _role = 'Patient';

  final AuthService _authService = AuthService();

  Future<void> _signUp() async {
    try {
      User? user = await _authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        _ageController.text.trim(),
        _notesController.text.trim(),
        _role,
      );

      if (user != null) {
        pref!.setString('userToken', user.uid);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainAppScreen()));
      } else {
        // Show error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: text('فشل تسجيل حساب جديد'),
              content: text('فشل التسجيل برجاء المحاولة مره اخرى'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: text('رجوع'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Show error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: text('فشل تسجيل حساب جديد'),
            content: text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: text('موافق'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('تسجيل حساب جديد', fontSize: 20),
        centerTitle: true,
        surfaceTintColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                text('الايميل'),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                text('الباسوورد'),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                text('الاسم'),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                text('السن'),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                text('ملاحظات'),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                text('نوع الحساب'),
              ],
            ),
            DropdownButton<String>(
              borderRadius: BorderRadius.circular(12),
              value: _role,
              onChanged: (String? newValue) {
                setState(() {
                  _role = newValue!;
                });
              },
              items: <String>['Patient', 'Follower'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _signUp,
              child: text('تسجيل', color: Colors.purple),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: text('لديك حساب بالفعل ؟ سجل دخولك الان', color: Colors.purple),
            ),
          ],
        ),
      ),
    );
  }
}
