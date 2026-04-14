import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/category_provider.dart';

class CreateCategoryScreen extends StatefulWidget {
  final bool isIncome;

  const CreateCategoryScreen({super.key, required this.isIncome});

  @override
  State<CreateCategoryScreen> createState() =>
      _CreateCategoryScreenState();
}

class _CreateCategoryScreenState
    extends State<CreateCategoryScreen> {
  final nameController = TextEditingController();

  IconData selectedIcon = Icons.category;
  Color selectedColor = Colors.blue;

  final icons = [

  /// 🏠 LIFE
  Icons.home,
  Icons.apartment,
  Icons.chair,
  Icons.bed,

  /// 🚗 TRANSPORT
  Icons.directions_car,
  Icons.local_gas_station,
  Icons.train,
  Icons.flight,
  Icons.directions_bus,

  /// 🛒 SHOPPING
  Icons.shopping_cart,
  Icons.store,
  Icons.shopping_bag,

  /// 🍔 FOOD
  Icons.restaurant,
  Icons.fastfood,
  Icons.local_cafe,
  Icons.icecream,

  /// 💼 WORK
  Icons.work,
  Icons.business,
  Icons.laptop,
  Icons.build,

  /// 🎮 FUN
  Icons.sports_esports,
  Icons.movie,
  Icons.music_note,
  Icons.sports_soccer,

  /// ❤️ LIFE
  Icons.favorite,
  Icons.pets,
  Icons.child_care,

  /// 💰 MONEY
  Icons.attach_money,
  Icons.savings,
  Icons.account_balance,

  /// ⭐ BONUS
  Icons.star,
  Icons.card_giftcard,
];

  final colors = [

  /// 🔴 ROUGE
  Color(0xFFEF4444),
  Color(0xFFDC2626),
  Color(0xFFB91C1C),

  /// 🟠 ORANGE
  Color(0xFFF97316),
  Color(0xFFEA580C),
  Color(0xFFC2410C),

  /// 🟡 JAUNE
  Color(0xFFEAB308),
  Color(0xFFFACC15),
  Color(0xFFCA8A04),

  /// 🟢 VERT
  Color(0xFF22C55E),
  Color(0xFF16A34A),
  Color(0xFF15803D),

  /// 🟢 LIME
  Color(0xFF84CC16),
  Color(0xFF65A30D),

  /// 🔵 CYAN
  Color(0xFF06B6D4),
  Color(0xFF0891B2),

  /// 🔵 BLEU
  Color(0xFF3B82F6),
  Color(0xFF2563EB),
  Color(0xFF1D4ED8),

  /// 🟣 INDIGO
  Color(0xFF6366F1),
  Color(0xFF4F46E5),

  /// 🟣 VIOLET
  Color(0xFFA855F7),
  Color(0xFF9333EA),

  /// 🌸 ROSE
  Color(0xFFEC4899),
  Color(0xFFDB2777),

];

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CategoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Nouvelle catégorie"),
      ),
      body: SingleChildScrollView(
  padding: EdgeInsets.only(
    left: 20,
    right: 20,
    bottom: MediaQuery.of(context).viewInsets.bottom,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

            /// 🔥 PREVIEW
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selectedColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(selectedIcon,
                      color: selectedColor, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    nameController.text.isEmpty
                        ? "Nom catégorie"
                        : nameController.text,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// INPUT
            TextField(
              controller: nameController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Nom",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2C2C2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ICONS
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Icône",
                  style: TextStyle(color: Colors.grey)),
            ),

            const SizedBox(height: 10),

            Wrap(
  spacing: 10,
  children: colors.map((c) {
    final selected = selectedColor == c;

    return GestureDetector(
      onTap: () {
        setState(() => selectedColor = c);
      },
      child: AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  transform: selected
      ? (Matrix4.identity()..scale(1.2))
      : Matrix4.identity(),

        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,

          /// 🔥 BORDER
          border: selected
              ? Border.all(color: Colors.white, width: 2)
              : null,

          /// 🔥 BONUS SHADOW
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: c.withOpacity(0.6),
                    blurRadius: 8,
                  )
                ]
              : [],
        ),
      ),
    );
  }).toList(),
),

            const SizedBox(height: 20),

            /// COLORS
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Couleur",
                  style: TextStyle(color: Colors.grey)),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: colors.map((c) {
                final selected = selectedColor == c;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedColor = c);
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: Colors.white, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

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
                onPressed: () {
                  if (nameController.text.isEmpty) return;

                  provider.addCategory(
                    CategoryModel(
                      name: nameController.text,
                      icon: selectedIcon,
                      color: selectedColor,
                      isIncome: widget.isIncome,
                    ),
                  );

                  Navigator.pop(context);
                },
                child: const Text("Créer",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}