import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medication_app/User/sign_up.dart';
import 'package:medication_app/Const/texts.dart';
import 'package:medication_app/User/main_app.dart';
import 'package:medication_app/main.dart';

import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // Show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: text('حدث خطأ'),
            content: text('برجاء ادخال كل البيانات'),
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
      return;
    }

    try {
      User? user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        pref!.setString('userToken', user.uid);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainAppScreen()),
        );
      } else {
        // Show error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: text('حدث خطأ '),
              content: text('حدث خطأ اثناء تسجيل الدخول , اعد المحاولة مرة اخرى'),
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
            title: text('خطأ اثناء تسجيل الدخول'),
            content: text(e.toString()),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text('تسجيل الدخول', fontSize: 20),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                text('الإيميل'),
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
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _login,
              child: text('تسجيل الدخول'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: text('ليس لديك حساب ؟ سجل الان', color: Colors.purple),
            ),
          ],
        ),
      ),
    );
  }
}
