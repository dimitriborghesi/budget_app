import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import '../main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool rememberMe = false;
  bool useBiometric = false;

  /// 🔐 LOGIN / SIGNUP
  Future<void> submit() async {
  setState(() {
    loading = true;
    error = "";
  });

  if (rememberMe) {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("email", email.text.trim());
}

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
void initState() {
  super.initState();
  loadSavedData();
}

Future<void> loadSavedData() async {
  final prefs = await SharedPreferences.getInstance();

  final savedEmail = prefs.getString("email");

  if (savedEmail != null) {
    setState(() {
      email.text = savedEmail;
      rememberMe = true;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B05),
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

Row(
  children: [
    Checkbox(
      value: rememberMe,
      activeColor: const Color(0xFF799C0A),
      onChanged: (value) {
        setState(() {
          rememberMe = value ?? false;
        });
      },
    ),
    const Text(
      "Se souvenir de moi",
      style: TextStyle(color: Colors.white70),
    ),
  ],
),

const SizedBox(height: 5),

Row(
  children: [
    Checkbox(
      value: useBiometric,
      activeColor: const Color(0xFF799C0A),
      onChanged: (value) async {
        setState(() {
          useBiometric = value ?? false;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("biometric", useBiometric);
      },
    ),
    const Text(
      "Activer Face ID / empreinte",
      style: TextStyle(color: Colors.white70),
    ),
  ],
),

                const SizedBox(height: 10),

                if (error.isNotEmpty)
                  Text(
  error,
  style: const TextStyle(
    color: Colors.orangeAccent,
    fontWeight: FontWeight.w500,
  ),
),

                  if (error.contains("Email envoyé"))
  ElevatedButton(
    onPressed: () async {
      await FirebaseAuth.instance.currentUser?.reload();

      final user = FirebaseAuth.instance.currentUser;

if (user != null) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const MainScreen()),
  );
} else {
  setState(() {
    error = "Connecte-toi d'abord";
  });
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF060B05),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔥 petit handle (style iOS)
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Créer un compte",
                  style: TextStyle(
                    color: Color(0xFFE7EAE7),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// 📧 EMAIL
                TextField(
                  controller: email,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF0D140A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// 🔑 PASSWORD
                TextField(
                  controller: password,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Mot de passe",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF0D140A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 💎 BOUTON CREATE
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF799C0A),
                        Color(0xFF5F7F08),
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      setState(() {
                        isLogin = false;
                      });

                      await submit(); // 🔥 réutilise ton code
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      "Créer un compte",
                      style: TextStyle(
                        color: Color(0xFFE7EAE7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  },
  child: const Text(
    "Créer un compte",
    style: TextStyle(color: Colors.white70),
  ),
),

                // 🔑 RESET PASSWORD
                TextButton(
                  onPressed: resetPassword,
                  child: const Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),

                const SizedBox(height: 20),
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
    hintStyle: const TextStyle(color: Colors.white38),
    filled: true,
    fillColor: const Color(0xFF0D140A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}

  ButtonStyle _buttonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF799C0A),
    foregroundColor: const Color(0xFFE7EAE7),
    minimumSize: const Size(double.infinity, 55),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  );
}
}