import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/main_screen.dart';
import '../../shared/screens/login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool loading = true;
  bool authenticated = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;

    // ❌ pas connecté → login
    if (user == null) {
      setState(() {
        loading = false;
        authenticated = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final useBio = prefs.getBool("biometric") ?? false;

    // 🔥 PAS de biométrie → LOGIN OBLIGATOIRE
    if (!useBio) {
      setState(() {
        loading = false;
        authenticated = false;
      });
      return;
    }

    try {
      final localAuth = LocalAuthentication();

      final didAuth = await localAuth.authenticate(
        localizedReason: "Déverrouille ton app 🔐",
      );

      setState(() {
        loading = false;
        authenticated = didAuth;
      });
    } catch (e) {
      setState(() {
        loading = false;
        authenticated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF060B05),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authenticated) {
      return const MainScreen();
    } else {
      return const LoginScreen();
    }
  }
}