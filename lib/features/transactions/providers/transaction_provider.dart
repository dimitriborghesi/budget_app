import 'dart:async';

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
}