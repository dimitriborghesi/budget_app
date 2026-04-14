import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/recurring_provider.dart';
import '../models/recurring.dart';
import '../widgets/add_recurring_popup.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecurringProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF799C0A),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddRecurringPopup(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Récurrence",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

_buildMonthlyImpact(provider.recurring),

const SizedBox(height: 20),

            Expanded(
  child: Builder(
    builder: (_) {
      final active =
    provider.recurring.where((r) => r.enabled).toList();

final inactive =
    provider.recurring.where((r) => !r.enabled).toList();

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [

          /// 🔥 ACTIFS
          if (active.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Activé",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),

            ...active.map((r) => RecurringCard(r: r)),
          ],

          /// 🔥 INACTIFS
          if (inactive.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Désactivé",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
            ),

            ...inactive.map((r) => RecurringCard(r: r)),
          ],
        ],
      );
    },
  ),
)
          ],
        ),
      ),
    );
  }
}

class RecurringCard extends StatefulWidget {
  final Recurring r;

  const RecurringCard({super.key, required this.r});

  @override
  State<RecurringCard> createState() => _RecurringCardState();
}

class _RecurringCardState extends State<RecurringCard> {
  double offset = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RecurringProvider>();
    final r = widget.r;

    return GestureDetector(
      /// 🔥 TAP = EDIT
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AddRecurringPopup(edit: r),
        );
      },

      /// 🔥 SWIPE
      onHorizontalDragUpdate: (details) {
        setState(() {
          offset += details.delta.dx;
          offset = offset.clamp(-160, 120);
        });
      },

      onHorizontalDragEnd: (_) async {
        /// 👉 DROITE = VALIDER
        if (offset > 70) {
  final updated = Recurring(
    id: r.id,
    title: r.title,
    amount: r.amount,
    account: r.account,
    category: r.category,
    isIncome: r.isIncome,
    day: r.day,
    interval: r.interval,
    enabled: !r.enabled, // 🔥 toggle ici
    done: r.done,
    lastRun: r.lastRun,
  );

  HapticFeedback.mediumImpact();
  await provider.update(updated);
}

        /// 👉 GAUCHE = DELETE
        if (offset < -80) {
          HapticFeedback.heavyImpact();

          final deleted = r;
          await provider.delete(r.id);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Supprimé"),
              action: SnackBarAction(
                label: "Annuler",
                onPressed: () async {
                  await provider.restore(deleted);
                },
              ),
            ),
          );
        }

        setState(() => offset = 0);
      },

      child: Stack(
        children: [

          /// BACKGROUND
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: offset > 20 ? 1 : 0,
                    child: const Icon(Icons.check,
                        color: Color(0xFF34C759)),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: offset < -40 ? 1 : 0,
                    child: const Icon(Icons.delete,
                        color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ),

          /// CARD
          Transform.translate(
            offset: Offset(offset, 0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [

                  /// BADGE PROPRE
                  Container(
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: _getCategoryColor(r.category).withOpacity(0.15),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(
    _getCategoryIcon(r.category),
color: _getCategoryColor(r.category),
  ),
),

                  const SizedBox(width: 12),

                  /// TEXT
                  Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        r.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),

      /// 🔥 LOGIQUE AVANT LE TEXT
      Builder(
        builder: (_) {
          final now = DateTime.now();

          final isDoneThisMonth = r.lastRun != null &&
              r.lastRun!.month == now.month &&
              r.lastRun!.year == now.year;

          final subtitle = isDoneThisMonth
              ? "${r.category} • ✔ effectué ce mois"
              : "${r.category} • ${_nextDate(r)}";

          return Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          );
        },
      ),
    ],
  ),
),

                  /// AMOUNT
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: r.isIncome
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF1B3C10),
                                Color(0xFF3C460A),
                              ],
                            )
                          : const LinearGradient(
                              colors: [
                                Color(0xFF611313),
                                Color(0xFF2B0D0D),
                              ],
                            ),
                    ),
                    child: Text(
                      "${r.isIncome ? "+" : "-"}${r.amount.toStringAsFixed(2)}€",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 DATE PROCHAINE
  String _nextDate(Recurring r) {
  final now = DateTime.now();

  int month = now.month;
  int year = now.year;

  if (now.day >= r.day) {
    month += r.interval;
  }

  while (month > 12) {
    month -= 12;
    year++;
  }

  final date = DateTime(year, month, r.day);
  final diff = date.difference(now).inDays;

  const months = [
    "janvier","février","mars","avril","mai","juin",
    "juillet","août","septembre","octobre","novembre","décembre"
  ];

  if (diff <= 0) return "Aujourd'hui";
  if (diff == 1) return "Demain";

  return "Dans $diff jours • ${date.day} ${months[date.month - 1]}";
}
}
Widget _buildMonthlyImpact(List<Recurring> list) {
  double income = 0;
  double expense = 0;

  for (var r in list.where((r) => r.enabled)) {
    if (r.isIncome) {
      income += r.amount;
    } else {
      expense += r.amount;
    }
  }

  return Column(
    children: [

      const Text(
        "Total",
        style: TextStyle(
          color: Colors.white54,
          fontSize: 18
        ),
      ),

      const SizedBox(height: 8),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          /// 🔥 INCOME ANIMÉ
          _AnimatedAmount(
            value: income,
            isExpense: false,
          ),

          const SizedBox(width: 12),

          /// 🔥 EXPENSE ANIMÉ
          _AnimatedAmount(
            value: expense,
            isExpense: true,
          ),
        ],
      ),
    ],
  );
}
/// 🎨 ICON + COULEUR
Color _getCategoryColor(String category) {
  switch (category) {
    case "Courses":
      return Colors.green;
    case "Santé":
      return Colors.pink;
    case "Loisirs":
      return Colors.purple;
    case "Transport":
      return Colors.blue;
    case "Restaurant":
      return Colors.deepOrange;
    case "Salaire":
      return Colors.green;
    case "Factures":
      return Colors.grey;
    default:
      return Colors.white;
  }
}

IconData _getCategoryIcon(String category) {
  switch (category) {
    case "Courses":
      return Icons.shopping_cart;
    case "Santé":
      return Icons.favorite;
    case "Loisirs":
      return Icons.sports_esports;
    case "Transport":
      return Icons.directions_bus;
    case "Restaurant":
      return Icons.restaurant;
    case "Salaire":
      return Icons.work;
    case "Factures":
      return Icons.receipt_long;
    default:
      return Icons.category;
  }
}
class _AnimatedAmount extends StatelessWidget {
  final double value;
  final bool isExpense;

  const _AnimatedAmount({
    required this.value,
    this.isExpense = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0, end: value),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {

        return AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: isExpense
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF611313),
                        Color(0xFF2B0D0D),
                      ],
                    )
                  : const LinearGradient(
                      colors: [
                        Color(0xFF1B3C10),
                        Color(0xFF3C460A),
                      ],
                    ),
            ),
            child: Text(
              "${isExpense ? "-" : "+"}${animatedValue.toStringAsFixed(2)}€ / mois",
              style: const TextStyle(
                color: Colors.white,
                fontSize:20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}