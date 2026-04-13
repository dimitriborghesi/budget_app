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
      icon: IconData(map['icon'] ?? Icons.account_balance.codePoint,
          fontFamily: 'MaterialIcons'),
      color: map['color'] ?? 0xFF799C0A,
    );
  }
}