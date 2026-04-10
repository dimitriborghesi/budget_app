import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static int _id = 0; // 🔥 évite écrasement notif

  /// INIT
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    /// 🔔 permission Firebase
    await FirebaseMessaging.instance.requestPermission();
  }

  /// 🔔 NOTIFICATION SIMPLE
  static Future<void> show({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'budget_channel',
      'Budget Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notifications.show(
      _id++, // 🔥 unique id
      title,
      body,
      details,
    );
  }

  /// 💸 NOTIF TRANSACTION (AUTO FORMAT)
  static Future<void> transaction({
    required String title,
    required double amount,
    required bool isIncome,
  }) async {
    final sign = isIncome ? "+" : "-";

    await show(
      title: isIncome ? "💸 Revenu reçu" : "💳 Dépense",
      body: "$title $sign${amount.toStringAsFixed(2)}€",
    );
  }

  /// 🔁 NOTIF RECURRING (Netflix etc)
  static Future<void> recurring({
    required String title,
    required double amount,
    required bool isIncome,
  }) async {
    final sign = isIncome ? "+" : "-";

    await show(
      title: "🔁 Automatisation",
      body: "$title $sign${amount.toStringAsFixed(2)}€",
    );
  }
}