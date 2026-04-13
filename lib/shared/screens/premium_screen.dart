import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B05),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔙 BACK
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),

              const SizedBox(height: 20),

              /// 💎 TITLE
              const Text(
                "Passe en Premium",
                style: TextStyle(
                  color: Color(0xFFE7EAE7),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Connecte ta banque et automatise ton budget",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              /// 🔥 FEATURES
              _feature("🔗", "Connexion bancaire automatique"),
              _feature("🧠", "Catégorisation intelligente"),
              _feature("📊", "Statistiques avancées"),
              _feature("🔔", "Notifications en temps réel"),

              const Spacer(),

              /// 💰 PRICE
              const Text(
                "1,99€ / mois",
                style: TextStyle(
                  color: Color(0xFFE7EAE7),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                "Sans engagement",
                style: TextStyle(color: Colors.white54),
              ),

              const SizedBox(height: 20),

              /// 🚀 CTA
              Container(
                width: double.infinity,
                height: 60,
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
                  onPressed: () {
                    // TODO paiement
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text(
                    "🚀 Activer Premium",
                    style: TextStyle(
                      color: Color(0xFFE7EAE7),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// 🧠 SOCIAL PROOF
              const Center(
                child: Text(
                  "Déjà +500 utilisateurs satisfaits",
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feature(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFE7EAE7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}