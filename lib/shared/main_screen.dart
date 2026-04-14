import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/transactions/providers/transaction_provider.dart';
import '../features/accounts/providers/account_provider.dart';
import '../features/recurring/providers/recurring_provider.dart';

import '../features/transactions/screens/income_screen.dart';
import '../features/transactions/screens/expense_screen.dart';
import 'screens/stats_screen.dart';
import '../features/accounts/screens/accounts_screen.dart';
import 'screens/profile_screen.dart';
import '../features/recurring/screens/recurring_screen.dart'; // 🔥 NEW

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 1; // 🔥 start sur Dépenses
  bool _loaded = false;

  final screens = const [
    IncomeScreen(),
    ExpenseScreen(),
    RecurringScreen(), // 🔥 AUTO
    StatsScreen(),
    AccountsScreen(),
    ProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;
    _loaded = true;

    _initApp();
  }

  Future<void> _initApp() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    final recurringProvider =
        Provider.of<RecurringProvider>(context, listen: false);

    try {
      /// LOAD
      transactionProvider.loadTransactions();
      accountProvider.loadAccounts();
      await recurringProvider.load();

      /// 🔥 AUTO EXECUTION
      await recurringProvider.run();
      await transactionProvider.syncBank();
    } catch (e) {
      debugPrint("Erreur INIT APP: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: screens[index],
      ),

      /// 💎 NAVBAR PREMIUM
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.white12),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) {
  ScaffoldMessenger.of(context).clearSnackBars(); // 🔥 FIX

  setState(() => index = i);
},
          backgroundColor: const Color(0xFF060B05),
          selectedItemColor: const Color(0xFF799C0A),
          unselectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              label: "Revenus",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_down),
              label: "Dépenses",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome), // 🔥 AUTO
              label: "Auto",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: "Stats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance),
              label: "Comptes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}