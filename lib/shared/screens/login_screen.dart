import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  final auth = FirebaseAuth.instance;
  final localAuth = LocalAuthentication();

  bool isLogin = true;
  bool loading = false;
  String error = "";

  /// 🔐 LOGIN / SIGNUP
  Future<void> submit() async {
  setState(() {
    loading = true;
    error = "";
  });

  try {
    if (isLogin) {
      final cred = await auth.signInWithEmailAndPassword(
  email: email.text.trim(),
  password: password.text.trim(),
);

// 🔥 REFRESH USER
await cred.user?.reload();

final updatedUser = FirebaseAuth.instance.currentUser;

if (!(updatedUser?.emailVerified ?? false)) {
  setState(() {
    error = "⚠️ Vérifie ton email avant de te connecter";
    loading = false; // 🔥 FIX ICI
  });
  return;
}

    } else {
      final cred = await auth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      await cred.user?.sendEmailVerification();

      setState(() {
        error = "📩 Email envoyé ! Vérifie ta boîte";
      });

      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  } catch (e) {
    setState(() {
      error = "Erreur : vérifie tes infos";
    });
  }

  setState(() {
    loading = false;
  });
}

  /// 🔑 RESET PASSWORD
  Future<void> resetPassword() async {
    if (email.text.isEmpty) {
      setState(() {
        error = "Entre ton email";
      });
      return;
    }

    await auth.sendPasswordResetEmail(email: email.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email envoyé 📩")),
    );
  }

  /// 🔐 FACE ID / FINGERPRINT
  Future<void> biometricLogin() async {
    final canCheck = await localAuth.canCheckBiometrics;

    if (!canCheck) {
      setState(() {
        error = "Biométrie non disponible";
      });
      return;
    }

    final didAuthenticate = await localAuth.authenticate(
      localizedReason: "Se connecter avec biométrie",
    );

    if (didAuthenticate) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                const Icon(Icons.account_balance,
                    size: 60, color: Colors.white),

                const SizedBox(height: 20),

                const Text(
                  "Budget App",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: email,
                  style: const TextStyle(color: Colors.white),
                  decoration: _input("Email"),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: password,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _input("Mot de passe"),
                ),

                const SizedBox(height: 10),

                if (error.isNotEmpty)
                  Text(error, style: const TextStyle(color: Colors.red)),

                  if (error.contains("Email envoyé"))
  ElevatedButton(
    onPressed: () async {
      await FirebaseAuth.instance.currentUser?.reload();

      final user = FirebaseAuth.instance.currentUser;

      if (user?.emailVerified ?? false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Toujours pas vérifié")),
        );
      }
    },
    child: const Text("J’ai vérifié mon email"),
  ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: _buttonStyle(),
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isLogin ? "Se connecter" : "Créer un compte"),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? "Créer un compte"
                        : "Déjà un compte ? Se connecter",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 10),

                // 🔑 RESET PASSWORD
                TextButton(
                  onPressed: resetPassword,
                  child: const Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔐 BIOMETRIC
                ElevatedButton.icon(
                  style: _buttonStyle(),
                  onPressed: biometricLogin,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text("Connexion biométrique"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎨 UI helpers
  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6C63FF),
      minimumSize: const Size(double.infinity, 50),
    );
  }
}