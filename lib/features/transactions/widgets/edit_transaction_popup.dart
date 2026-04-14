import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../../accounts/providers/account_provider.dart';

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

  String selectedAccount = "";
  String selectedCategory = "";

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
    selectedAccount = widget.transaction.account;
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;

    if (accounts.isNotEmpty &&
        !accounts.any((a) => a.name == selectedAccount)) {
      selectedAccount = accounts.first.name;
    }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _bar(),

            _input(titleController, "Titre"),
            _input(amountController, "Montant"),

            const SizedBox(height: 20),

            /// 💳 ACCOUNTS
            _accountSelector(accounts),

            const SizedBox(height: 20),

            /// 🔥 CATEGORIES
            _categorySelector(),

            const SizedBox(height: 30),

            _button(context),
          ],
        ),
      ),
    );
  }

  Widget _bar() => Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(10),
        ),
      );

  Widget _input(TextEditingController c, String hint) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
      );

  Widget _accountSelector(accounts) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final acc = accounts[i];
          final selected = selectedAccount == acc.name;

          return GestureDetector(
            onTap: () => setState(() => selectedAccount = acc.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected
                    ? Color(acc.color)
                    : const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(acc.icon, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(acc.name,
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _categorySelector() {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final selected = selectedCategory == cat["name"];

          return GestureDetector(
            onTap: () =>
                setState(() => selectedCategory = cat["name"] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected
                    ? cat["color"] as Color
                    : const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(cat["icon"] as IconData,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(cat["name"] as String,
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _button(BuildContext context) {
    return SizedBox(
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
            account: selectedAccount, // 🔥 FIX
            date: widget.transaction.date,
            userId: widget.transaction.userId,
          );

          context.read<TransactionProvider>().update(updated);

          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Transaction modifiée")),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B61FF),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text("Modifier"),
      ),
    );
  }
}