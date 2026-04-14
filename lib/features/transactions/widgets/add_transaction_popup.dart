import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/category_provider.dart';
import '../../categories/create_category_screen.dart';
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
  final descriptionController = TextEditingController();

  String selectedAccount = "";
  String selectedCategory = "";
  late bool isIncome;

  @override
  void initState() {
    super.initState();
    isIncome = widget.isIncome;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    final accounts = context.watch<AccountProvider>().accounts;
    final categories =
        context.watch<CategoryProvider>().getByType(isIncome);

    if (accounts.isNotEmpty && selectedAccount.isEmpty) {
      selectedAccount = accounts.first.name;
    }

    if (categories.isNotEmpty && selectedCategory.isEmpty) {
      selectedCategory = categories.first.name;
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

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
                      color: Colors.white, fontSize: 18),
                ),

                const SizedBox(height: 20),

                _input("Titre", titleController),
                _input("Montant", amountController),
                _input("Description", descriptionController),

                const SizedBox(height: 15),

                _accounts(accounts),

                const SizedBox(height: 20),

                SizedBox(
  height: 70,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: categories.length + 1, // 🔥 +1 IMPORTANT
    separatorBuilder: (_, __) => const SizedBox(width: 10),

    itemBuilder: (_, i) {

      /// 🔥 BOUTON AJOUT (dernier item)
      if (i == categories.length) {
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CreateCategoryScreen(isIncome: isIncome),
              ),
            );
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 6),
                Text("Ajouter",
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        );
      }

      /// 🔥 CATEGORIES
      final cat = categories[i];
      final selected = selectedCategory == cat.name;

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = cat.name;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? cat.color
                : const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(cat.icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(cat.name,
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    },
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
                          titleController.text.isEmpty) return;

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
                    child: const Text("Ajouter",
                        style: TextStyle(color: Colors.white)),
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
        separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final acc = accounts[i];
          final selected = selectedAccount == acc.name;

          return GestureDetector(
            onTap: () =>
                setState(() => selectedAccount = acc.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14),
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
                      style: const TextStyle(
                          color: Colors.white)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _input(String hint, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: Colors.grey),
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