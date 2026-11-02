import 'package:starapp/core/utils/json.dart';

enum PayoutMethodType { bankAccount, mobileMoney }

/// Where withdrawals are sent (`GET /payout-methods`). Only the last four
/// digits of the account ever reach the app.
class PayoutMethod {
  const PayoutMethod({
    required this.id,
    required this.type,
    required this.bankName,
    required this.bankCode,
    required this.accountLast4,
    required this.accountName,
    this.isVerified = false,
    this.isDefault = false,
  });

  factory PayoutMethod.fromJson(Json json) => PayoutMethod(
    id: json['id'] as String,
    type: readEnum(
      PayoutMethodType.values,
      json['type'],
      PayoutMethodType.bankAccount,
    ),
    bankName: json['bankName'] as String? ?? '',
    bankCode: json['bankCode'] as String? ?? '',
    accountLast4: json['accountLast4'] as String? ?? '',
    accountName: json['accountName'] as String? ?? '',
    isVerified: json['isVerified'] as bool? ?? false,
    isDefault: json['isDefault'] as bool? ?? false,
  );

  final String id;
  final PayoutMethodType type;
  final String bankName;
  final String bankCode;
  final String accountLast4;

  /// The name the bank holds for the account.
  final String accountName;
  final bool isVerified;
  final bool isDefault;

  /// "GTBank •••• 4821".
  String get label => '$bankName •••• $accountLast4';

  Json toJson() => {
    'id': id,
    'type': type.name,
    'bankName': bankName,
    'bankCode': bankCode,
    'accountLast4': accountLast4,
    'accountName': accountName,
    'isVerified': isVerified,
    'isDefault': isDefault,
  };

  PayoutMethod copyWith({bool? isDefault}) => PayoutMethod(
    id: id,
    type: type,
    bankName: bankName,
    bankCode: bankCode,
    accountLast4: accountLast4,
    accountName: accountName,
    isVerified: isVerified,
    isDefault: isDefault ?? this.isDefault,
  );
}

/// A bank payouts can be sent to (`GET /banks`).
class Bank {
  const Bank({required this.code, required this.name, this.logoUrl});

  factory Bank.fromJson(Json json) => Bank(
    code: json['code'] as String,
    name: json['name'] as String? ?? '',
    logoUrl: json['logoUrl'] as String?,
  );

  /// The bank's clearing code, e.g. "058" for GTBank.
  final String code;
  final String name;
  final String? logoUrl;

  Json toJson() => {'code': code, 'name': name, 'logoUrl': logoUrl};
}

/// The bank's name for an account number (`GET /banks/resolve`).
class ResolvedAccount {
  const ResolvedAccount({required this.accountName});

  factory ResolvedAccount.fromJson(Json json) =>
      ResolvedAccount(accountName: json['accountName'] as String? ?? '');

  final String accountName;

  Json toJson() => {'accountName': accountName};
}
