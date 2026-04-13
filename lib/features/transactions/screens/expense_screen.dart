import 'dart:ui';
import 'package:budget_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_popup.dart';
import '../widgets/edit_transaction_popup.dart';
import '../../core/utils/messenger.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

int selectedMonth = DateTime.now().month;

class _ExpenseScreenState extends State<ExpenseScreen> {
  String? openedId;
  final Map<String, GlobalKey<_CardState>> cardKeys = {};

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    
    void dispose() {
  ScaffoldMessenger.of(context).clearSnackBars();
  super.dispose();
}

    final expenses =
        provider.transactions.where((t) => !t.isIncome).toList();

    final total =
expenses.fold<double>(0.0, (sum, t) => sum + (t.amount as double));
        
final Map<String, double> categoryTotals = {};

for (var t in expenses) {
  categoryTotals[t.category] =
      (categoryTotals[t.category] ?? 0) + t.amount;
}

    return Listener(
      behavior: HitTestBehavior.translucent,

      /// 🔥 TAP ANYWHERE GLOBAL
      onPointerDown: (_) {
  // 🔥 ferme TOUS les snackbars
  ScaffoldMessenger.of(context).clearSnackBars();

  if (openedId != null) {
    cardKeys[openedId!]?.currentState?.reset();
    setState(() => openedId = null);
    HapticFeedback.selectionClick();
  }
},

      child: Scaffold(
        floatingActionButton: FloatingActionButton(
  backgroundColor: const Color(0xFF7B61FF),
  onPressed: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionPopup(isIncome: false),
    );
  },
  child: const Icon(Icons.add),
),

        backgroundColor: const Color(0xFF0A0A0A),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
        
              

              /// HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    /// 🔥 FILTRE MOIS
    SizedBox(
  height: 36,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 12,
    itemBuilder: (context, index) {
      final month = index + 1;
      final isSelected = month == selectedMonth;

      return GestureDetector(
        onTap: () {
          setState(() => selectedMonth = month);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF7B61FF)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            _monthName(month),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white38,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    },
  ),
),

    const SizedBox(height: 20),

    /// 🔥 TOTAL
    const Text(
      "Dépenses",
      style: TextStyle(
        color: Colors.white70,
        fontSize: 15,
      ),
    ),

    const SizedBox(height: 6),

    Text(
      "-${total.toStringAsFixed(2)} €",
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),

    const SizedBox(height: 25),
  ],
)
              ),

              const SizedBox(height: 20),
              SizedBox(
  height: 60,
  child: ListView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    children: categoryTotals.entries.map((entry) {
      final cat = getCategoryData(entry.key);

      return Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: (cat["color"] as Color).withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(cat["icon"], color: cat["color"], size: 16),
            const SizedBox(width: 6),
            Text(
              "${entry.value.toStringAsFixed(0)}€",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }).toList(),
  ),
),

const SizedBox(height: 10),

              /// LIST
              Expanded(
  child: Builder(
    builder: (_) {
      final grouped = <String, List<dynamic>>{};

      final now = DateTime.now();
      final yesterday =
          now.subtract(const Duration(days: 1));

      for (var t in expenses) {
        final d = t.date;

        String key;

        if (d.day == now.day &&
            d.month == now.month &&
            d.year == now.year) {
          key = "Aujourd’hui";
        } else if (d.day == yesterday.day &&
            d.month == yesterday.month &&
            d.year == yesterday.year) {
          key = "Hier";
        } else if (now.difference(d).inDays < 7) {
          key = "Cette semaine";
        } else {
          key = "${d.day}/${d.month}/${d.year}";
        }

        grouped.putIfAbsent(key, () => []).add(t);
      }

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: const EdgeInsets.only(
                    top: 16, bottom: 6, left: 4),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ),

              ...entry.value.map((t) {
                return _Card(
                  key: cardKeys.putIfAbsent(
                    t.id,
                    () => GlobalKey<_CardState>(),
                  ),
                  t: t,
                  isOpen: openedId == t.id,
                  onOpen: () =>
                      setState(() => openedId = t.id),
                  onClose: () =>
                      setState(() => openedId = null),
                  isExpense: true,
                );
              }),
            ],
          );
        }).toList(),
      );
    },
  ),
),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFF7B61FF), Color(0xFF9F7CFF)],
          ),
        ),
        alignment: Alignment.center,
        child: const Text("Ajouter"),
      ),
    );
  }
}

class _Card extends StatefulWidget {
  final dynamic t;
  final bool isOpen;
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final bool isExpense;

  const _Card({
    super.key,
    required this.t,
    required this.isOpen,
    required this.onOpen,
    required this.onClose,
    required this.isExpense,
  });

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card>
    with SingleTickerProviderStateMixin {

  double offset = 0;

  final double maxLeft = -150;
  final double maxRight = 90;

  late AnimationController _controller;
  late Animation<double> _animation;

  bool isAnimating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 🍏 animation style UIKit (snap doux)
  void animateTo(double target) {
    isAnimating = true;

    _animation = Tween(begin: offset, end: target).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutExpo,
      ),
    )..addListener(() {
        setState(() => offset = _animation.value);
      });

    _controller.forward(from: 0).whenComplete(() {
      isAnimating = false;
    });
  }

  void reset() {
    widget.onClose();
    animateTo(0);
  }

  /// 🍏 rubber band iOS
  double rubber(double value, double limit) {
    if (value.abs() <= limit) return value;

    final excess = value.abs() - limit;
    final resistance = 1 / ((excess / 120) + 1);

    return value.sign * (limit + excess * resistance);
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<TransactionProvider>(context, listen: false);

    double progressRight =
        (offset / maxRight).clamp(0.0, 1.0);

    double progressLeft =
        (offset / maxLeft).clamp(0.0, 1.0).abs();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: reset,

      onHorizontalDragStart: (_) {
  ScaffoldMessenger.of(context).clearSnackBars();
},

      onHorizontalDragUpdate: (details) {
        if (isAnimating) return;

        setState(() {
          double friction = 1 - (offset.abs() / 350);
          friction = friction.clamp(0.55, 1.0);

          offset += details.delta.dx * friction;
          offset = rubber(offset, offset > 0 ? maxRight : maxLeft.abs());
        });
      },

      onHorizontalDragEnd: (details) async {
        final velocity = details.velocity.pixelsPerSecond.dx;

        if (offset > maxRight * 0.5 || velocity > 900) {
          HapticFeedback.lightImpact();

          HapticFeedback.lightImpact();

// 👉 attendre animation AVANT changement état
await _controller.animateTo(
  maxRight * 0.65,
  duration: const Duration(milliseconds: 220),
  curve: Curves.easeOutExpo,
);

// 👉 petit délai invisible (style iOS)
await Future.delayed(const Duration(milliseconds: 30));

widget.t.isChecked = !widget.t.isChecked;
await provider.update(widget.t);

reset();
        }

        else if (offset < maxLeft * 0.5 || velocity < -900) {
          HapticFeedback.selectionClick();

          widget.onOpen();
          animateTo(maxLeft * 0.65);
        }

        else {
          reset();
        }
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Stack(
          clipBehavior: Clip.none,
          children: [

            /// 🔥 BACK (BLUR dynamique)
            Positioned.fill(
              child: Row(
                children: [

                  /// LEFT BUTTON
                  Transform.translate(
                    offset: Offset(offset > 0 ? offset - 70 : -70, 0),
                    child: Opacity(
                      opacity: progressRight,
                      child: _blurCircle(
                        icon: widget.t.isChecked
                            ? Icons.close
                            : Icons.check,
                        color: widget.t.isChecked
                            ? Colors.redAccent
                            : const Color(0xFF34C759),
                        intensity: progressRight,
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// RIGHT BUTTONS
                  Transform.translate(
                    offset: Offset(
                      (offset + 110).clamp(0, 110),
                      0,
                    ),
                    child: Row(
                      children: [

                        Opacity(
                          opacity: progressLeft,
                          child: GestureDetector(
                            onTap: () {
                              reset();
                              showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: EditTransactionPopup(transaction: widget.t),
    );
  },
);
                            },
                            child: _blurCircle(
                              icon: Icons.edit,
                              color: Colors.white,
                              intensity: progressLeft,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Opacity(
                          opacity: progressLeft,
                          child: GestureDetector(
                            onTap: () {
                              final deleted = widget.t;

                              provider.delete(widget.t);

                              final messenger = messengerKey.currentState!;

messenger.clearSnackBars();

messenger.showSnackBar(
  SnackBar(
    duration: const Duration(seconds: 5),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(12),
    backgroundColor: const Color(0xFF1C1C1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    content: const Text("Supprimé"),
    action: SnackBarAction(
      label: "Annuler",
      textColor: const Color(0xFF7B61FF),
      onPressed: () {
        provider.add(
          title: deleted.title,
          amount: deleted.amount,
          account: deleted.account,
          category: deleted.category,
          isIncome: deleted.isIncome,
        );
      },
    ),
  ),
);
                              reset();
                            },
                            child: _blurCircle(
                              icon: Icons.delete,
                              color: Colors.redAccent,
                              intensity: progressLeft,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// FRONT
            Transform.translate(
              offset: Offset(offset, 0),
              child: Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color(0xFF151515),
    borderRadius: BorderRadius.circular(18),
  ),
                child: Row(
  children: [
    /// 🔥 ICON CATEGORY
    Builder(
      builder: (_) {
        final cat = getCategoryData(widget.t.category);

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (cat["color"] as Color).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            cat["icon"] as IconData,
            color: cat["color"] as Color,
            size: 18,
          ),
        );
      },
    ),

    const SizedBox(width: 12),

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.t.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(widget.t.date),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),

    Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(10),

  gradient: widget.t.isChecked
      ? const LinearGradient(
          colors: [
            Color(0xFF1B3C10),
            Color(0xFF3C460A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [
            Color.fromARGB(255, 97, 19, 19),
            Color.fromARGB(255, 43, 13, 13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
),

  child: Text(
    "-${widget.t.amount.toStringAsFixed(2)}€",
    style: const TextStyle(
  color: Colors.white,
  fontSize: 13.5,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.3,
  height: 1.2,
  fontFamily: 'SF Pro Text',
),
  ),
),
  ],
)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blurCircle({
    required IconData icon,
    required Color color,
    required double intensity,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10 * intensity,
          sigmaY: 10 * intensity,
        ),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color.lerp(
                Colors.transparent,
                const Color(0x22FFFFFF),
                intensity),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final yesterday =
      now.subtract(const Duration(days: 1));

  final hour =
      "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

  if (date.day == now.day &&
      date.month == now.month &&
      date.year == now.year) {
    return "Aujourd’hui • $hour";
  }

  if (date.day == yesterday.day &&
      date.month == yesterday.month &&
      date.year == yesterday.year) {
    return "Hier • $hour";
  }

  return "${date.day.toString().padLeft(2, '0')}/"
         "${date.month.toString().padLeft(2, '0')} • $hour";
}
Map<String, dynamic> getCategoryData(String cat) {
  switch (cat) {
    case "Santé":
      return {"icon": Icons.favorite, "color": Colors.pink};
    case "Loisirs":
      return {"icon": Icons.sports_esports, "color": Colors.purple};
    case "Travaux":
      return {"icon": Icons.home_repair_service, "color": Colors.orange};
    case "Cadeaux":
      return {"icon": Icons.card_giftcard, "color": Colors.red};
    case "Courses":
      return {"icon": Icons.shopping_cart, "color": Colors.green};
    case "Transport":
      return {"icon": Icons.directions_bus, "color": Colors.blue};
    case "Voiture":
      return {"icon": Icons.directions_car, "color": Colors.indigo};
    case "Assurances":
      return {"icon": Icons.security, "color": Colors.teal};
    case "Restaurant":
      return {"icon": Icons.restaurant, "color": Colors.deepOrange};
    case "Voyage":
      return {"icon": Icons.flight, "color": Colors.lightBlue};
    case "Paypal":
      return {"icon": Icons.account_balance_wallet, "color": Colors.blueAccent};
    case "Amazon":
      return {"icon": Icons.shopping_bag, "color": Colors.orangeAccent};
    case "Amende":
      return {"icon": Icons.warning, "color": Colors.redAccent};
    case "Shopping":
      return {"icon": Icons.store, "color": Colors.pinkAccent};
    case "Factures":
      return {"icon": Icons.receipt_long, "color": Colors.grey};
    default:
      return {"icon": Icons.category, "color": Colors.white};
  }
}
String _monthName(int month) {
  const months = [
    "Jan",
    "Fév",
    "Mar",
    "Avr",
    "Mai",
    "Juin",
    "Juil",
    "Août",
    "Sep",
    "Oct",
    "Nov",
    "Déc"
  ];

  return months[month - 1];
}
