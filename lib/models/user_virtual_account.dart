import 'package:json_annotation/json_annotation.dart';

part 'user_virtual_account.g.dart';

@JsonSerializable()
class VirtualAccountResponse {
  final int totalPages;
  final List<Group> groups;

  VirtualAccountResponse({
    required this.totalPages,
    required this.groups,
  });

  factory VirtualAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$VirtualAccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VirtualAccountResponseToJson(this);
}

@JsonSerializable()
class Group {
  final int mobileId;
  final String countryCode;
  final List<VirtualAccount> userVirtualAccounts;

  Group({
    required this.mobileId,
    required this.countryCode,
    required this.userVirtualAccounts,
  });

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);
}

@JsonSerializable()
class VirtualAccount {
  final int id;
  final String? name;
  final int? mobileId; // Renamed for consistency
  final int? orgAppId;
  final String? orgAppName;
  final String? orgAppLogo;
  final String username;
  final String? createdApp;
  final String? lastLoginApp;
  final DateTime? lastLoginTime;
  final int? age;
  final bool? paymentDueStatus;
  final String? mobileNumber;
  final String? countryCode;
  final bool? isMobileApp;
  final String? lastLoginAppLogo;

  VirtualAccount({
    required this.id,
    this.name,
    this.mobileId,
    this.orgAppId,
    this.orgAppName,
    this.orgAppLogo,
    required this.username,
    this.createdApp,
    this.lastLoginApp,
    this.lastLoginTime,
    this.age,
    this.paymentDueStatus,
    this.mobileNumber,
    this.countryCode,
    this.isMobileApp,
    this.lastLoginAppLogo,
  });

  factory VirtualAccount.fromJson(Map<String, dynamic> json) => _$VirtualAccountFromJson(json);

  Map<String, dynamic> toJson() => _$VirtualAccountToJson(this);
}
