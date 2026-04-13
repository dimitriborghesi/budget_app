import 'dart:async';
import '../../../core/services/bank_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction.dart';
import '../../../core/services/notification_service.dart'; // 🔥 AJOUT

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  StreamSubscription? _sub;

  /// 🔥 STREAM LIVE
  void loadTransactions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _sub?.cancel();

    _sub = _db
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs
          .map((doc) =>
              TransactionModel.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    });
  }

  /// ➕ ADD + NOTIF + BALANCE
  Future<void> add({
  required String title,
  required double amount,
  required String account,
  required String category,
  required bool isIncome,
}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _db.collection('transactions').add({
        "title": title,
        "amount": amount,
        "account": account,
        "category": category,
        "isIncome": isIncome,
        "date": DateTime.now(),
        "userId": user.uid,
      });

      /// 🔥 UPDATE BALANCE
      final accounts = await _db
          .collection('accounts')
          .where('userId', isEqualTo: user.uid)
          .where('name', isEqualTo: account)
          .get();

      for (var doc in accounts.docs) {
        await doc.reference.update({
          'balance': FieldValue.increment(
            isIncome ? amount : -amount,
          ),
        });
      }

      /// 🔔 NOTIFICATION AUTO
      await NotificationService.transaction(
        title: title,
        amount: amount,
        isIncome: isIncome,
      );
    } catch (e) {
      debugPrint("Erreur ADD transaction: $e");
    }
  }

  /// ❌ DELETE
  Future<void> delete(TransactionModel transaction) async {
    try {
      await _db
          .collection('transactions')
          .doc(transaction.id)
          .delete();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final value = transaction.isIncome
          ? -transaction.amount
          : transaction.amount;

      final accounts = await _db
          .collection('accounts')
          .where('userId', isEqualTo: user.uid)
          .where('name', isEqualTo: transaction.account)
          .get();

      for (var doc in accounts.docs) {
        await doc.reference.update({
          'balance': FieldValue.increment(value),
        });
      }
    } catch (e) {
      debugPrint("Erreur DELETE transaction: $e");
    }
  }

  /// ✏️ UPDATE
  Future<void> update(TransactionModel transaction) async {
    try {
      await _db
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      debugPrint("Erreur UPDATE transaction: $e");
    }
  }

  /// 🔄 LOAD
  Future<void> load(String uid) async {
    final snapshot = await _db
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .get();

    _transactions = snapshot.docs
        .map((doc) =>
            TransactionModel.fromMap(doc.data(), doc.id))
        .toList();

    notifyListeners();
  }

  /// 🧹 CLEAN
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
    // 🔥 MATCHING
  bool _isMatch(TransactionModel local, BankTransaction bank) {
    final amountMatch =
        (local.amount - bank.amount.abs()).abs() < 1.0;

    final dateMatch =
        local.date.difference(bank.date).inDays.abs() <= 2;

    final titleMatch = bank.title
        .toLowerCase()
        .contains(local.title.toLowerCase());

    return amountMatch && dateMatch && titleMatch;
  }

  // 🔥 SYNC BANQUE
  Future<void> syncBank() async {
  try {
    final bankService = BankService();
    final bankTransactions = await bankService.fetchTransactions();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    for (var bank in bankTransactions) {
      // 🔥 CHECK SI DEJA EXISTE
      final existing = await _db
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .where('bankId', isEqualTo: bank.id)
          .get();

      if (existing.docs.isNotEmpty) {
        continue; // ⛔ skip doublon
      }

      bool matched = false;

      for (var local in _transactions) {
        if (local.bankId != null) continue;

        if (_isMatch(local, bank)) {
          await _db
              .collection('transactions')
              .doc(local.id)
              .update({
            "isChecked": true,
            "bankId": bank.id,
            "isSynced": true,
          });

          matched = true;
          break;
        }
      }

      if (!matched) {
        await _db.collection('transactions').add({
          "title": bank.title,
          "amount": bank.amount.abs(),
          "account": "Principal",
          "category": _autoCategory(bank.title),
          "isIncome": bank.amount > 0,
          "date": bank.date,
          "userId": user.uid,
          "isChecked": true,
          "bankId": bank.id,
          "isSynced": true,
        });
      }
    }

    await NotificationService.simple(
      title: "Synchronisation",
      body: "Transactions mises à jour 💳",
    );

    debugPrint("✅ Sync sans doublon");
  } catch (e) {
    debugPrint("❌ Erreur sync banque: $e");
  }
}

  _autoCategory(String title) {}

  void updateTransaction(t) {}

  void deleteTransaction(id) {}
}