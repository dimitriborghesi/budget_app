import 'package:budget_app/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'premium_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> connectBank() async {
    try {
      final res =
          await http.get(Uri.parse("http://10.0.2.2:3000/link"));

      final data = jsonDecode(res.body);
      final url = data["url"];

      if (url != null) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      debugPrint("Erreur connexion banque: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 👤 AVATAR
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF6C63FF),
              child: Icon(Icons.person, size: 40),
            ),

            const SizedBox(height: 20),

            // 📧 EMAIL
            Text(
              user?.email ?? "Utilisateur",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            // ⚙️ OPTIONS
            _item(Icons.settings, "Paramètres"),
            _item(Icons.lock, "Sécurité"),
            _item(Icons.help, "Aide"),

            const SizedBox(height: 20),

            // 🏦 STATUT BANQUE
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.account_balance, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  "Banque connectable",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 🔌 CONNECT BANK
            ElevatedButton(
              onPressed: connectBank,
              child: const Text("🏦 Connecter ma banque"),
            ),

            const SizedBox(height: 10),

            // 🔄 SYNC
            ElevatedButton(
              onPressed: () async {
                await Provider.of<TransactionProvider>(
                        context,
                        listen: false)
                    .syncBank();
              },
              child: const Text("🔄 Sync banque"),
            ),

            const SizedBox(height: 10),

            // 💎 PREMIUM
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PremiumScreen(),
                  ),
                );
              },
              child: const Text("💎 Premium"),
            ),

            const Spacer(),

            // 🔐 LOGOUT
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text("Se déconnecter"),
            )
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}