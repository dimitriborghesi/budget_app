import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 60),

            const Text(
              "💎 Premium",
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            _feature("Connexion bancaire automatique"),
            _feature("Synchronisation en temps réel"),
            _feature("Catégorisation intelligente"),
            _feature("Statistiques avancées"),
            _feature("Aucune pub"),

            const Spacer(),

            const Text(
              "1,99€ / mois",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("💳 Paiement simulé"),
                  ),
                );
              },
              child: const Text("Activer Premium"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _feature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}