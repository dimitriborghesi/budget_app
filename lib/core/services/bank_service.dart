class BankTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;

  BankTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });
}

class BankService {
  Future<List<BankTransaction>> fetchTransactions() async {
    await Future.delayed(const Duration(seconds: 2));

    // 🔥 simulation (plus tard → Nordigen API)
    return [
      BankTransaction(
        id: "bank_1",
        title: "UBER BV",
        amount: -12.10,
        date: DateTime.now(),
      ),
      BankTransaction(
        id: "bank_2",
        title: "MC DONALD",
        amount: -15.50,
        date: DateTime.now(),
      ),
    ];
  }
}