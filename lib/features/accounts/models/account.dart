class Account {
  String id;
  String name;
  double balance;
  String userId;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'balance': balance,
      'userId': userId,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map, String id) {
    return Account(
      id: id,
      name: map['name'] ?? '',
      balance: (map['balance'] as num).toDouble(),
      userId: map['userId'] ?? '',
    );
  }
}