import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_popup.dart';
import '../widgets/transaction_card.dart';
import '../../../core/providers/category_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:budget_app/core/theme/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {

  String? selectedCategory;

  double previousTotal = 0;

  int selectedIndex = 1;

  DateTime selectedDate = DateTime.now();

  bool isSnapping = false;

final ScrollController _scrollController = ScrollController();
bool isCollapsed = false;

@override
void initState() {
  super.initState();

_scrollController.addListener(() {
  if (isSnapping) return;

  final offset = _scrollController.offset;

  const double expandThreshold = 40;   // retour donut
  const double collapseThreshold = 120; // passage barre

  /// 🔥 COLLAPSE (donut → barre)
  if (offset > collapseThreshold && !isCollapsed) {
    isSnapping = true;

    setState(() => isCollapsed = true);

    _scrollController.animateTo(
      collapseThreshold,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    ).then((_) => isSnapping = false);
  }

  /// 🔥 EXPAND (barre → donut)
  else if (offset < expandThreshold && isCollapsed) {
    isSnapping = true;

    setState(() => isCollapsed = false);

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    ).then((_) => isSnapping = false);
  }
});
}

void _showCategoryDetails(String category, List transactions) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true, // 🔥 tap outside
    barrierLabel: "",
    barrierColor: Colors.black.withOpacity(0.25), // 🔥 blur feel
    transitionDuration: const Duration(milliseconds: 300),

    pageBuilder: (_, __, ___) {
      return StatefulBuilder(
        builder: (context, setLocalState) {

          String search = "";

          final filtered = transactions.where((t) {
            return t.title.toLowerCase().contains(search.toLowerCase());
          }).toList();

          final total = filtered.fold<double>(
            0,
            (s, e) => s + e.amount,
          );

return Material(
  color: Colors.transparent,
  child: Stack(
    children: [

      /// 🔥 TAP OUTSIDE (IMPORTANT)
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black.withOpacity(0.0),
        ),
      ),

      /// 🔥 POPUP
      Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(top: 80),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// HANDLE
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                /// TITLE + TOTAL
                Column(
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${total.toStringAsFixed(2)} €",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// SEARCH
                TextField(
                  onChanged: (value) {
                    setLocalState(() {
                      search = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Rechercher...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).dividerColor.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// LIST
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final t = filtered[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).cardColor,
                          child: const Icon(Icons.shopping_cart),
                        ),
                        title: Text(t.title),
                        subtitle: Text("${t.date.day}/${t.date.month}"),
                        trailing: Text(
                          "-${t.amount.toStringAsFixed(2)} €",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
);
        },
      );
    },

    /// 🔥 ANIMATION iOS STYLE
    transitionBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

Widget _tabs() {
  final tabs = ["Semaine", "Mois", "Trimestre", "Année"];

  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth / tabs.length;

      return Container(
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
color: Theme.of(context).dividerColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [

            /// 🔥 SLIDER ANIMÉ
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              left: selectedIndex * width,
              top: 0,
              bottom: 0,
              width: width,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            /// 🔥 TEXT
            Row(
              children: List.generate(tabs.length, (index) {
                final isActive = index == selectedIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isActive
  ? Theme.of(context).textTheme.bodyMedium!.color
  : Theme.of(context).textTheme.bodySmall!.color,
                        ),
                        child: Text(tabs[index]),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    },
  );
}

  String get periodLabel {
  switch (selectedIndex) {

    /// 📅 SEMAINE
    case 0:
      final start = selectedDate.subtract(
        Duration(days: selectedDate.weekday - 1),
      );
      final end = start.add(const Duration(days: 6));

      return "${start.day} ${_monthName(start.month)} → ${end.day} ${_monthName(end.month)}";

    /// 📅 MOIS
    case 1:
      return "${_monthName(selectedDate.month)} ${selectedDate.year}";

    /// 📅 TRIMESTRE
    case 2:
      final quarter = ((selectedDate.month - 1) ~/ 3);
      final startMonth = quarter * 3 + 1;
      final endMonth = startMonth + 2;

      return "${_monthName(startMonth)} → ${_monthName(endMonth)} ${selectedDate.year}";

    /// 📅 ANNÉE
    case 3:
      return "${selectedDate.year}";
  }

  return "";
}

  Widget _circleButton(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Icon(icon, size: 16),
    ),
  );
}

  Widget _iosHeader() {
  final tabs = ["Semaine", "Mois", "Trimestre", "Année"];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// 🔝 TITLE + MENU

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      "Dépenses",
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    ),

    Row(
      children: [

        /// 🔥 MENU (...)

        const SizedBox(width: 8),

        /// 📅 CALENDAR BUTTON (🔥 IMPORTANT)
Row(
  children: [
    _circleButton(Icons.more_horiz, () {}),
  ],
),
      ],
    )
  ],
),

      const SizedBox(height: 16),


      /// 🔥 TABS (Semaine / Mois / ...)
Row(
  children: [

    /// 🔥 TABS
    Expanded(child: _tabs()),

    const SizedBox(width: 8),

    /// 📅 CALENDAR BUTTON (à droite comme ton screen)
GestureDetector(
  onTap: _openCalendar,
  child: Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor, // 👈 même fond que circle
      borderRadius: BorderRadius.circular(12),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: const Icon(Icons.calendar_today, size: 18),
  ),
),
  ],
),

      const SizedBox(height: 3),

      /// 🔥 DATE NAVIGATION
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// ⬅️
          IconButton(
            icon: const Icon(Icons.chevron_left),
onPressed: () {
  setState(() {
    switch (selectedIndex) {
      case 0: // semaine
        selectedDate = selectedDate.subtract(const Duration(days: 7));
        break;
      case 1: // mois
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month - 1,
        );
        break;
      case 2: // trimestre
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month - 3,
        );
        break;
      case 3: // année
        selectedDate = DateTime(
          selectedDate.year - 1,
          selectedDate.month,
        );
        break;
    }
  });
},
          ),

          /// 📅 DATE
Center(
  child: GestureDetector(
    child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      periodLabel,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ],
),
  ),
),

          /// ➡️
          IconButton(
            icon: const Icon(Icons.chevron_right),
onPressed: () {
  setState(() {
    switch (selectedIndex) {
      case 0:
        selectedDate = selectedDate.add(const Duration(days: 7));
        break;
      case 1:
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month + 1,
        );
        break;
      case 2:
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month + 3,
        );
        break;
      case 3:
        selectedDate = DateTime(
          selectedDate.year + 1,
          selectedDate.month,
        );
        break;
    }
  });
},
          ),
        ],
      ),
    ],
  );
}

void _openCalendar() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Container(
        margin: const EdgeInsets.only(top: 80),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// 🔥 HANDLE (petit trait iOS)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            /// 📅 CALENDAR
TableCalendar(
  firstDay: DateTime(2020),
  lastDay: DateTime.now(),
  focusedDay: selectedDate,

  selectedDayPredicate: (day) => isSameDay(day, selectedDate),

  onDaySelected: (selectedDay, focusedDay) {
    setState(() {
      selectedDate = selectedDay;
    });

    Navigator.pop(context);
  },

  headerStyle: const HeaderStyle(
    titleCentered: true,
    formatButtonVisible: false,
  ),

  calendarStyle: CalendarStyle(
    todayDecoration: BoxDecoration(
      color: Colors.grey.withOpacity(0.3),
      shape: BoxShape.circle,
    ),

    selectedDecoration: BoxDecoration(
      color: Theme.of(context).primaryColor,
      shape: BoxShape.circle,
    ),
  ),
),

            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

 final expenses = provider.transactions.where((t) {
  if (t.isIncome) return false;

  switch (selectedIndex) {

    /// 🗓 SEMAINE
    case 0:
      final start = selectedDate.subtract(
        Duration(days: selectedDate.weekday - 1),
      );
      final end = start.add(const Duration(days: 6));

      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
             t.date.isBefore(end.add(const Duration(days: 1)));

    /// 📅 MOIS
    case 1:
      return t.date.month == selectedDate.month &&
             t.date.year == selectedDate.year;

    /// 📊 TRIMESTRE
    case 2:
      final quarter = ((selectedDate.month - 1) ~/ 3);
      final startMonth = quarter * 3 + 1;
      final endMonth = startMonth + 2;

      return t.date.year == selectedDate.year &&
             t.date.month >= startMonth &&
             t.date.month <= endMonth;

    /// 📆 ANNÉE
    case 3:
      return t.date.year == selectedDate.year;
  }

if (selectedCategory != null) {
  return t.category == selectedCategory;
}
if (selectedCategory != null && t.category != selectedCategory) {
  return false;
}
  return false;
  
}).toList();

final grouped = _groupByCategory(expenses);
final categoryProvider = context.read<CategoryProvider>();

    final total = expenses.fold<double>(0, (s, e) => s + e.amount);
    WidgetsBinding.instance.addPostFrameCallback((_) {
  previousTotal = total;
});

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddTransactionPopup(isIncome: false),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

body: SafeArea(
  child: Column(
  children: [

    /// 🔝 FIXE
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _iosHeader(),
    ),

    const SizedBox(height: 10),

    /// 💰 FIXE
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _totalCard(total),
    ),

    const SizedBox(height: 10),

    /// 🍩 FIXE (reactif)
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _categorySection(expenses),
    ),

    const SizedBox(height: 10),

        /// 🔥 TITRE FIXE
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
       child: Align(
    alignment: Alignment.centerLeft,
      child: Text(
        "Liste des dépenses",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    ),
    ),

    const SizedBox(height: 10),

    /// 📜 SCROLL
    Expanded(
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [

          const SizedBox(height: 10),

          _transactions(expenses),

          const SizedBox(height: 80),
        ],
      ),
    ),
  ],
)
),
    );
  }

  // ================= UI =================

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Dépenses",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Row(
  children: [
    _circleButton(Icons.more_horiz, () {}),
    const SizedBox(width: 8),
  ],
)
      ],
    );
  }

Widget _totalCard(double total) {
  return Container(
      width: double.infinity, // 🔥 AJOUTE ÇA
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).shadowColor.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Total des dépenses",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 5),
TweenAnimationBuilder<double>(
  tween: Tween<double>(
    begin: previousTotal,
    end: total,
  ),
  duration: const Duration(milliseconds: 500),
  curve: Curves.easeOutCubic,
  builder: (context, value, _) {
    return Text(
      "${value.toStringAsFixed(2)} €",
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
    );
  },
),
      ],
    ),
  );
}

Widget _categorySection(List expenses) {
  final grouped = _groupByCategory(expenses);

  final sorted = grouped.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final top5 = sorted.take(5).toList();
  final hasMore = sorted.length > 5;

return AnimatedContainer(
  duration: const Duration(milliseconds: 220),
  curve: Curves.easeOut,
  height: isCollapsed ? 40 : 180, // 👈 plus petit
padding: EdgeInsets.symmetric(
  horizontal: 12,
  vertical: isCollapsed ? 6 : 12, // 👈 moins de hauteur
),
  clipBehavior: Clip.hardEdge, // 🔥 FIX OVERFLOW
  decoration: BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(12),
  ),

  child: Stack(
    alignment: Alignment.center,
    children: [

      /// 🍩 DONUT (disparaît RAPIDE)
      AnimatedOpacity(
        duration: const Duration(milliseconds: 100), // 👈 rapide
        opacity: isCollapsed ? 0 : 1,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: isCollapsed ? 0.7 : 1,
          child: Row(
            children: [
              SizedBox(
                height: 130, // 👈 réduit pour éviter overflow
                width: 150,
                child: PieChart(
                  PieChartData(
                    sections: _buildSections(expenses),
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(width: 12),
Flexible(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    
    children: [
      ...top5.map((e) => _categoryRow(e.key, e.value)),

      if (hasMore && !isCollapsed)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: GestureDetector(
            onTap: () {
              _showCategoryDetails(
                "Toutes les catégories",
                expenses,
              );
            },
            child: Text(
              "Voir plus",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
    ],
  ),
),
            ],
          ),
        ),
      ),

      /// 📊 BAR (arrive après + s’étire)
      AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: isCollapsed ? 1 : 0,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          tween: Tween(
            begin: isCollapsed ? 0.3 : 1,
            end: isCollapsed ? 1 : 0.3,
          ),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.scale(
              scaleX: value, // 👈 étirement horizontal
              child: child,
            );
          },
          child: SizedBox(
            height: 6,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: _simpleCategoryBar(expenses),
            ),
          ),
        ),
      ),
    ],
  ),
);
}

Widget _categoryRow(String label, double amount) {
  final categoryProvider = context.read<CategoryProvider>();
  final cat = categoryProvider.getByName(label);
  final color = cat?.color ?? Theme.of(context).primaryColor;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        /// 🔵 DOT
        Container(
          width: 45,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 1),

        /// 🔥 LABEL ALIGNÉ
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),

        /// 💰 MONTANT ALIGNÉ À DROITE
        Text(
          "${amount.toStringAsFixed(0)} €",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _transactions(List expenses) {
  final now = DateTime.now();

  /// 🔥 TRI DESC (plus récent en haut)
  expenses.sort((a, b) => b.date.compareTo(a.date));

  /// 🔥 GROUP BY DATE
  Map<String, List> grouped = {};

  for (var t in expenses) {
    final date = DateTime(t.date.year, t.date.month, t.date.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String label;

    if (date == today) {
      label = "Aujourd’hui";
    } else if (date == yesterday) {
      label = "Hier";
    } else {
      label = "${t.date.day} ${_monthName(t.date.month)}";
    }

    if (!grouped.containsKey(label)) {
      grouped[label] = [];
    }

    grouped[label]!.add(t);
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// 🔥 RENDER GROUPS
      ...grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🗓 HEADER (Aujourd’hui / Hier / ...)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey
                ),
              ),
            ),

            /// 📄 TRANSACTIONS
...entry.value.asMap().entries.map((item) {
  final index = item.key;
  final t = item.value;

  return TransactionCard(
    t: t,
    isExpense: !t.isIncome,
    isFirst: index == 0,
    isLast: index == entry.value.length - 1,
  );
}),
          ],
        );
      }),
    ],
  );
}

  // ================= LOGIC =================

  Map<String, double> _groupByCategory(List expenses) {
    final Map<String, double> totals = {};

    for (var e in expenses) {
      final cat = e.category ?? "Autres";
      totals[cat] = (totals[cat] ?? 0) + e.amount;
    }

    return totals;
  }

List<PieChartSectionData> _buildSections(List expenses) {
  final grouped = _groupByCategory(expenses);
  final total = grouped.values.fold<double>(
    0.0,
    (sum, value) => sum + value,
  );

  final categoryProvider = context.read<CategoryProvider>();

  return grouped.entries.map((e) {
    final cat = categoryProvider.getByName(e.key);

    return PieChartSectionData(
      value: e.value,
      color: cat?.color ?? Theme.of(context).primaryColor,
      radius: 30,
      title: "",
    );
  }).toList();
}

  BoxDecoration _card() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
    );
  }

  String _monthName(int month) {
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
    return months[month - 1];
  }
  Widget _simpleCategoryBar(List expenses) {
  final grouped = _groupByCategory(expenses);

  final total = grouped.values.fold<double>(
    0.0,
    (a, b) => a + b,
  );

  final categoryProvider = context.read<CategoryProvider>();

  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Row(
      children: grouped.entries.map((e) {
        final cat = categoryProvider.getByName(e.key);
        final color = cat?.color ?? Colors.grey;

        final percent = total == 0 ? 0 : e.value / total;

        return Expanded(
          flex: (percent * 1000).clamp(1, 1000).toInt(),
          child: Container(
            height: 6,
            color: color,
          ),
        );
      }).toList(),
    ),
  );
}
}