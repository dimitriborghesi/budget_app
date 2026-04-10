import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/transactions/providers/transaction_provider.dart';
import 'features/accounts/providers/account_provider.dart';
import 'features/recurring/providers/recurring_provider.dart';

import 'shared/screens/login_screen.dart';
import 'shared/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => TransactionProvider()),
    ChangeNotifierProvider(create: (_) => AccountProvider()),
    ChangeNotifierProvider(create: (_) => RecurringProvider()),
  ],
  child: MaterialApp(
    scaffoldMessengerKey: messengerKey,
    debugShowCheckedModeBanner: false,
    home: const LoginScreen(),
      ),
    );
  }
}