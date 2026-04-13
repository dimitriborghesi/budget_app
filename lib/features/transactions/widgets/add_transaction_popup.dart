import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';

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
  final TextEditingController titleController =
      TextEditingController();
  final TextEditingController amountController =
      TextEditingController();

  String selectedAccount = "Principal";

  /// 🔥 CATEGORIES
 late final List<Map<String, dynamic>> categories;

@override
void initState() {
  super.initState();

  categories = widget.isIncome
      ? [
          {"name": "Salaire", "icon": Icons.work, "color": Colors.green},
          {"name": "Remboursement", "icon": Icons.reply, "color": Colors.blue},
          {"name": "Anniversaire", "icon": Icons.cake, "color": Colors.orange},
          {"name": "Don", "icon": Icons.volunteer_activism, "color": Colors.teal},
          {"name": "Amis", "icon": Icons.people, "color": Colors.purple},
        ]
      : [
          {"name": "Courses", "icon": Icons.shopping_cart, "color": Colors.green},
          {"name": "Transport", "icon": Icons.directions_bus, "color": Colors.blue},
          {"name": "Restaurant", "icon": Icons.restaurant, "color": Colors.deepOrange},
          {"name": "Loisirs", "icon": Icons.sports_esports, "color": Colors.purple},
          {"name": "Factures", "icon": Icons.receipt, "color": Colors.grey},
        ];
}

String selectedCategory = "Courses";

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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Montant",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 CATEGORIES UI
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final cat = categories[index];
                  final isSelected =
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected
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

            const SizedBox(height: 30),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final title =
                      titleController.text.trim();
                  final amountText =
                      amountController.text.trim();

                  if (title.isEmpty ||
                      amountText.isEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                          content:
                              Text("Remplis les champs")),
                    );
                    return;
                  }

                  final amount =
                      double.tryParse(amountText);
                  if (amount == null) return;

                  await Provider.of<TransactionProvider>(
                    context,
                    listen: false,
                  ).add(
                    title: title,
                    amount: amount,
                    account: selectedAccount,
                    category: selectedCategory, // 🔥 FIX
                    isIncome: widget.isIncome,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content:
                          Text("Transaction ajoutée"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF7B61FF),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Ajouter"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}