import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_popup.dart';
import '../widgets/transaction_card.dart';
import 'package:budget_app/core/utils/category_utils.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

int selectedMonth = DateTime.now().month;

class _ExpenseScreenState extends State<ExpenseScreen> {
  bool showUncheckedOnly = false;

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

    final total =
        expenses.fold<double>(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),

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

            /// 🔥 HEADER + FILTRE
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  /// MOIS
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 12,
                      itemBuilder: (_, index) {
                        final month = index + 1;
                        final isSelected =
                            month == selectedMonth;

                        return GestureDetector(
                          onTap: () {
                            setState(() =>
                                selectedMonth = month);
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.only(right: 8),
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF799C0A)
                                  : Colors.white10,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _monthName(month),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white38,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// TOTAL
                  const Text("Dépenses",
                      style:
                          TextStyle(color: Colors.white70)),

                  const SizedBox(height: 6),

                  Text(
                    "-${total.toStringAsFixed(2)} €",
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// FILTRE
                  Row(
                    children: [
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showUncheckedOnly =
                                !showUncheckedOnly;
                          });
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6),
                          decoration: BoxDecoration(
                            color: showUncheckedOnly
                                ? const Color(0xFF799C0A)
                                : Colors.white10,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Non pointé",
                            style:
                                TextStyle(color: Colors.white),
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
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final t = filtered[index];

                  return TransactionCard(
                    t: t,
                    isExpense: true,
                  );
                },
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