import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/account.dart';

class AccountProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Account> _accounts = [];
  List<Account> get accounts => _accounts;

  // ✅ AJOUT HISTORIQUE
  List<Map<String, dynamic>> _transfers = [];
  List<Map<String, dynamic>> get transfers => _transfers;

  // 🔄 LOAD
  void loadAccounts() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // ACCOUNTS
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

    // TRANSFERS
    _db
        .collection('transfers')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _transfers = snapshot.docs.map((doc) => doc.data()).toList();
      notifyListeners();
    });
  }

  // ➕ ADD ACCOUNT
  Future<void> addAccount(String name, IconData icon, Color color) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await _db.collection('accounts').add({
    'name': name,
    'balance': 0,
    'userId': user.uid,
    'icon': icon.codePoint,
    'color': color.value,
  });
}

  // ➕ swipe delete
Future<void> deleteAccount(String id) async {
  await _db.collection('accounts').doc(id).delete();
}

  // 🔁 TRANSFER COMPLET (5 PARAMS)
  Future<void> transfer(
    Account from,
    Account to,
    double amount,
    String label,
    String description,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (from.balance < amount) return;

    // UPDATE BALANCE
    await _db.collection('accounts').doc(from.id).update({
      'balance': FieldValue.increment(-amount),
    });

    await _db.collection('accounts').doc(to.id).update({
      'balance': FieldValue.increment(amount),
    });

    // SAVE HISTORY
    await _db.collection('transfers').add({
      'from': from.name,
      'to': to.name,
      'amount': amount,
      'label': label,
      'description': description,
      'userId': user.uid,
      'date': Timestamp.now(),
    });
  }
}