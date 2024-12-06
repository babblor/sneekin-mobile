import 'package:json_annotation/json_annotation.dart';

part 'virtual_account.g.dart';

@JsonSerializable()
class VirtualAccount {
  final int id;
  final String? name;
  final int? mobileID;
  final int orgAppId;
  final String orgAppName;
  final String? orgAppLogo;
  final String username;
  final String createdApp;
  final String lastLoginApp;
  final DateTime? lastLoginTime;
  final int? ageGroup;
  final String? paymentDueStatus;
  final String? mobileNumber;
  final String? countryCode;

  VirtualAccount(
      {required this.id,
      this.name,
      this.mobileID,
      required this.orgAppId,
      required this.orgAppName,
      this.orgAppLogo,
      required this.username,
      required this.createdApp,
      required this.lastLoginApp,
      this.lastLoginTime,
      this.ageGroup,
      this.paymentDueStatus,
      this.mobileNumber,
      this.countryCode});

  factory VirtualAccount.fromJson(Map<String, dynamic> json) => _$VirtualAccountFromJson(json);

  Map<String, dynamic> toJson() => _$VirtualAccountToJson(this);
}
