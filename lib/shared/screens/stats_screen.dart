import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../features/transactions/providers/transaction_provider.dart';
import '../../features/transactions/screens/expense_screen.dart';
import '../../features/transactions/widgets/transaction_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final all = context.watch<TransactionProvider>().transactions;

    /// 🔥 FILTRE MOIS
    final tx = all.where((t) =>
        t.date.month == selectedMonth.month &&
        t.date.year == selectedMonth.year).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    double income = 0;
    double expense = 0;

    for (var t in tx) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    final balance = income - expense;

    /// 📈 COURBE
    List<FlSpot> spots = [];
    double running = 0;

    for (int i = 0; i < tx.length; i++) {
      final t = tx[i];
      running += t.isIncome ? t.amount : -t.amount;
      spots.add(FlSpot(i.toDouble(), running));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔥 HEADER
              const Text("Statistics",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),

              const SizedBox(height: 20),

              /// 📅 FILTRE PROPRE
              _monthSelector(),

              const SizedBox(height: 25),

              /// 💰 CARD PREMIUM
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF799C0A),
                      Color(0xFF3A5F0B),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const Text("Balance",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    Text(
                      "${balance.toStringAsFixed(2)} €",
                      style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// 📈 COURBE
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: const Color(0xFF799C0A),
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// 💸 CARDS
              Row(
                children: [
                  Expanded(
                    child: _card("Revenus", income, Colors.green),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _card("Dépenses", expense, Colors.red),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// 🧾 HISTORIQUE (STYLE BANQUE 🔥)
              const Text("Historique",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              ..._buildHistory(tx),
            ],
          ),
        ),
      ),
    );
  }

  /// 📅 SELECTEUR CLEAN
  Widget _monthSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (_, i) {
          final date =
              DateTime.now().subtract(Duration(days: 30 * i));

          final selected =
              date.month == selectedMonth.month &&
                  date.year == selectedMonth.year;

          return GestureDetector(
            onTap: () => setState(() => selectedMonth = date),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: selected
                    ? const Color(0xFF799C0A)
                    : const Color(0xFF1A1A1A),
              ),
              child: Text(
                "${date.month}/${date.year}",
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🧾 HISTORIQUE GROUPÉ PAR DATE
  List<Widget> _buildHistory(List tx) {
  final Map<String, List<dynamic>> grouped = {};

  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));

  for (var t in tx) {
    final d = t.date;

    String key;

    if (d.day == now.day &&
        d.month == now.month &&
        d.year == now.year) {
      key = "Aujourd’hui";
    } else if (d.day == yesterday.day &&
        d.month == yesterday.month &&
        d.year == yesterday.year) {
      key = "Hier";
    } else if (now.difference(d).inDays < 7) {
      key = "Cette semaine";
    } else {
      key = "${d.day}/${d.month}/${d.year}";
    }

    grouped.putIfAbsent(key, () => []).add(t);
  }

  return grouped.entries.map((entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),

        Text(entry.key,
            style: const TextStyle(color: Colors.white54)),

        const SizedBox(height: 5),

        ...entry.value.map((t) {
          return TransactionCard(
  t: t,
  isExpense: !t.isIncome,
);
        }),
      ],
    );
  }).toList();
}
  Widget _card(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFF1A1A1A),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color)),
          const SizedBox(height: 5),
          Text(
            "${amount.toStringAsFixed(2)}€",
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
class _StatsCard extends StatefulWidget {
  final dynamic t;

  const _StatsCard({required this.t});

  @override
  State<_StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<_StatsCard>
    with SingleTickerProviderStateMixin {

  double offset = 0;
  final double maxLeft = -150;
  final double maxRight = 90;

  late AnimationController _controller;
  late Animation<double> _animation;

  bool isAnimating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  void animateTo(double target) {
    isAnimating = true;

    _animation = Tween(begin: offset, end: target).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutExpo,
      ),
    )..addListener(() {
        setState(() => offset = _animation.value);
      });

    _controller.forward(from: 0).whenComplete(() {
      isAnimating = false;
    });
  }

  void reset() {
    animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<TransactionProvider>(context, listen: false);

    double progressRight =
        (offset / maxRight).clamp(0.0, 1.0);

    double progressLeft =
        (offset / maxLeft).clamp(0.0, 1.0).abs();

    return GestureDetector(
      onTap: reset,

      onHorizontalDragUpdate: (details) {
        if (isAnimating) return;

        setState(() {
          offset += details.delta.dx;
          offset = offset.clamp(maxLeft, maxRight);
        });
      },

      onHorizontalDragEnd: (details) async {
        final velocity = details.velocity.pixelsPerSecond.dx;

        /// 👉 CHECK (comme dépenses)
        if (offset > maxRight * 0.5 || velocity > 900) {
          HapticFeedback.lightImpact();

          widget.t.isChecked = !widget.t.isChecked;
          await provider.update(widget.t);

          reset();
        }

        /// 👉 DELETE
        else if (offset < maxLeft * 0.5 || velocity < -900) {
          provider.delete(widget.t);
        }

        else {
          reset();
        }
      },

      child: Transform.translate(
        offset: Offset(offset, 0),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xFF1A1A1A),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [

              /// LEFT
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(widget.t.title,
                      style:
                          const TextStyle(color: Colors.white)),
                  Text(widget.t.category,
                      style: const TextStyle(
                          color: Colors.white38)),
                ],
              ),

              /// RIGHT (MONTANT STYLE DEPENSES 🔥)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),

                  gradient: widget.t.isChecked
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF1B3C10),
                            Color(0xFF3C460A),
                          ],
                        )
                      : const LinearGradient(
                          colors: [
                            Color(0xFF3A0F0F),
                            Color(0xFF1C0707),
                          ],
                        ),
                ),
                child: Text(
                  "${widget.t.isIncome ? "+" : "-"}${widget.t.amount.toStringAsFixed(2)}€",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}