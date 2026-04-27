import 'package:budget_app/shared/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/providers/category_provider.dart';
import 'features/transactions/providers/transaction_provider.dart';
import 'features/accounts/providers/account_provider.dart';
import 'features/recurring/providers/recurring_provider.dart';
import 'firebase_options.dart';
import 'core/auth/auth_gate.dart'; // 🔥 IMPORTANT
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    await initializeDateFormatting('fr_FR', null); // 👈 important


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
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // 🔥 AJOUT
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => RecurringProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
child: Builder(
  builder: (context) {

    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      locale: const Locale('fr', 'FR'),
      scaffoldMessengerKey: messengerKey,
      debugShowCheckedModeBanner: false,

theme: AppTheme.light,
darkTheme: AppTheme.dark,

      themeMode: themeProvider.mode,

      home: const AuthGate(),
    );
  },
),
    );
  }
}