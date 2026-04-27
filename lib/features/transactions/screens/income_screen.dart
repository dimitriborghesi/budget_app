import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IncomeScreen(),
    );
  }
}

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF22C55E),
          onPressed: () {},
          child: const Icon(Icons.add, size: 28),
        ),
      ),

      bottomNavigationBar: _bottomNav(),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            /// HEADER
            const Center(
              child: Text(
                "Revenus",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _selector(),
            const SizedBox(height: 12),
            _dateRange(),
            const SizedBox(height: 16),
            _summary(),
            const SizedBox(height: 16),
            _donut(),
            const SizedBox(height: 16),
            _transactions(),
          ],
        ),
      ),
    );
  }

  /// SELECTOR
  Widget _selector() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _card(),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18),
          const SizedBox(width: 10),
          const Text("Avril 2024",
              style: TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text("Mois",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// DATE RANGE
  Widget _dateRange() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _card(),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Avril 2024",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text("01 Avr – 30 Avr 2024",
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  /// SUMMARY CARD
Widget _summary() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF1B4332),
          Color(0xFF2D6A4E),
          Color(0xFF52B788),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2D6A4E).withOpacity(0.35),
          blurRadius: 20,
          offset: const Offset(0, 10),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Total revenus du mois",
            style: TextStyle(color: Colors.white70)),

        const SizedBox(height: 8),

        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "+1 800",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: " €",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const LinearProgressIndicator(
            value: 0.9,
            minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),

        const SizedBox(height: 10),

        const Text("Objectif : 2 000 €",
            style: TextStyle(color: Colors.white70)),
      ],
    ),
  );
}

  /// DONUT
  Widget _donut() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text("Répartition des Revenus",
              style: TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 16),

          Row(
            children: [

              SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
PieChart(
  PieChartData(
    sectionsSpace: 3,
    centerSpaceRadius: 55,
    sections: [
      PieChartSectionData(
        value: 75,
        color: const Color(0xFF66BB6A),
        radius: 22,
        showTitle: false,
      ),
      PieChartSectionData(
        value: 25,
        color: const Color(0xFF42A5F5),
        radius: 22,
        showTitle: false,
      ),
    ],
  ),
),

const Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text("2 500 €",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        )),
    SizedBox(height: 2),
    Text("+9%",
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w600,
        )),
  ],
)
                  ],
                ),
              ),

              const SizedBox(width: 20),

              const Expanded(
                child: Column(
                  children: [
                    _LegendItem(
                        color: Color(0xFF66BB6A),
                        title: "Salaire",
                        amount: "+2 000 €"),
                    _LegendItem(
                        color: Color(0xFF42A5F5),
                        title: "Auto",
                        amount: "-500 €"),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Voir tout"),
              Text("+2 300 €",
                  style: TextStyle(color: Colors.green)),
            ],
          )
        ],
      ),
    );
  }

  /// TRANSACTIONS
  Widget _transactions() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _card(),
      child: Column(
        children: const [

          Align(
            alignment: Alignment.centerLeft,
            child: Text("Derniers Revenus",
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),

          SizedBox(height: 12),

          _TransactionItem(
              title: "Salaire",
              subtitle: "Virement",
              amount: "+2 000 €"),

          _TransactionItem(
              title: "Revenu Auto",
              subtitle: "Paypal",
              amount: "+500 €"),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Revenus"),
        BottomNavigationBarItem(icon: Icon(Icons.trending_down), label: "Dépenses"),
        BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: "Auto"),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "Stats"),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: "Comptes"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
      ],
    );
  }

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 12,
          offset: const Offset(0, 6),
        )
      ],
    );
  }
}

/// LEGEND
class _LegendItem extends StatelessWidget {
  final Color color;
  final String title;
  final String amount;

  const _LegendItem({
    required this.color,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
          Text(amount),
        ],
      ),
    );
  }
}

/// TRANSACTION ITEM
class _TransactionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;

  const _TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE8F5E9),
        child: Icon(Icons.work, color: Color(0xFF22C55E)),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(amount,
          style: const TextStyle(
              color: Color(0xFF22C55E),
              fontWeight: FontWeight.bold)),
    );
  }
}