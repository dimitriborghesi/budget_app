import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recurring_provider.dart';
import '../models/recurring.dart';

class AddRecurringPopup extends StatefulWidget {
  final Recurring? edit;

  const AddRecurringPopup({super.key, this.edit});

  @override
  State<AddRecurringPopup> createState() => _AddRecurringPopupState();
}

class _AddRecurringPopupState extends State<AddRecurringPopup> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  int day = 1;
  bool isIncome = false;
  String category = "Netflix";

  final categories = [
    "Netflix",
    "Amazon",
    "Uber",
    "Loyer",
    "Électricité",
    "Eau",
    "Salaire",
  ];

  @override
  void initState() {
    super.initState();

    if (widget.edit != null) {
      titleController.text = widget.edit!.title;
      amountController.text = widget.edit!.amount.toString();
      day = widget.edit!.day;
      isIncome = widget.edit!.isIncome;
      category = widget.edit!.category;
    }
  }

  IconData getIcon(String cat) {
    switch (cat) {
      case "Netflix":
        return Icons.movie;
      case "Amazon":
        return Icons.shopping_bag;
      case "Uber":
        return Icons.local_taxi;
      case "Loyer":
        return Icons.home;
      case "Électricité":
        return Icons.flash_on;
      case "Eau":
        return Icons.water_drop;
      case "Salaire":
        return Icons.attach_money;
      default:
        return Icons.repeat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecurringProvider>(context, listen: false);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.edit == null
                    ? "Nouvelle récurrence"
                    : "Modifier",
                style:
                    const TextStyle(color: Colors.white, fontSize: 18),
              ),

              const SizedBox(height: 20),

              _input("Titre", titleController),
              _input("Montant", amountController),

              /// JOUR
              Row(
                children: [
                  const Text("Jour",
                      style: TextStyle(color: Colors.grey)),
                  const Spacer(),
                  DropdownButton<int>(
                    value: day,
                    dropdownColor: const Color(0xFF2C2C2E),
                    items: List.generate(
                      31,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text("${i + 1}",
                            style: const TextStyle(
                                color: Colors.white)),
                      ),
                    ),
                    onChanged: (v) => setState(() => day = v!),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// CATÉGORIES
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((c) {
                  final selected = c == category;

                  return GestureDetector(
                    onTap: () => setState(() => category = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF7B61FF)
                            : const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(getIcon(c),
                              size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(c,
                              style: const TextStyle(
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

              /// SWITCH
              Row(
                children: [
                  const Text("Revenu",
                      style: TextStyle(color: Colors.grey)),
                  const Spacer(),
                  Switch(
                    value: isIncome,
                    onChanged: (v) =>
                        setState(() => isIncome = v),
                    activeTrackColor: Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B61FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final r = Recurring(
                    id: widget.edit?.id ?? "",
                    title: titleController.text,
                    amount: double.tryParse(
                            amountController.text) ??
                        0,
                    account: "Principal",
                    category: category,
                    isIncome: isIncome,
                    day: day,
                    enabled: widget.edit?.enabled ?? true,
                    done: widget.edit?.done ?? false,
                  );

                  if (widget.edit == null) {
                    await provider.add(r);
                  } else {
                    await provider.update(r);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                    widget.edit == null ? "Ajouter" : "Modifier"),
              ),
            ],
          ),
        ),
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