import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_popup.dart';
import '../widgets/transaction_card.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() =>
      _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  bool showUncheckedOnly = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final incomes = provider.transactions
        .where((t) => t.isIncome)
        .toList();

    final filtered = showUncheckedOnly
        ? incomes.where((t) => !t.isChecked).toList()
        : incomes;

    final total =
        incomes.fold<double>(0.0, (sum, t) => sum + t.amount);

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
                const AddTransactionPopup(isIncome: true),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            /// HEADER
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text("Revenus",
                      style:
                          TextStyle(color: Colors.white70)),

                  const SizedBox(height: 6),

                  Text(
                    "+${total.toStringAsFixed(2)} €",
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

            /// LIST
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final t = filtered[index];

                  return TransactionCard(
                    t: t,
                    isExpense: false,
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