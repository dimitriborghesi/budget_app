import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'features/transactions/providers/transaction_provider.dart';
import 'features/accounts/providers/account_provider.dart';
import 'features/recurring/providers/recurring_provider.dart';
import 'firebase_options.dart';
import 'shared/screens/login_screen.dart';
import 'shared/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

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
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final auth = FirebaseAuth.instance;
  final localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  Future<void> checkUser() async {
    final user = auth.currentUser;

    if (user == null) {
      goLogin();
      return;
    }

    final canCheck = await localAuth.canCheckBiometrics;

    if (canCheck) {
      final ok = await localAuth.authenticate(
        localizedReason: "Connexion rapide",
      );

      if (!ok) {
        goLogin();
        return;
      }
    }

    goHome();
  }

  void goLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}