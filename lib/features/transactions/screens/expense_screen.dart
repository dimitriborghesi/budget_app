import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_popup.dart';
import '../widgets/transaction_card.dart';
import 'package:animations/animations.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

int selectedMonth = DateTime.now().month;

class _ExpenseScreenState extends State<ExpenseScreen> {
  double previousAmount = 0;
  int previousTotal = 0;
  int previousUnchecked = 0;
  int previousChecked = 0;

  bool showUncheckedOnly = false;
  int previousMonth = selectedMonth;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final expenses = provider.transactions
        .where((t) =>
            !t.isIncome && t.date.month == selectedMonth)
        .toList();

    final filtered = showUncheckedOnly
        ? expenses.where((t) => !t.isChecked).toList()
        : expenses;

    final totalCount = expenses.length;
    final unchecked = expenses.where((t) => !t.isChecked).length;
    final checked = expenses.where((t) => t.isChecked).length;

    final now = DateTime.now();

    final todayExpenses = expenses
        .where((t) =>
            t.date.day == now.day &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final yesterday = now.subtract(const Duration(days: 1));

    final yesterdayExpenses = expenses
        .where((t) =>
            t.date.day == yesterday.day &&
            t.date.month == yesterday.month &&
            t.date.year == yesterday.year)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final diff = todayExpenses - yesterdayExpenses;

    return Scaffold(
      backgroundColor: const Color(0xFF060B05),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF799C0A),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: const Color(0xFF060B05),
            builder: (_) =>
                const AddTransactionPopup(isIncome: false),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            /// 🔥 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔥 MOIS
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 12,
                      itemBuilder: (_, index) {
                        final month = index + 1;
                        final isSelected = month == selectedMonth;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              previousMonth = selectedMonth;

                              previousAmount = todayExpenses;
                              previousTotal = totalCount;
                              previousUnchecked = unchecked;
                              previousChecked = checked;

                              selectedMonth = month;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF799C0A)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _monthName(month),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 CONTEXTE
                  Row(
                    children: [
                      Text(
                        "${_monthName(selectedMonth)} • ",
                        style: const TextStyle(color: Colors.white38),
                      ),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(
                          begin: previousTotal,
                          end: totalCount,
                        ),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, _) {
                          return Text(
                            "$value transactions",
                            style: const TextStyle(color: Colors.white38),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// 🔥 STATUS
                  Row(
                    children: [
                      Text("$unchecked non pointées",
                          style: const TextStyle(color: Colors.white70)),
                      const Text(" • ", style: TextStyle(color: Colors.white38)),
                      Text("$checked validées",
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// 🔥 TODAY
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: previousAmount,
                      end: todayExpenses,
                    ),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, _) {
                      return Text(
                        "Aujourd’hui : -${value.toStringAsFixed(2)} €",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 6),

                  /// 🔥 VS HIER + FLÈCHE
                  Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: diff),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, value, _) {
                          final isGood = value <= 0;

                          return Row(
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 400),
                                builder: (context, anim, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      isGood
                                          ? (1 - anim) * 6
                                          : -(1 - anim) * 6,
                                    ),
                                    child: Icon(
                                      isGood
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      size: 14,
                                      color: isGood
                                          ? Colors.greenAccent
                                          : Colors.orange,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${value >= 0 ? "+" : ""}${value.toStringAsFixed(2)}€ vs hier",
                                style: TextStyle(
                                  color: isGood
                                      ? Colors.greenAccent
                                      : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// 🔥 FILTRE
                  Row(
                    children: [
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showUncheckedOnly = !showUncheckedOnly;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: showUncheckedOnly
                                ? const Color(0xFF799C0A)
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Non pointé",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            /// 🔥 LIST
            Expanded(
              child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 350),

                transitionBuilder:
                    (child, animation, secondaryAnimation) {
                  final monthDiff =
                      (selectedMonth - previousMonth + 12) % 12;

                  final isForward =
                      monthDiff > 0 && monthDiff <= 6;

                  final offsetAnimation = Tween<Offset>(
                    begin: isForward
                        ? const Offset(1, 0)
                        : const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ));

                  return ClipRect(
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },

                child: Container(
                  key: ValueKey(selectedMonth),
                  child: Builder(
                    builder: (_) {
                      final now = DateTime.now();

                      bool isToday(DateTime d) =>
                          d.day == now.day &&
                          d.month == now.month &&
                          d.year == now.year;

                      bool isYesterday(DateTime d) {
                        final y =
                            now.subtract(const Duration(days: 1));
                        return d.day == y.day &&
                            d.month == y.month &&
                            d.year == y.year;
                      }

                      filtered.sort(
                          (a, b) => b.date.compareTo(a.date));

                      Map<String, List> grouped = {};

                      for (var t in filtered) {
                        String key;

                        if (isToday(t.date)) {
                          key = "Aujourd’hui";
                        } else if (isYesterday(t.date)) {
                          key = "Hier";
                        } else {
                          key =
                              "${t.date.day} ${_monthName(t.date.month)}";
                        }

                        grouped.putIfAbsent(key, () => []).add(t);
                      }

                      return ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        children: grouped.entries.map((entry) {
                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 4,
                                    top: 16,
                                    bottom: 6),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              ),
                              ...entry.value.map((t) =>
                                  TransactionCard(
                                    t: t,
                                    isExpense: true,
                                  )),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _monthName(int month) {
  const months = [
    "Jan","Fév","Mar","Avr","Mai","Juin",
    "Juil","Août","Sep","Oct","Nov","Déc"
  ];
  return months[month - 1];
}