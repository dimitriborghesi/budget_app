import 'package:cloud_firestore/cloud_firestore.dart';

class Recurring {
  final String id;
  final String title;
  final double amount;
  final String account;
  final String category;
  final bool isIncome;
  final int day;
  final int interval;
  final DateTime? lastRun;
  final bool enabled;
  bool done;

  Recurring({
    required this.id,
    required this.title,
    required this.amount,
    required this.account,
    required this.category,
    required this.isIncome,
    required this.interval, // 🔥 AJOUT ICI
    required this.day,
    this.done = false,
    this.lastRun,
    this.enabled = true,
  });

  factory Recurring.fromMap(String id, Map<String, dynamic> data) {
    return Recurring(
      id: id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      account: data['account'] ?? '',
      category: data['category'] ?? '',
      isIncome: data['isIncome'] ?? false,
      day: data['day'] ?? 1,
      interval: data['interval'] ?? 1,
      done: data['done'] ?? false, // 🔥 FIX
      lastRun: data['lastRun'] != null
          ? (data['lastRun'] as Timestamp).toDate()
          : null,
      enabled: data['enabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'account': account,
      'category': category,
      'isIncome': isIncome,
      'day': day,
      'done': done, // 🔥 FIX
      'lastRun': lastRun,
      'enabled': enabled,
      "interval": interval,
    };
  }
}