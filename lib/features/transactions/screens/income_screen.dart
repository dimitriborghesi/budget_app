import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_popup.dart';
import '../widgets/edit_transaction_popup.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  String? openedId;

  /// 🔥 clé pour contrôler les cards
  final Map<String, GlobalKey<_CardState>> cardKeys = {};

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final incomes =
        provider.transactions.where((t) => t.isIncome).toList();

    final total =
incomes.fold<double>(0.0, (sum, t) => sum + (t.amount as double));

    return Listener(
      behavior: HitTestBehavior.translucent,

      /// 🔥 TAP ANYWHERE FIX (réel)
      onPointerDown: (_) {
        if (openedId != null) {
          cardKeys[openedId!]?.currentState?.reset();
          setState(() => openedId = null);
          HapticFeedback.selectionClick();
        }
      },

      child: Scaffold(
        backgroundColor: Colors.black,
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
                    const Text("Revenus",
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      "+${total.toStringAsFixed(2)} €",
                      style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    _button(() {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            const AddTransactionPopup(isIncome: true),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: incomes.length,
                  itemBuilder: (context, i) {
                    final t = incomes[i];

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

  const _Card({
    super.key,
    required this.t,
    required this.isOpen,
    required this.onOpen,
    required this.onClose,
  });

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card>
    with SingleTickerProviderStateMixin {

  double offset = 0;

  final double maxLeft = -150;
  final double maxRight = 110;

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

          animateTo(maxRight * 0.85);

          Future.delayed(const Duration(milliseconds: 120), () async {
            widget.t.isChecked = !widget.t.isChecked;
            await provider.update(widget.t);
            reset();
          });
        }

        else if (offset < maxLeft * 0.5 || velocity < -900) {
          HapticFeedback.selectionClick();

          widget.onOpen();
          animateTo(maxLeft * 0.95);
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
                              showDialog(
                                context: context,
                                builder: (_) => EditTransactionPopup(
                                  transaction: widget.t,
                                ),
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

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: const Text("Supprimé"),
                                  behavior:
                                      SnackBarBehavior.floating,
                                  backgroundColor:
                                      const Color(0xFF1C1C1E),
                                  action: SnackBarAction(
                                    label: "Annuler",
                                    textColor:
                                        const Color(0xFF7B61FF),
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
                    const Icon(Icons.arrow_downward,
                        color: Color(0xFF34C759)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(widget.t.title)),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.t.isChecked
                            ? const Color(0xFF34C759)
                                .withOpacity(0.15)
                            : const Color(0xFFFF3B30)
                                .withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.t.isChecked
                            ? Icons.check
                            : Icons.close,
                        size: 16,
                        color: widget.t.isChecked
                            ? const Color(0xFF34C759)
                            : const Color(0xFFFF3B30),
                      ),
                    ),

                    Text(
                      "+${widget.t.amount.toStringAsFixed(2)}€",
                      style: const TextStyle(
                        color: Color(0xFF34C759),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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