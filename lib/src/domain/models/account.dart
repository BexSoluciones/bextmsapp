const String tableAccount = 'accounts';

class AccountFields {
  static final List<String> values = [
    id,
    idAccount,
    accountId,
    name,
    bankId,
    accountNumber,
    codeQr,
    createdAt,
  ];

  static const String id = 'id';
  static const String idAccount = 'id_account';
  static const String accountId = 'account_id';
  static const String name = 'name';
  static const String bankId = 'bank_id';
  static const String accountNumber = 'account_number';
  static const String codeQr = 'code_qr';
  static const String createdAt = 'created_at';
}

class Account {
  Account(
      {this.id,
        this.accountId,
        this.name,
        this.bankId,
        this.accountNumber,
        this.codeQr,
        this.createdAt,
      });

  Account.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accountId = json['account_id'];
    name = json['name'];
    bankId = json['bank_id'];
    accountNumber = json['account_number'];
    codeQr = json['code_qr'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['account_id'] = accountId;
    data['bank_id'] = bankId;
    data['account_number'] = accountNumber;
    data['code_qr'] = codeQr;
    data['created_at'] = createdAt;
    return data;
  }

  int? id;
  int? accountId;
  int? idAccount;
  String? name;
  int? bankId;
  int? accountNumber;
  String? codeQr;
  String? createdAt;
}

class AccountPayment {
  AccountPayment(
      {
        this.paid,
        this.type,
        this.account,
        this.date,
      });

  String? type;
  String? paid;
  Account? account;
  String? date;
}
