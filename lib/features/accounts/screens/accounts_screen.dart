import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../models/account.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
  }

  double _total(List<Account> accounts) {
    return accounts.fold(0, (sum, acc) => sum + acc.balance);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF060B05),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Mes comptes",
            style: TextStyle(color: Colors.white)),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF799C0A),
        onPressed: () => _showAddAccount(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 💰 TOTAL + BTN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total",
                        style: TextStyle(color: Colors.white54)),
                    Text(
                      "${_total(provider.accounts).toStringAsFixed(2)} €",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF799C0A)),
                  onPressed: () => _showTransfer(context),
                  child: const Text("Transférer",
                      style: TextStyle(color: Colors.white)),
                )
              ],
            ),

            const SizedBox(height: 20),

            /// 💳 LIST
            Expanded(
              child: ListView(
                children: [

                  ...provider.accounts.map((acc) =>
                      Dismissible(
                        key: Key(acc.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          provider.deleteAccount(acc.id);
                          HapticFeedback.mediumImpact();
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete,
                              color: Colors.white),
                        ),
                        child: _accountCard(acc, context),
                      )
                  ),

                  const SizedBox(height: 20),

                  const Text("Historique global",
                      style: TextStyle(color: Colors.white)),

                  const SizedBox(height: 10),

                  ...provider.transfers.map((t) => _historyItem(t)),
                ],
              ),
            ),

            /// 💸 ANIMATION
            SizeTransition(
              sizeFactor: _controller,
              child: const Icon(Icons.attach_money,
                  color: Colors.green, size: 40),
            )
          ],
        ),
      ),
    );
  }

  /// 💳 CARD
  Widget _accountCard(Account acc, BuildContext context) {
    return GestureDetector(
      onTap: () => _showAccountHistory(context, acc),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(acc.color),
              child: Icon(acc.icon, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(acc.name,
                  style: const TextStyle(color: Colors.white)),
            ),
            Text("${acc.balance.toStringAsFixed(2)} €",
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  /// 📊 HISTO GLOBAL
  Widget _historyItem(Map<String, dynamic> t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['label'] ?? '',
                    style: const TextStyle(color: Colors.white)),
                Text("${t['from']} → ${t['to']}",
                    style: const TextStyle(color: Colors.white38)),
              ],
            ),
          ),
          Text("${t['amount']} €",
              style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  /// 📊 HISTO PAR COMPTE
  void _showAccountHistory(BuildContext context, Account acc) {
    final provider =
        Provider.of<AccountProvider>(context, listen: false);

    final filtered = provider.transfers.where((t) =>
        t['from'] == acc.name || t['to'] == acc.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151515),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListView(
        padding: const EdgeInsets.all(20),
        children: [

          Text("Historique ${acc.name}",
              style: const TextStyle(color: Colors.white)),

          const SizedBox(height: 20),

          ...filtered.map((t) => ListTile(
                title: Text(t['label'],
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(t['description'] ?? '',
                    style:
                        const TextStyle(color: Colors.white54)),
                trailing: Text("${t['amount']} €",
                    style: const TextStyle(color: Colors.white)),
              )),
        ],
      ),
    );
  }

  /// 🔁 TRANSFERT + ANIMATION + VIBRATION
  void _showTransfer(BuildContext context) {
    final provider =
        Provider.of<AccountProvider>(context, listen: false);

    Account? from;
    Account? to;

    final amount = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setState) => Dialog(
          backgroundColor: const Color(0xFF151515),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text("Transfert",
                    style: TextStyle(color: Colors.white)),

                const SizedBox(height: 15),

                _selectAccount(context, "De", from, (val) {
                  setState(() => from = val);
                }),

                _selectAccount(context, "Vers", to, (val) {
                  setState(() => to = val);
                }),

                TextField(
                  controller: amount,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      hintText: "Montant",
                      hintStyle: TextStyle(color: Colors.white38)),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF799C0A),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () {
                    final value =
                        double.tryParse(amount.text) ?? 0;

                    if (from != null && to != null) {
                      provider.transfer(from!, to!, value, "Transfert", "");

                      _controller.forward(from: 0);
                      HapticFeedback.mediumImpact();
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("Envoyer",
                      style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// SELECT CLEAN
  Widget _selectAccount(BuildContext context, String label,
      Account? selected, Function(Account) onSelect) {

    final provider =
        Provider.of<AccountProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF151515),
          builder: (_) => ListView(
            children: provider.accounts.map((acc) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(acc.color),
                  child: Icon(acc.icon, color: Colors.white),
                ),
                title: Text(acc.name,
                    style: const TextStyle(color: Colors.white)),
                onTap: () {
                  onSelect(acc);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Text(selected?.name ?? label,
                style: const TextStyle(color: Colors.white)),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down,
                color: Colors.white54),
          ],
        ),
      ),
    );
  }
  
  void _showAddAccount(BuildContext context) {
  final name = TextEditingController();

  IconData selectedIcon = Icons.account_balance;
  Color selectedColor = const Color(0xFF799C0A);

  final icons = [
    Icons.account_balance,
    Icons.savings,
    Icons.wallet,
    Icons.credit_card,
  ];

  final colors = [
    Color(0xFF799C0A),
    Colors.blue,
    Colors.purple,
    Colors.orange,
  ];

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (_, setState) => Dialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text("Nouveau compte",
                  style: TextStyle(color: Colors.white)),

              const SizedBox(height: 15),

              TextField(
                controller: name,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Nom du compte",
                  hintStyle: TextStyle(color: Colors.white38),
                ),
              ),

              const SizedBox(height: 20),

              /// ICONES
              Wrap(
                spacing: 10,
                children: icons.map((icon) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedIcon = icon),
                    child: CircleAvatar(
                      backgroundColor: selectedIcon == icon
                          ? const Color(0xFF799C0A)
                          : Colors.grey[800],
                      child: Icon(icon, color: Colors.white),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 15),

              /// COULEURS
              Wrap(
                spacing: 10,
                children: colors.map((c) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = c),
                    child: CircleAvatar(
                      backgroundColor: c,
                      radius: selectedColor == c ? 18 : 14,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF799C0A),
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () async {
                  if (name.text.isEmpty) return;

                  await Provider.of<AccountProvider>(context, listen: false)
                      .addAccount(
                          name.text.trim(), selectedIcon, selectedColor);

                  Navigator.pop(context);
                },
                child: const Text("Créer",
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    ),
  );
}}