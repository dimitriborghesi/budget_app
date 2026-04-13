import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String id;
  String title;
  double amount;
  bool isIncome;
  String category;
  String account;
  DateTime date;
  String userId;
  bool isChecked;

  // 🔥 NEW
  String? bankId;
  bool isSynced;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.account,
    required this.date,
    required this.userId,
    this.isChecked = false,
    this.bankId,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'isIncome': isIncome,
      'category': category,
      'account': account,
      'date': Timestamp.fromDate(date),
      'userId': userId,
      'isChecked': isChecked,

      // 🔥 NEW
      'bankId': bankId,
      'isSynced': isSynced,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      isIncome: map['isIncome'] ?? false,
      category: map['category'] ?? '',
      account: map['account'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      isChecked: map['isChecked'] ?? false,

      // 🔥 NEW
      bankId: map['bankId'],
      isSynced: map['isSynced'] ?? false,
    );
  }
}