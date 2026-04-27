import 'package:budget_app/features/transactions/widgets/edit_transaction_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:budget_app/core/utils/category_utils.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../../../core/providers/category_provider.dart';
import '../../../main.dart';
import 'package:budget_app/core/theme/app_colors.dart';


class TransactionCard extends StatefulWidget {
  final TransactionModel t;
  final bool isExpense;
  final Color? backgroundColor;
  final bool isFirst;
  final bool isLast;

  const TransactionCard({
    this.isFirst = false,
    this.isLast = false,
    super.key,
    required this.t,
    required this.isExpense,
    this.backgroundColor, // 👈 AJOUT

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
final theme = Theme.of(context);


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
messengerKey.currentState
  ?..hideCurrentSnackBar()
  ..showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,

      /// 🔥 ALIGNEMENT AVEC TA LISTE
      margin: const EdgeInsets.symmetric(
        horizontal: 16, // 👈 EXACT comme ta liste
        vertical: 10,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

backgroundColor: theme.colorScheme.inverseSurface,

      content: Row(
        children: [
           Expanded(
            child: Text(
  "Supprimé",
  style: TextStyle(
    color: theme.colorScheme.onInverseSurface,
  ),
),
          ),

          /// 🔥 TON BOUTON
          GestureDetector(
            onTap: () async {
              await provider.add(
                title: deleted.title,
                amount: deleted.amount,
                account: deleted.account,
                category: deleted.category,
                isIncome: deleted.isIncome,
                date: deleted.date,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF9EA34E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "Annuler",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
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
      if (!isReleasing && offset > 60)
if (!isReleasing && offset > 20)
  Padding(
    padding: const EdgeInsets.only(left: 20),
    child: Transform.translate(
      offset: Offset(
        -105 + offset.clamp(0, 100), // 👈 magie ici
        0,
      ),
      child: Opacity(
        opacity: (offset / 110).clamp(0, 1), // 👈 fade progressif
child: Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    gradient: (previewChecked ?? t.isChecked)
        ? const RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFFCB5B5E),
              Color(0xFFBB5258),
              Color(0xFFAC4854),
            ],
            stops: [0.0, 0.5, 1.0],
          )
        : const RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF9EA34E),
              Color(0xFF9EA34E),
            ],
            stops: [0.3, 1.0],
          ),
  ),
  child: Text(
    (previewChecked ?? t.isChecked)
        ? "Non pointé"
        : "Pointé",
    style: const TextStyle(
      color: Color(0xFFFAF7F8),
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),
  ),
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
offset: Offset(
  380 + offset.clamp(-70, 0), // 👈 plus proche du bord
  0,
),
      child: Opacity(
        opacity: (-offset / 110).clamp(0, 1), // 👈 fade progressif
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
        colors: [
              Color(0xFFCB5B5E),
    Color(0xFFBB5258), // couleur intermédiaire auto
    Color(0xFFAC4854)
        ],
        stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: const Icon(
                Icons.delete,
                color: Color(0xFFFAF7F8)
              ),
            ),
          ),
        )
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
  margin: EdgeInsets.zero,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  decoration: BoxDecoration(
color: widget.backgroundColor ?? theme.cardColor.withOpacity(0.9),
borderRadius: BorderRadius.only(
  topLeft: Radius.circular(widget.isFirst ? 16 : 0),
  topRight: Radius.circular(widget.isFirst ? 16 : 0),
  bottomLeft: Radius.circular(widget.isLast ? 16 : 0),
  bottomRight: Radius.circular(widget.isLast ? 16 : 0),
),
border: widget.isLast
    ? null
    : Border(
        bottom: BorderSide(
          color: theme.dividerColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
    boxShadow: [
      BoxShadow(
    color: theme.shadowColor.withOpacity(0.0),
        blurRadius: 0,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: Row(
    children: [

      /// 🔥 ICON
Container(
  margin: const EdgeInsets.only(right: 12),
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: cat?.color ?? theme.primaryColor, // 🎨 fond = couleur catégorie
  ),
  child: Icon(
    cat?.icon ?? Icons.category,
    color: Colors.white, // ⚪ icône blanche
    size: 18,
  ),
),

      /// 🔥 TEXTES
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// titre
Row(
  mainAxisSize: MainAxisSize.min, // 🔥 IMPORTANT
  children: [
    Flexible( // 👈 au lieu de Expanded
      child: Text(
        t.title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyMedium?.color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ),

    const SizedBox(width: 4),

    Icon(
      (previewChecked ?? t.isChecked)
          ? Icons.check_rounded

          : Icons.close_rounded,
      size: 15,
      color: (previewChecked ?? t.isChecked)
          ? AppColors.success
          : AppColors.danger,
    ),
  ],
),

            const SizedBox(height: 4),

            /// sous texte
Text(
  _formatDate(t.date),
  style: TextStyle(
    fontSize: 10,
    color: theme.textTheme.bodySmall?.color,
  ),
),
          ],
        ),
      ),

      /// 🔥 MONTANT
Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [

    /// 💰 MONTANT
    Text(
      "${t.isIncome ? "+" : "-"}${t.amount.toStringAsFixed(2)}€",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.textTheme.bodyMedium?.color,
      ),
    ),

    const SizedBox(height: 2),

    /// 🏷️ CATÉGORIE (même couleur que l’icône)
    Text(
      t.category ?? "",
      style: TextStyle(
        fontSize: 10,
        color: cat?.color ?? theme.primaryColor,
        fontWeight: FontWeight.w500,
      ),
    ),
  ],
),
const SizedBox(width: 8),

Icon(
  Icons.chevron_right,
  size: 20,
color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
),
    ],
  ),
)
  ],
    ),
  );
}
}
String _formatDate(DateTime date) {
  const months = [
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    "Juin",
    "Juillet",
    "Août",
    "Septembre",
    "Octobre",
    "Novembre",
    "Décembre"
  ];

  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return "${date.day} ${months[date.month - 1]} à $hour:$minute";
}