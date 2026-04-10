import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/account.dart';

class AccountProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Account> _accounts = [];
  List<Account> get accounts => _accounts;

  void loadAccounts(String uid) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _db
        .collection('accounts')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      _accounts = snapshot.docs
          .map((doc) => Account.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    });
  }

  Future<void> addAccount(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.collection('accounts').add({
      'name': name,
      'balance': 0,
      'userId': user.uid,
    });
  }

  /// 🔥 FIX ERREUR transfer
  Future<void> transfer(Account from, Account to, double amount) async {
    if (from.balance < amount) return;

    await _db.collection('accounts').doc(from.id).update({
      'balance': FieldValue.increment(-amount),
    });

    await _db.collection('accounts').doc(to.id).update({
      'balance': FieldValue.increment(amount),
    });
  }

  Future<void> load(String uid) async {}
}