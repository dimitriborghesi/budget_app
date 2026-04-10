import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class EditTransactionPopup extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionPopup({super.key, required this.transaction});

  @override
  State<EditTransactionPopup> createState() =>
      _EditTransactionPopupState();
}

class _EditTransactionPopupState
    extends State<EditTransactionPopup> {
  late TextEditingController titleController;
  late TextEditingController amountController;

  String selectedAccount = "Principal";
  String selectedCategory = "Courses";

  final categories = [
    {"name": "Santé", "icon": Icons.favorite, "color": Colors.pink},
    {"name": "Loisirs", "icon": Icons.sports_esports, "color": Colors.purple},
    {"name": "Travaux", "icon": Icons.home_repair_service, "color": Colors.orange},
    {"name": "Cadeaux", "icon": Icons.card_giftcard, "color": Colors.red},
    {"name": "Courses", "icon": Icons.shopping_cart, "color": Colors.green},
    {"name": "Transport", "icon": Icons.directions_bus, "color": Colors.blue},
    {"name": "Voiture", "icon": Icons.directions_car, "color": Colors.indigo},
    {"name": "Assurances", "icon": Icons.security, "color": Colors.teal},
    {"name": "Restaurant", "icon": Icons.restaurant, "color": Colors.deepOrange},
    {"name": "Voyage", "icon": Icons.flight, "color": Colors.lightBlue},
    {"name": "Paypal", "icon": Icons.account_balance_wallet, "color": Colors.blueAccent},
    {"name": "Amazon", "icon": Icons.shopping_bag, "color": Colors.orangeAccent},
    {"name": "Amende", "icon": Icons.warning, "color": Colors.redAccent},
    {"name": "Shopping", "icon": Icons.store, "color": Colors.pinkAccent},
    {"name": "Factures", "icon": Icons.receipt_long, "color": Colors.grey},
  ];

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.transaction.title);

    amountController = TextEditingController(
        text: widget.transaction.amount.toString());

    selectedCategory = widget.transaction.category;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// BAR
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            /// TITLE
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Titre",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 10),

            /// AMOUNT
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Montant",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 CATEGORIES
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory == cat["name"];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat["name"] as String;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat["color"] as Color
                            : const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            cat["icon"] as IconData,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat["name"] as String,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final updated = TransactionModel(
  id: widget.transaction.id,
  title: titleController.text,
  amount: double.tryParse(
          amountController.text.replaceAll(',', '.')) ??
      0,
  isIncome: widget.transaction.isIncome,
  category: selectedCategory,
  account: widget.transaction.account,
  date: widget.transaction.date,
  userId: widget.transaction.userId,
);

                  Provider.of<TransactionProvider>(context, listen: false)
                      .update(updated);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Transaction modifiée"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B61FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Modifier"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}