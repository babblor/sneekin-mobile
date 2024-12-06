import 'package:json_annotation/json_annotation.dart';

part 'org_app_account.g.dart';

@JsonSerializable()
class OrgAppAccount {
  final int id;
  final String? orgName;
  final String name;
  final String? mobile;
  final String? countryCode;
  final String? email; // Made nullable
  final String clientId;
  final String? clientSecret;
  final String? logo;
  final String? clientWebsite;

  OrgAppAccount(
      {required this.id,
      this.orgName,
      required this.name,
      this.mobile,
      this.countryCode,
      this.email, // Updated to nullable
      required this.clientId,
      this.clientSecret,
      this.logo,
      this.clientWebsite});

  /// Factory method to create an `OrgAppAccount` from JSON
  factory OrgAppAccount.fromJson(Map<String, dynamic> json) => _$OrgAppAccountFromJson(json);

  /// Method to convert an `OrgAppAccount` to JSON
  Map<String, dynamic> toJson() => _$OrgAppAccountToJson(this);
}
