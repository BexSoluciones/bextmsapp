const String tableAccount = 'accounts';

class AccountFields {
  static final List<String> values = [
    id,
    accountId,
    name,
    bankId,
    accountNumber,
    createdAt,
  ];

  static const String id = 'id';
  static const String accountId = 'account_id';
  static const String name = 'name';
  static const String bankId = 'bank_id';
  static const String accountNumber = 'account_number';
  static const String createdAt = 'created_at';
}

class Account {
  Account(
      {this.id,
      this.accountId,
      this.name,
      this.bankId,
      this.accountNumber,
      this.createdAt});

  Account.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accountId = json['account_id'];
    name = json['name'];
    bankId = json['bank_id'];
    accountNumber = json['account_number'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['id_account'] = id;
    data['account_id'] = accountId;
    data['bank_id'] = bankId;
    data['account_number'] = accountNumber;
    data['created_at'] = createdAt;
    return data;
  }

  int? id;
  int? accountId;
  String? name;
  int? bankId;
  int? accountNumber;
  String? createdAt;
}
