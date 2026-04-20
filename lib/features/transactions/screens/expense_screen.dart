// ✅ VERSION CLEAN — STABLE + FADE OK

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_popup.dart';
import '../widgets/transaction_card.dart';
import 'package:animations/animations.dart';

class MonthClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 24.0;

    /// 🔥 largeur de ton encoche (change juste ça)
    const padding = -3.0;

    final path = Path();

    /// 🔝 HAUT
    path.moveTo(0, 0);
    path.lineTo(0, size.height);

    /// 🔥 GAUCHE → début encoche
    path.lineTo(padding, size.height);

    /// 🔥 ARRONDI GAUCHE (inchangé)
    path.quadraticBezierTo(
      padding,
      size.height - radius,
      padding + radius,
      size.height - radius,
    );

    /// 🔥 LIGNE CENTRALE (plus longue)
    path.lineTo(size.width - padding - radius, size.height - radius);

    /// 🔥 ARRONDI DROIT (inchangé)
    path.quadraticBezierTo(
      size.width - padding,
      size.height - radius,
      size.width - padding,
      size.height,
    );

    /// 🔝 DROITE
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

int selectedMonth = DateTime.now().month;

class _ExpenseScreenState extends State<ExpenseScreen> {
  bool showUncheckedOnly = false;
  int previousMonth = selectedMonth;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final expenses = provider.transactions
        .where((t) => !t.isIncome && t.date.month == selectedMonth)
        .toList();

    final filtered = showUncheckedOnly
        ? expenses.where((t) => !t.isChecked).toList()
        : expenses;

    final totalCount = expenses.length;
    final unchecked = expenses.where((t) => !t.isChecked).length;
    final checked = expenses.where((t) => t.isChecked).length;

    final now = DateTime.now();

    final todayExpenses = expenses
        .where((t) =>
            t.date.day == now.day &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final yesterday = now.subtract(const Duration(days: 1));

    final yesterdayExpenses = expenses
        .where((t) =>
            t.date.day == yesterday.day &&
            t.date.month == yesterday.month &&
            t.date.year == yesterday.year)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final diff = todayExpenses - yesterdayExpenses;

    return Scaffold(
      backgroundColor: Colors.transparent,

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9EA34E),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: const Color(0xFF060B05),
            builder: (_) => const AddTransactionPopup(isIncome: false),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Stack(
        children: [

          /// 🔥 BACKGROUND
          Transform.translate(
            offset: const Offset(0, -80),
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          /// 🔥 GLOBAL FADE (léger)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.15, 0.5, 1.0],
                colors: [
                  Colors.transparent, 
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(1),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                /// 🔥 HEADER
                Stack(
                  clipBehavior: Clip.none,
                  children: [

                    /// MOIS
       ClipPath(
  clipper: MonthClipper(),
  child: Container(
    height: 70,
    color: Colors.white,

    /// 🔥 CENTRAGE VERTICAL PARFAIT
    alignment: Alignment.center,

    child: Transform.translate(
        offset: const Offset(0, -12), // 👈 ajuste ici
  child: SizedBox(
      height: 36, // 👈 hauteur réelle des pills

      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 12,
        separatorBuilder: (_, __) => const SizedBox(width: 8),

        itemBuilder: (_, index) {
          final month = index + 1;
          final isSelected = month == selectedMonth;

          return GestureDetector(
            onTap: () {
              setState(() {
                previousMonth = selectedMonth;
                selectedMonth = month;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),

              /// 🔥 HAUTEUR FIXE → plus de décalage
              height: 36,
              alignment: Alignment.center,

              padding: const EdgeInsets.symmetric(horizontal: 14),

              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF9EA34E)
                    : const Color(0xFFF2F2F7),

                borderRadius: BorderRadius.circular(18),

                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),

              child: Text(
                _monthName(month),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    ),
  ),
),
       ),

                    /// CARD
                    Positioned(
                      top: 55,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [

                            /// 🔥 RADIAL FADE (LOCAL PROPRE)
Positioned.fill(
  child: Stack(
    children: [

      /// 1️⃣ GRADIENT DIAGONAL
      Positioned.fill(
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.4, 0.75, 1.0],
        colors: [
          Colors.white,  // lisibilité texte
          Colors.white,
          Colors.white.withOpacity(0.1),  // 👈 presque transparent
          Colors.transparent,             // 👈 FULL tasse visible
        ],
      ),
    ),
  ),
),
    ],
  ),
),
                                                        /// CARD BG
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                              color: Colors.white.withOpacity(0.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Row(
                                    children: [
                                      Text("${_monthName(selectedMonth)} • "),
                                      Text("$totalCount transactions",
                                        style: const TextStyle(
    fontSize: 13,
    color: Colors.black54,
  ),
),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Text("$unchecked non pointées • $checked validées"),

                                  const SizedBox(height: 12),

                                  Text(
                                    "Aujourd’hui : -${todayExpenses.toStringAsFixed(2)} €",
                                      style: const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: Colors.black,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "${diff >= 0 ? "+" : ""}${diff.toStringAsFixed(2)}€ vs hier",
                                    style: TextStyle(
                                      color: diff <= 0 ? Colors.green : Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showUncheckedOnly = !showUncheckedOnly;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: showUncheckedOnly
                                                ? const Color(0xFF9EA34E)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            "Non pointé",
                                            style: TextStyle(
                                              color: showUncheckedOnly
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 190),

                /// 🔥 LISTE
                Expanded(
                  child: PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation, secondaryAnimation) {
                      final monthDiff = (selectedMonth - previousMonth + 12) % 12;
                      final isForward = monthDiff > 0 && monthDiff <= 6;

                      final offsetAnimation = Tween<Offset>(
                        begin: isForward ? const Offset(1, 0) : const Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ));

                      return ClipRect(
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: ListView(
                      key: ValueKey(selectedMonth),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: _buildGroupedList(filtered),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedList(List filtered) {
    final now = DateTime.now();

    bool isToday(DateTime d) =>
        d.day == now.day && d.month == now.month && d.year == now.year;

    bool isYesterday(DateTime d) {
      final y = now.subtract(const Duration(days: 1));
      return d.day == y.day && d.month == y.month && d.year == y.year;
    }

    filtered.sort((a, b) => b.date.compareTo(a.date));

    Map<String, List> grouped = {};

    for (var t in filtered) {
      String key;

      if (isToday(t.date)) {
        key = "Aujourd’hui";
      } else if (isYesterday(t.date)) {
        key = "Hier";
      } else {
        key = "${t.date.day} ${_monthName(t.date.month)}";
      }

      grouped.putIfAbsent(key, () => []).add(t);
    }

    return grouped.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 16, bottom: 6),
            child: Text(
              entry.key,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          ...entry.value.map((t) => TransactionCard(
                t: t,
                isExpense: true,
                backgroundColor: Colors.white.withOpacity(0.97),
              )),
        ],
      );
    }).toList();
  }
}

String _monthName(int month) {
  const months = [
    "Jan","Fév","Mar","Avr","Mai","Juin",
    "Juil","Août","Sep","Oct","Nov","Déc"
  ];
  return months[month - 1];
}