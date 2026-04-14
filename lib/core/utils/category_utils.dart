import 'package:flutter/material.dart';

Color getCategoryColor(String category) {
  final c = category.toLowerCase();

  if (c.contains("course")) return Colors.green;
  if (c.contains("sant")) return Colors.pink;
  if (c.contains("loisir")) return Colors.purple;
  if (c.contains("transport") || c.contains("uber"))
    return Colors.blue;
  if (c.contains("voiture")) return Colors.indigo;
  if (c.contains("restaurant")) return Colors.deepOrange;
  if (c.contains("facture")) return Colors.grey;

  if (c.contains("salaire")) return Colors.green;
  if (c.contains("remboursement")) return Colors.blue;
  if (c.contains("anniversaire")) return Colors.orange;
  if (c.contains("don")) return Colors.teal;

  return Colors.white;
}

IconData getCategoryIcon(String category) {
  final c = category.toLowerCase();

  if (c.contains("course")) return Icons.shopping_cart;
  if (c.contains("sant")) return Icons.favorite;
  if (c.contains("loisir")) return Icons.sports_esports;
  if (c.contains("transport") || c.contains("uber"))
    return Icons.directions_bus;
  if (c.contains("voiture")) return Icons.directions_car;
  if (c.contains("restaurant")) return Icons.restaurant;
  if (c.contains("facture")) return Icons.receipt_long;

  if (c.contains("salaire")) return Icons.work;
  if (c.contains("remboursement")) return Icons.reply;
  if (c.contains("anniversaire")) return Icons.cake;
  if (c.contains("don")) return Icons.volunteer_activism;

  return Icons.category;
}