import 'package:flutter/material.dart';

class Account {
  String id;
  String name;
  double balance;
  String userId;
  IconData icon;
  int color;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.userId,
    required this.icon,
    required this.color,
  });

  factory Account.fromMap(Map<String, dynamic> map, String id) {
    return Account(
      id: id,
      name: map['name'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
      userId: map['userId'] ?? '',
      icon: _getIcon(map['icon']),
      color: map['color'] ?? 0xFF799C0A,
    );
  }
}
IconData _getIcon(dynamic iconCode) {
  switch (iconCode) {
    case 0xe88a: // home
      return Icons.home;
    case 0xe87d: // star
      return Icons.star;
    case 0xe7fd: // person
      return Icons.person;
    case 0xe263: // wallet
      return Icons.account_balance_wallet;
    default:
      return Icons.account_balance;
  }
}