import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../models/account.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Mes comptes")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAccount(context);
        },
        child: const Icon(Icons.add),
      ),

      body: ListView(
        children: provider.accounts.map((acc) {
          return GestureDetector(
            onTap: () => _showTransfer(context, acc),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8E2DE2)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(acc.name),
                  const SizedBox(height: 10),
                  Text("${acc.balance.toStringAsFixed(2)} €",
                      style: const TextStyle(fontSize: 26)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ➕ ADD ACCOUNT
  void _showAddAccount(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nouveau compte"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<AccountProvider>(context, listen: false)
                  .addAccount(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Ajouter"),
          )
        ],
      ),
    );
  }

  // 🔁 TRANSFER
  void _showTransfer(BuildContext context, Account from) {
    final provider =
        Provider.of<AccountProvider>(context, listen: false);
    final controller = TextEditingController();

    Account? selected;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Transfert depuis ${from.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<Account>(
              hint: const Text("Vers"),
              items: provider.accounts
                  .where((a) => a != from)
                  .map((a) => DropdownMenuItem(
                        value: a,
                        child: Text(a.name),
                      ))
                  .toList(),
              onChanged: (val) => selected = val,
            ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Montant",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;

              if (selected != null) {
                provider.transfer(from, selected!, amount);
              }

              Navigator.pop(context);
            },
            child: const Text("Envoyer"),
          )
        ],
      ),
    );
  }
}