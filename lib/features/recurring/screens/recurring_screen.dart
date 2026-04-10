import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/recurring_provider.dart';
import '../models/recurring.dart';
import '../widgets/add_recurring_popup.dart';

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  String? openedId;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecurringProvider>(context);

    return GestureDetector(
      onTap: () => setState(() => openedId = null),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Récurrence"),
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF6C5CE7),
          child: const Icon(Icons.add),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AddRecurringPopup(),
            );
          },
        ),

        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.recurring.length,
          itemBuilder: (context, i) {
            final r = provider.recurring[i];

            return _Card(
              r: r,
              isOpen: openedId == r.id,
              onOpen: () => setState(() => openedId = r.id),
              onClose: () => setState(() => openedId = null),
            );
          },
        ),
      ),
    );
  }
}

class _Card extends StatefulWidget {
  final Recurring r;
  final bool isOpen;
  final VoidCallback onOpen;
  final VoidCallback onClose;

  const _Card({
    required this.r,
    required this.isOpen,
    required this.onOpen,
    required this.onClose,
  });

  @override
  State<_Card> createState() => _CardState();
}

// 🔥 UNIQUEMENT _CardState MODIFIÉ

class _CardState extends State<_Card> {
  double offset = 0;

  final double maxLeft = -120;
  final double maxRight = 90;

  void reset() {
    setState(() => offset = 0);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<RecurringProvider>(context, listen: false);

    return GestureDetector(
      behavior: HitTestBehavior.translucent, // 🔥 clique partout
      onTap: reset,

      onHorizontalDragUpdate: (details) {
        setState(() {
          offset += details.delta.dx;
          offset = offset.clamp(maxLeft, maxRight);
        });
      },

      onHorizontalDragEnd: (_) async {
        if (offset > 70) {
          HapticFeedback.lightImpact();

          widget.r.done = !widget.r.done;
          await provider.update(widget.r);

          reset();
        } else if (offset < -70) {
          widget.onOpen();
          setState(() => offset = maxLeft);
        } else {
          reset();
        }
      },

      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Stack(
  clipBehavior: Clip.none,
  children: [
    /// 🔥 BACKGROUND ACTIONS (ALIGNÉS AVEC LA CARD)
    Positioned.fill(
      child: Padding(
padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// LEFT
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: offset > 40 ? 1 : 0,
              child: _ActionButton(
                color: widget.r.done
                    ? const Color(0xFFFF3B30)
                    : const Color(0xFF34C759),
                icon: widget.r.done ? Icons.close : Icons.check,
                label: widget.r.done ? "Annuler" : "Valider",
                onTap: () async {
                  widget.r.done = !widget.r.done;
                  await provider.update(widget.r);
                  reset();
                },
              ),
            ),

            /// RIGHT
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: offset < -40 ? 1 : 0,
              child: Row(
                children: [
                  _ActionButton(
                    color: const Color(0xFFFF9F0A),
                    icon: Icons.edit,
                    label: "Modifier",
                    onTap: () {
                      reset();
                      showDialog(
                        context: context,
                        builder: (_) =>
                            AddRecurringPopup(edit: widget.r),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _ActionButton(
                    color: const Color(0xFFFF3B30),
                    icon: Icons.delete,
                    label: "Supprimer",
                    onTap: () async {
                      final deletedItem = widget.r;

                      await provider.delete(deletedItem.id);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Supprimé"),
                          action: SnackBarAction(
                            label: "Annuler",
                            onPressed: () async {
                              await provider.add(deletedItem);
                            },
                          ),
                        ),
                      );
                    },
                  ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(22),
        ),
        child: _content(widget.r),
      ),
    ),
  ],
)
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

  Widget _content(Recurring r) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF34C759)
                .withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.repeat,
              color: Color(0xFF34C759)),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(r.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
              Text("Le ${r.day}",
                  style:
                      const TextStyle(color: Colors.grey)),
            ],
          ),
        ),

        /// 💎 STATUS STYLE IOS
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: r.done
                    ? const Color(0xFF34C759)
                        .withValues(alpha: 0.15)
                    : const Color(0xFFFF3B30)
                        .withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Icon(
                r.done ? Icons.check : Icons.close,
                color: r.done
                    ? const Color(0xFF34C759)
                    : const Color(0xFFFF3B30),
                size: 16,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "${r.isIncome ? "+" : "-"}${r.amount.toStringAsFixed(2)}€",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: r.isIncome
                    ? const Color(0xFF34C759)
                    : const Color(0xFFFF453A),
              ),
            ),
          ],
        )
      ],
    );
  }