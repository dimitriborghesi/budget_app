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
      icon: _iconFromCode(map['icon']),
      color: map['color'] ?? 0xFF799C0A,
    );
  }
}
IconData _iconFromCode(dynamic code) {
  const icons = {
    0xe88a: Icons.home,
    0xe87d: Icons.star,
    0xe7fd: Icons.person,
    0xe263: Icons.account_balance_wallet,
    0xe84f: Icons.settings,
    0xe850: Icons.account_balance,
  };

  return icons[code] ?? Icons.account_balance;
}
