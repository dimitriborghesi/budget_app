import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final IconData icon;
  final Color color;
  final bool isIncome;

  CategoryModel({
    required this.name,
    required this.icon,
    required this.color,
    required this.isIncome,
  });
}

class CategoryProvider with ChangeNotifier {
  final List<CategoryModel> _categories = [

    /// 🔥 DEPENSES
    CategoryModel(name: "Courses", icon: Icons.shopping_cart, color: Colors.green, isIncome: false),
    CategoryModel(name: "Maison", icon: Icons.home, color: Colors.brown, isIncome: false),
    CategoryModel(name: "Voyage", icon: Icons.flight, color: Colors.blue, isIncome: false),
    CategoryModel(name: "Travaux", icon: Icons.construction, color: Colors.orange, isIncome: false),
    CategoryModel(name: "Essence", icon: Icons.local_gas_station, color: Colors.red, isIncome: false),
    CategoryModel(name: "Assurance", icon: Icons.security, color: Colors.indigo, isIncome: false),
    CategoryModel(name: "Voiture", icon: Icons.directions_car, color: Colors.blueGrey, isIncome: false),
    CategoryModel(name: "Santé", icon: Icons.favorite, color: Colors.pink, isIncome: false),
    CategoryModel(name: "Loisirs", icon: Icons.sports_esports, color: Colors.purple, isIncome: false),
    CategoryModel(name: "Restaurant", icon: Icons.restaurant, color: Colors.deepOrange, isIncome: false),
    CategoryModel(name: "Factures", icon: Icons.receipt_long, color: Colors.grey, isIncome: false),
    CategoryModel(name: "Abonnements", icon: Icons.subscriptions, color: Colors.cyan, isIncome: false),

    /// 🔥 REVENUS
    CategoryModel(name: "Salaire", icon: Icons.work, color: Colors.green, isIncome: true),
    CategoryModel(name: "Freelance", icon: Icons.laptop_mac, color: Colors.blue, isIncome: true),
    CategoryModel(name: "Investissement", icon: Icons.trending_up, color: Colors.teal, isIncome: true),
    CategoryModel(name: "Cadeau", icon: Icons.card_giftcard, color: Colors.orange, isIncome: true),
    CategoryModel(name: "Bonus", icon: Icons.star, color: Colors.amber, isIncome: true),
  ];

  List<CategoryModel> getByType(bool isIncome) =>
      _categories.where((c) => c.isIncome == isIncome).toList();

  CategoryModel? getByName(String name) {
    try {
      return _categories.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }

  void addCategory(CategoryModel c) {
    _categories.add(c);
    notifyListeners();
  }
}