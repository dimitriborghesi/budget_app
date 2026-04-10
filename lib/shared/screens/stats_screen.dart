import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../features/transactions/providers/transaction_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final allTransactions =
        Provider.of<TransactionProvider>(context).transactions;

    /// 📅 FILTRE MOIS
    final transactions = allTransactions.where((t) {
      return t.date.month == selectedMonth.month &&
          t.date.year == selectedMonth.year;
    }).toList();

    double totalIncome = 0;
    double totalExpense = 0;

    final Map<String, double> categoryTotals = {};
    final List<double> dailyBalance = List.filled(30, 0);

    double runningBalance = 0;

    for (var t in transactions) {
      if (t.isIncome) {
        totalIncome += t.amount;
        runningBalance += t.amount;
      } else {
        totalExpense += t.amount;
        runningBalance -= t.amount;

        categoryTotals[t.category] =
            (categoryTotals[t.category] ?? 0) + t.amount;
      }

      final dayIndex = t.date.day - 1;
      if (dayIndex >= 0 && dayIndex < 30) {
        dailyBalance[dayIndex] = runningBalance;
      }
    }

    final balance = totalIncome - totalExpense;
    final total = totalExpense == 0 ? 1 : totalExpense;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Stats"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 📅 SELECTEUR MOIS
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(6, (i) {
                  final date =
                      DateTime.now().subtract(Duration(days: 30 * i));

                  final isSelected =
                      date.month == selectedMonth.month &&
                          date.year == selectedMonth.year;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMonth = date;
                      });
                    },
                    child: Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFF1A1A1A),
                      ),
                      child: Text(
                        "${date.month}/${date.year}",
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            /// 💰 BALANCE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                ),
              ),
              child: Column(
                children: [
                  const Text("Balance totale",
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: balance),
                    duration: const Duration(milliseconds: 800),
                    builder: (_, value, __) {
                      return Text(
                        "${value.toStringAsFixed(2)} €",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            
            /// 🍩 DONUT
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
                  sections: categoryTotals.entries.map((e) {
                    final percent = e.value / total;

                    return PieChartSectionData(
                      value: e.value,
                      title:
                          "${(percent * 100).toStringAsFixed(0)}%",
                      color: _randomColor(e.key),
                      radius: 50,
                      titleStyle: const TextStyle(
                          color: Colors.white, fontSize: 12),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📈 COURBE EVOLUTION
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(30, (i) {
                        return FlSpot(i.toDouble(),
                            dailyBalance[i]);
                      }),
                      isCurved: true,
                      color: Colors.purpleAccent,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📊 CATEGORIES
            Expanded(
              child: ListView(
                children: categoryTotals.entries.map((e) {
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xFF1A1A1A),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _randomColor(e.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(e.key,
                                style: const TextStyle(
                                    color: Colors.white)),
                          ],
                        ),
                        Text(
                          "${e.value.toStringAsFixed(2)}€",
                          style: const TextStyle(
                              color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            /// 💵 RESUME
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _card("Revenus", totalIncome, Colors.green),
                _card("Dépenses", totalExpense, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 COULEURS
  Color _randomColor(String key) {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.teal,
    ];
    return colors[key.hashCode % colors.length];
  }

  Widget _card(String title, double amount, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: color.withOpacity(0.15),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color)),
          const SizedBox(height: 5),
          Text(
            "${amount.toStringAsFixed(2)}€",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}