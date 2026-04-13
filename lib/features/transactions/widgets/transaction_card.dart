import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class TransactionCard extends StatefulWidget {
  final dynamic t;
  final bool isExpense;
  final Function()? onEdit;

  const TransactionCard({
    super.key,
    required this.t,
    required this.isExpense,
    this.onEdit,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  double offset = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TransactionProvider>();

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          offset += details.delta.dx;
          offset = offset.clamp(-160, 120);
        });
      },
      onHorizontalDragEnd: (_) async {
        /// 👉 POINTER (droite)
        if (offset > 70) {
          widget.t.isChecked = !widget.t.isChecked;

          if (widget.t.isChecked) {
            HapticFeedback.mediumImpact(); // ✔
          } else {
            HapticFeedback.heavyImpact(); // ❌
          }

          await provider.update(widget.t);
        }

        /// 👉 EDIT (gauche léger)
        if (offset < -60 && offset > -120) {
          HapticFeedback.selectionClick();
          if (widget.onEdit != null) widget.onEdit!();
        }

        /// 👉 DELETE (gauche fort)
        if (offset <= -120) {
          HapticFeedback.heavyImpact();
          provider.delete(widget.t);
        }

        setState(() => offset = 0);
      },

      child: Stack(
        children: [
          /// BACKGROUND ACTIONS
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  /// 👉 GAUCHE (✔ pointer)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: offset > 20 ? 1 : 0,
                    child: Row(
                      children: const [
                        Icon(Icons.check, color: Color(0xFF34C759)),
                      ],
                    ),
                  ),

                  const Spacer(),

                  /// 👉 DROITE (edit + delete)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: offset < -40 ? 1 : 0,
                    child: Row(
                      children: const [
                        Icon(Icons.edit, color: Colors.blueAccent),
                        SizedBox(width: 16),
                        Icon(Icons.delete, color: Colors.redAccent),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// FRONT CARD
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
                  /// BADGE ✔ / ❌
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.t.isChecked
                          ? const Color(0xFF34C759).withOpacity(0.2)
                          : Colors.red.withOpacity(0.15),
                    ),
                    child: Icon(
                      widget.t.isChecked
                          ? Icons.check
                          : Icons.close,
                      size: 14,
                      color: widget.t.isChecked
                          ? const Color(0xFF34C759)
                          : Colors.redAccent,
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// TEXTE
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.t.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.t.category,
                          style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  /// MONTANT
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10),
                      gradient: widget.t.isIncome
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
                      "${widget.t.isIncome ? "+" : "-"}${widget.t.amount.toStringAsFixed(2)}€",
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
}