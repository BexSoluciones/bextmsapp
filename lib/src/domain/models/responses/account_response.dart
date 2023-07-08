import 'package:equatable/equatable.dart';

import '../account.dart';

class AccountResponse extends Equatable {
  final List<Account> accounts;

  const AccountResponse({
    required this.accounts
  });

  factory AccountResponse.fromMap(Map<String, dynamic> map) {
    return AccountResponse(
      accounts: List<Account>.from(
        map['accounts'].map<Account>(
              (x) => Account.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [accounts];
}
