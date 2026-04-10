import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recurring.dart';
import '../../../core/services/notification_service.dart';

class RecurringProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Recurring> recurring = [];

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  /// LOAD
  Future<void> load() async {
    final snap = await _db
        .collection('recurring')
        .where('userId', isEqualTo: userId)
        .get();

    recurring = snap.docs
        .map((d) => Recurring.fromMap(d.id, d.data()))
        .toList();

    notifyListeners();
  }

  /// ADD
  Future<void> add(Recurring r) async {
    await _db.collection('recurring').add({
      ...r.toMap(),
      "userId": userId,
    });

    await load();
  }

  /// DELETE
  Future<void> delete(String id) async {
    await _db.collection('recurring').doc(id).delete();
    await load();
  }

  /// RESTORE 🔥
  Future<void> restore(Recurring r) async {
    await _db.collection('recurring').add({
      ...r.toMap(),
      "userId": userId,
    });

    await load();
  }

  /// TOGGLE
  Future<void> toggle(Recurring r) async {
    await _db.collection('recurring').doc(r.id).update({
      "enabled": !r.enabled,
    });

    await load();
  }

  /// AUTO RUN
  Future<void> run() async {
    final now = DateTime.now();

    for (var r in recurring) {
      if (!r.enabled) continue;

      final alreadyRun = r.lastRun != null &&
          r.lastRun!.month == now.month &&
          r.lastRun!.year == now.year;

      if (r.day == now.day && !alreadyRun) {
        await _db.collection('transactions').add({
          "title": r.title,
          "amount": r.amount,
          "account": r.account,
          "category": r.category,
          "isIncome": r.isIncome,
          "date": now,
          "userId": userId,
        });

        final acc = await _db
            .collection('accounts')
            .where('userId', isEqualTo: userId)
            .where('name', isEqualTo: r.account)
            .get();

        for (var doc in acc.docs) {
          await doc.reference.update({
            "balance": FieldValue.increment(
              r.isIncome ? r.amount : -r.amount,
            ),
          });
        }

        await NotificationService.recurring(
          title: r.title,
          amount: r.amount,
          isIncome: r.isIncome,
        );

        await _db.collection('recurring').doc(r.id).update({
          "lastRun": now,
        });
      }
    }

    await load();
  }

  /// UPDATE 🔥 FIX
Future<void> update(Recurring r) async {
  await _db.collection('recurring').doc(r.id).update(r.toMap());

  final index = recurring.indexWhere((e) => e.id == r.id);

  if (index != -1) {
    recurring[index] = r;
  }

  notifyListeners();
}
}