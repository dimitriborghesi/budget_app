import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final LocalAuthentication auth = LocalAuthentication();

  bool biometric = false;
  bool notifications = true;

  String language = "FR";
  String currency = "€";

  // 🔐 DEMANDE BIOMETRIE
  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: "Confirme ton identité",
        options: const AuthenticationOptions(
          biometricOnly: false,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // 🔐 TOGGLE BIOMETRIE AVEC AUTH
  void toggleBiometric(bool value) async {
    final ok = await authenticate();

    if (!ok) return;

    setState(() {
      biometric = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          biometric
              ? "🔒 Biométrie activée"
              : "❌ Biométrie désactivée",
        ),
      ),
    );
  }

  // 🌍 CHANGER LANGUE
  void changeLanguage() {
    setState(() {
      language = language == "FR" ? "EN" : "FR";
    });
  }

  // 💰 CHANGER DEVISE
  void changeCurrency() {
    setState(() {
      currency = currency == "€" ? "\$" : "€";
    });
  }

  // 🔒 RESET PASSWORD
  void resetPassword() async {
    if (user?.email == null) return;

    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: user!.email!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("📩 Email de réinitialisation envoyé"),
      ),
    );
  }

  // 🔓 LOGOUT
  void logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // 🧱 CARD
  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }

  // 📄 ITEM
  Widget _item(IconData icon, String title,
      {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color),
      ),
      trailing: trailing ??
Icon(
  Icons.arrow_forward_ios,
  color: Theme.of(context).iconTheme.color,
  size: 16,
),      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
  "Profil",
  style: TextStyle(
    color: Theme.of(context).textTheme.bodyMedium!.color,
  ),
),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                const SizedBox(height: 20),

                // 👤 USER CARD
                _card(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Color(0xFF799C0A),
                      child: Icon(
  Icons.person,
  size: 35,
  color: Colors.white, // 👈 OK ici (cas spécial)
),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.email ?? "",
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ⚙️ SETTINGS
                _card(
                  children: [
                    _item(
  Icons.dark_mode,
  "Mode sombre",
  trailing: Switch(
    value: context.watch<ThemeProvider>().isDark,
    activeColor: const Color(0xFF799C0A),
    onChanged: (value) {
      context.read<ThemeProvider>().toggleTheme(value);
    },
  ),
),
                    _item(
                      Icons.lock,
                      "Biométrie",
                      trailing: Switch(
                        value: biometric,
                        activeColor: const Color(0xFF799C0A),
                        onChanged: toggleBiometric,
                      ),
                    ),
                    _item(
                      Icons.notifications,
                      "Notifications",
                      trailing: Switch(
                        value: notifications,
                        activeColor: const Color(0xFF799C0A),
                        onChanged: (v) {
                          setState(() {
                            notifications = v;
                          });
                        },
                      ),
                    ),
                    _item(
                      Icons.language,
                      "Langue ($language)",
                      onTap: changeLanguage,
                    ),
                    _item(
                      Icons.euro,
                      "Devise ($currency)",
                      onTap: changeCurrency,
                    ),
                    _item(
                      Icons.picture_as_pdf,
                      "Exporter PDF",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("📄 Export PDF à venir"),
                          ),
                        );
                      },
                    ),
                    _item(
                      Icons.lock_reset,
                      "Changer mot de passe",
                      onTap: resetPassword,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🏦 BANK
                _card(
                  children: [
                    _item(
                      Icons.account_balance,
                      "Connecter banque",
                      onTap: () {},
                    ),
                    _item(
                      Icons.sync,
                      "Synchroniser",
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔴 LOGOUT
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Se déconnecter"),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}