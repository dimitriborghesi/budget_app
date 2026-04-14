import 'package:budget_app/features/transactions/widgets/edit_transaction_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:budget_app/core/utils/category_utils.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../../../core/providers/category_provider.dart';

class TransactionCard extends StatefulWidget {
  final TransactionModel t;
  final bool isExpense;

  const TransactionCard({
    super.key,
    required this.t,
    required this.isExpense,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  double offset = 0;

  bool? previewChecked;
  bool isReleasing = false;

  @override
Widget build(BuildContext context) {
  final provider = context.read<TransactionProvider>();
  final t = widget.t;

final cat = context
    .watch<CategoryProvider>()
    .getByName(t.category);

  return GestureDetector(

  /// 👉 TAP = EDIT
  onTap: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditTransactionPopup(transaction: t),
    );
  },
    onHorizontalDragUpdate: (details) {
  setState(() {
    offset = (offset + details.delta.dx).clamp(-120, 120);
  });

  /// 🔥 vibration légère quand on passe un seuil
  if (offset > 60 && offset < 65) {
    HapticFeedback.lightImpact();
  }
},

   onHorizontalDragEnd: (_) async {

  /// 👉 DROITE = CHECK
if (offset > 90) {
  HapticFeedback.heavyImpact();
  final updated = TransactionModel(
      id: t.id,
      title: t.title,
      amount: t.amount,
      isIncome: t.isIncome,
      category: t.category,
      account: t.account,
      date: t.date,
      userId: t.userId,
      isChecked: !t.isChecked,
      bankId: t.bankId,
      isSynced: t.isSynced,
    );

    setState(() {
      isReleasing = true;
      previewChecked = !t.isChecked;
      offset = 0;
    });

    await Future.delayed(const Duration(milliseconds: 120));

    await provider.update(updated);

    setState(() {
      previewChecked = null;
      isReleasing = false; // 🔥 IMPORTANT
    });

    return;
  }

  /// 👉 GAUCHE = DELETE
  if (offset < -80) {
    HapticFeedback.heavyImpact();

    final deleted = t;

    setState(() {
      isReleasing = true;
      offset = 0;
    });

    await provider.delete(t);

    if (context.mounted) {
      ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(
    SnackBar(
      content: const Text("Supprimé"),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: "Annuler",
        textColor: Colors.white,
        onPressed: () async {
          await provider.add(
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
    }

    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      isReleasing = false; // 🔥 IMPORTANT
    });

    return;
  }

  /// 👉 RESET NORMAL
  setState(() {
    isReleasing = true;
    offset = 0;
  });

  await Future.delayed(const Duration(milliseconds: 100));

  setState(() {
    isReleasing = false;
  });
},

    child: Stack(
  children: [

    /// 🔥 BACKGROUND
    Positioned.fill(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [

      /// 👉 GAUCHE = CHECK
      if (!isReleasing && offset > 20)
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Transform.translate(
            offset: Offset(offset.clamp(0, 70) - 70, 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: (previewChecked ?? t.isChecked)
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
              child: Icon(
                (previewChecked ?? t.isChecked)
                    ? Icons.close
                    : Icons.check,
                color: Colors.white,
              ),
            ),
          ),
        )
      else
        const SizedBox(width: 60),

      /// 👉 DROITE = DELETE
      if (!isReleasing && offset < -20)
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Transform.translate(
            offset: Offset(offset.clamp(-70, 0) + 70, 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF611313),
                    Color(0xFF2B0D0D),
                  ],
                ),
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
        )
      else
        const SizedBox(width: 60),
    ],
  ),
),
     

    /// 🔥 CARD DEVANT
    AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      transform: Matrix4.translationValues(offset, 0, 0),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
  children: [

    /// 🔥 ICON CATÉGORIE
    Container(
  margin: const EdgeInsets.only(right: 12),
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: (cat?.color ?? Colors.white).withOpacity(0.2),
  ),
  child: Icon(
    cat?.icon ?? Icons.category,
    color: cat?.color ?? Colors.white,
    size: 18,
  ),
),

    /// 🔥 TEXTE
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${t.category} • ${_formatDate(t.date)}",
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),

    /// 🔥 POINTAGE (✔ / ❌)
    Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: (previewChecked ?? t.isChecked)
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
      child: Icon(
        (previewChecked ?? t.isChecked)
            ? Icons.check
            : Icons.close,
        color: Colors.white,
        size: 14,
      ),
    ),

    /// 💰 MONTANT
    Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: t.isIncome
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
        "${t.isIncome ? "+" : "-"}${t.amount.toStringAsFixed(2)}€",
        style: const TextStyle(color: Colors.white),
      ),
    ),
  ],
),
    ),
  ],
    ),
  );
}
}
String _formatDate(DateTime date) {
  return "${date.day}/${date.month} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
}
