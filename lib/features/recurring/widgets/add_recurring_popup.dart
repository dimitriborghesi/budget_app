import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../accounts/providers/account_provider.dart';
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
  late FixedExtentScrollController dayController;
  late FixedExtentScrollController intervalController;

  int day = 1;
  int interval = 1;

  String selectedAccount = "";
  String selectedCategory = "Courses";
  bool isIncome = false;

  DateTime? _lastHaptic;

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

  /// 🔥 NEW
  {"name": "Maison", "icon": Icons.home, "color": Colors.brown},
  {"name": "Voyage", "icon": Icons.flight, "color": Colors.lightBlue},
  {"name": "Travaux", "icon": Icons.construction, "color": Colors.orange},
  {"name": "Essence", "icon": Icons.local_gas_station, "color": Colors.redAccent},
  {"name": "Assurance", "icon": Icons.security, "color": Colors.indigo},
  {"name": "Voiture", "icon": Icons.directions_car, "color": Colors.blueGrey},
];

@override
void initState() {
  super.initState();

  if (widget.edit != null) {
    final r = widget.edit!;

    titleController.text = r.title;
    amountController.text = r.amount.toString();
    selectedAccount = r.account;
    selectedCategory = r.category;
    isIncome = r.isIncome;
    day = r.day;
    interval = r.interval;
  }

  /// 🔥 IMPORTANT
  dayController = FixedExtentScrollController(initialItem: day - 1);
  intervalController =
      FixedExtentScrollController(initialItem: interval - 1);
}

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RecurringProvider>();
    final accounts = context.watch<AccountProvider>().accounts;

    /// 🔥 AUTO SELECT COMPTE
    if (accounts.isNotEmpty && selectedAccount.isEmpty) {
      selectedAccount = accounts.first.name;
    }

    final categories =
        isIncome ? incomeCategories : expenseCategories;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
  padding: EdgeInsets.only(
    bottom: MediaQuery.of(context).viewInsets.bottom,
  ),
  child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text("Nouvelle récurrence",
                style: TextStyle(color: Colors.white, fontSize: 18)),

            const SizedBox(height: 20),

            _input("Titre", titleController),
            _input("Montant", amountController),

            const SizedBox(height: 15),

            _accounts(accounts),

            const SizedBox(height: 20),

            /// TYPE
            Row(
              children: [
                _typeButton("Dépense", false),
                const SizedBox(width: 10),
                _typeButton("Revenu", true),
              ],
            ),

            const SizedBox(height: 15),

            /// 🔥 ANIM CATEGORIES
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: SizedBox(
                key: ValueKey(isIncome),
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    final selected =
                        selectedCategory == cat["name"];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = cat["name"] as String;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? cat["color"] as Color
                              : const Color(0xFF2C2C2E),
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Icon(cat["icon"] as IconData,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(cat["name"] as String,
                                style: const TextStyle(
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// LABELS
            Row(
              children: const [
                Expanded(
                    child: Center(
                        child: Text("Jour",
                            style: TextStyle(color: Colors.grey)))),
                Expanded(
                    child: Center(
                        child: Text("Tous les",
                            style: TextStyle(color: Colors.grey)))),
              ],
            ),

            const SizedBox(height: 6),

            /// PICKERS
            SizedBox(
              height: 90,
              child: Row(
                children: [
                  Expanded(child: _pickerDay()),
                  Expanded(child: _pickerInterval()),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// 🔥 PREVIEW
            Text(
              _nextExecutionText(),
              style: const TextStyle(
                  color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 20),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF799C0A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                 onPressed: () async {
  final raw = amountController.text
    .replaceAll(',', '.')
    .replaceAll(' ', '');

  final r = Recurring(
    id: widget.edit?.id ?? "",
    title: titleController.text,
    amount: double.tryParse(raw) ?? 0,
    account: selectedAccount,
    category: selectedCategory,
    isIncome: isIncome,
    day: day,
    interval: interval,
    enabled: true,
    done: false,
  );

  if (widget.edit != null) {
    await provider.update(r);
  } else {
    await provider.add(r);
  }

  if (context.mounted) Navigator.pop(context);
},
                child: Text(
  widget.edit != null ? "Modifier la récurrence" : "Nouvelle récurrence",
  style: const TextStyle(color: Colors.white),
),
            ),
            )
          ],
        ),
      ),
    )
    );
  }

  /// 🔥 HAPTIC SMART
  void _haptic() {
    final now = DateTime.now();
    if (_lastHaptic == null ||
        now.difference(_lastHaptic!) > const Duration(milliseconds: 60)) {
      HapticFeedback.selectionClick();
      _lastHaptic = now;
    }
  }

  Widget _pickerDay() {
    return CupertinoPicker(
  scrollController: dayController,
      itemExtent: 28,
      onSelectedItemChanged: (i) {
        _haptic();
        setState(() => day = i + 1);
      },
      children: List.generate(
        31,
        (i) => Center(
            child: Text("${i + 1}",
                style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _pickerInterval() {
    return CupertinoPicker(
  scrollController: intervalController,
      itemExtent: 28,
      onSelectedItemChanged: (i) {
        _haptic();
        setState(() => interval = i + 1);
      },
      children: List.generate(
        12,
        (i) => Center(
            child: Text("${i + 1} mois",
                style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  String _nextExecutionText() {
    final now = DateTime.now();

    int month = now.month;
    int year = now.year;

    if (now.day >= day) {
      month += interval;
    }

    while (month > 12) {
      month -= 12;
      year++;
    }

    final date = DateTime(year, month, day);

    const months = [
      "janvier","février","mars","avril","mai","juin",
      "juillet","août","septembre","octobre","novembre","décembre"
    ];

    return "Prochaine exécution le ${date.day} ${months[date.month - 1]}";
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

  Widget _typeButton(String text, bool value) {
    final selected = isIncome == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isIncome = value;
            selectedCategory = value
                ? incomeCategories.first["name"] as String
                : expenseCategories.first["name"] as String;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF799C0A)
                : const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(text,
                style: const TextStyle(color: Colors.white)),
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