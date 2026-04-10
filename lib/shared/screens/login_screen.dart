import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main_screen.dart'; // ✅ FIX ICI

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  final auth = FirebaseAuth.instance;

  void login() async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
    } catch (e) {
      await auth.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Login", style: TextStyle(fontSize: 24)),

            const SizedBox(height: 20),

            TextField(
              controller: email,
              decoration: const InputDecoration(hintText: "Email"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Password"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: login,
              child: const Text("Se connecter"),
            )
          ],
        ),
      ),
    );
  }
}