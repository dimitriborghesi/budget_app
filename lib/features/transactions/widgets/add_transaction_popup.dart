import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../../accounts/providers/account_provider.dart';

class AddTransactionPopup extends StatefulWidget {
  final bool isIncome;

  const AddTransactionPopup({
    super.key,
    required this.isIncome,
  });

  @override
  State<AddTransactionPopup> createState() =>
      _AddTransactionPopupState();
}

class _AddTransactionPopupState
    extends State<AddTransactionPopup> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController(); // 🔥 NEW

  String selectedAccount = "";
  String selectedCategory = "";
  late bool isIncome;

  final incomeCategories = [
    {"name": "Salaire", "icon": Icons.work, "color": Colors.green},
    {"name": "Remboursement", "icon": Icons.reply, "color": Colors.blue},
    {"name": "Anniversaire", "icon": Icons.cake, "color": Colors.orange},
    {"name": "Don", "icon": Icons.volunteer_activism, "color": Colors.teal},
    {"name": "Amis", "icon": Icons.people, "color": Colors.purple},
  ];

  final expenseCategories = [
    {"name": "Courses", "icon": Icons.shopping_cart, "color": Colors.green},
    {"name": "Santé", "icon": Icons.favorite, "color": Colors.pink},
    {"name": "Loisirs", "icon": Icons.sports_esports, "color": Colors.purple},
    {"name": "Transport", "icon": Icons.directions_bus, "color": Colors.blue},
    {"name": "Restaurant", "icon": Icons.restaurant, "color": Colors.deepOrange},
    {"name": "Factures", "icon": Icons.receipt_long, "color": Colors.grey},
  ];

  @override
  void initState() {
    super.initState();

    isIncome = widget.isIncome;

    selectedCategory = isIncome
        ? incomeCategories.first["name"] as String
        : expenseCategories.first["name"] as String;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    final accounts = context.watch<AccountProvider>().accounts;

    if (accounts.isNotEmpty && selectedAccount.isEmpty) {
      selectedAccount = accounts.first.name;
    }

    final categories =
        isIncome ? incomeCategories : expenseCategories;

 return Container(
  padding: EdgeInsets.only(
    bottom: MediaQuery.of(context).viewInsets.bottom,
  ),
  decoration: const BoxDecoration(
    color: Color(0xFF1C1C1E),
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(25),
    ),
  ),
  child: SafeArea(
    top: false,
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// 🔥 BARRE DRAG
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Text(
              isIncome
                  ? "Nouveau revenu"
                  : "Nouvelle dépense",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            _input("Titre", titleController),
            _input("Montant", amountController),
            _input("Description (optionnel)", descriptionController),

            const SizedBox(height: 15),

            _accounts(accounts),

            const SizedBox(height: 20),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: SizedBox(
                key: ValueKey(isIncome),
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    final selected =
                        selectedCategory == cat["name"];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory =
                              cat["name"] as String;
                        });
                      },
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 200),
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? cat["color"] as Color
                              : const Color(0xFF2C2C2E),
                          borderRadius:
                              BorderRadius.circular(18),
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
                              style: const TextStyle(
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF799C0A),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final raw = amountController.text
                      .replaceAll(',', '.')
                      .replaceAll(' ', '');

                  final amount = double.tryParse(raw);

                  if (amount == null ||
                      titleController.text.isEmpty) {
                    return;
                  }

                  await provider.add(
                    title: titleController.text,
                    amount: amount,
                    account: selectedAccount,
                    category: selectedCategory,
                    isIncome: isIncome,
                  );

                  if (context.mounted)
                    Navigator.pop(context);
                },
                child: const Text(
                  "Ajouter",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _accounts(accounts) {
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
                  Icon(acc.icon,
                      color: Colors.white, size: 18),
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

  Widget _input(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF2C2C2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}