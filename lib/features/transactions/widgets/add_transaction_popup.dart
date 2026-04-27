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

  DateTime selectedDate = DateTime.now();

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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();

    if (d.day == now.day &&
        d.month == now.month &&
        d.year == now.year) {
      return "Aujourd’hui";
    }

    return "${d.day}/${d.month}/${d.year}";
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
        color: Colors.white,
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

                /// HANDLE
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                /// TITLE
                Text(
                  isIncome
                      ? "Nouveau revenu"
                      : "Nouvelle dépense",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                _input("Titre", titleController),
                _input("Montant", amountController),
                _input("Description", descriptionController),

                /// 🔥 DATE PICKER (ICI)
                const SizedBox(height: 10),
                _buildDatePicker(),

                const SizedBox(height: 15),

                _accounts(accounts),

                const SizedBox(height: 20),

                /// CATEGORIES
                SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 10),
                    itemBuilder: (_, i) {

                      if (i == categories.length) {
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CreateCategoryScreen(
                                        isIncome: isIncome),
                              ),
                            );
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add),
                                SizedBox(width: 6),
                                Text("Ajouter"),
                              ],
                            ),
                          ),
                        );
                      }

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
                                : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                cat.icon,
                                color: selected
                                    ? Colors.white
                                    : Colors.black,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat.name,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.black,
                                ),
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
                      backgroundColor: const Color(0xFF799C0A),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
final raw = amountController.text
    .replaceAll(',', '.')
    .replaceAll(RegExp(r'[^0-9.]'), '');

final amount = double.tryParse(raw);

if (amount == null) {
  print("❌ montant invalide");
  return;
}

if (titleController.text.isEmpty) {
  print("❌ titre vide");
  return;
}

                      await provider.add(
                        title: titleController.text,
                        amount: amount,
                        account: selectedAccount,
                        category: selectedCategory,
                        isIncome: isIncome,
                        date: selectedDate, // 🔥 OK
                      );

if (!mounted) return;
Navigator.pop(context);
                    },
                    child: const Text("Ajouter"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// DATE UI
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 10),
            Text(
              _formatDate(selectedDate),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }

  /// ACCOUNTS
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
                    : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(
                    acc.icon,
                    color:
                        selected ? Colors.white : Colors.black,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    acc.name,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// INPUT
  Widget _input(String hint, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF5F5F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}