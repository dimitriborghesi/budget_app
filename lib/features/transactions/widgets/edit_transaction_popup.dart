import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/category_provider.dart';
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
  late TextEditingController descriptionController;

  String selectedAccount = "";
  String selectedCategory = "";
  late bool isIncome;

  @override
  void initState() {
    super.initState();

    final t = widget.transaction;

    titleController = TextEditingController(text: t.title);
    amountController = TextEditingController(text: t.amount.toString());
    descriptionController = TextEditingController();

    selectedAccount = t.account;
    selectedCategory = t.category;
    isIncome = t.isIncome;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    final accounts = context.watch<AccountProvider>().accounts;

    if (accounts.isNotEmpty && selectedAccount.isEmpty) {
      selectedAccount = accounts.first.name;
    }

    final categories =
    context.watch<CategoryProvider>().getByType(isIncome);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
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

                  const Text(
                    "Modifier transaction",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _input("Titre", titleController),
                  _input("Montant", amountController),
                  _input("Description", descriptionController),

                  const SizedBox(height: 15),

                  _accounts(accounts),

                  const SizedBox(height: 20),

                  /// CATEGORIES
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final cat = categories[i];
                        final selected =
                            selectedCategory == cat.name;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory =
                                  cat.name;
                            });
                          },
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? cat.color
                                  : const Color(0xFF2C2C2E),
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  cat.icon,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat.name,
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

                  const SizedBox(height: 25),

                  /// BUTTON
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

                        final updated = TransactionModel(
                          id: widget.transaction.id,
                          title: titleController.text,
                          amount: amount,
                          isIncome: isIncome,
                          category: selectedCategory,
                          account: selectedAccount,
                          date: widget.transaction.date,
                          userId: widget.transaction.userId,
                        );

                        await provider.update(updated);

                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        "Modifier",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
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
            onTap: () =>
                setState(() => selectedAccount = acc.name),
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
                      style:
                          const TextStyle(color: Colors.white)),
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