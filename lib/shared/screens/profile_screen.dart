import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

            // ⚙️ OPTION
            _item(Icons.settings, "Paramètres"),
            _item(Icons.lock, "Sécurité"),
            _item(Icons.help, "Aide"),

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