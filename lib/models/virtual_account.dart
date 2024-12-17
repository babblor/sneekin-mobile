import 'package:json_annotation/json_annotation.dart';

part 'virtual_account.g.dart';

@JsonSerializable()
class VirtualAccount {
  final int id;
  final String? name;
  final int? mobileID;
  final int? orgAppId;
  final String? orgAppName;
  final String? orgAppLogo;
  final String username;
  final String? createdApp;
  final String? lastLoginApp;
  final DateTime? lastLoginTime;
  final int? ageGroup;
  final bool? paymentDueStatus;
  final String? mobileNumber;
  final String? countryCode;
  final bool? isMobileApp;

  final String? lastLoginAppLogo;

  VirtualAccount(
      {required this.id,
      this.name,
      this.mobileID,
      this.orgAppId,
      this.orgAppName,
      this.orgAppLogo,
      required this.username,
      this.createdApp,
      this.lastLoginApp,
      this.lastLoginTime,
      this.ageGroup,
      this.isMobileApp,
      this.paymentDueStatus,
      this.mobileNumber,
      this.lastLoginAppLogo,
      this.countryCode});

  factory VirtualAccount.fromJson(Map<String, dynamic> json) => _$VirtualAccountFromJson(json);

  Map<String, dynamic> toJson() => _$VirtualAccountToJson(this);
}
