// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_app_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrgAppAccount _$OrgAppAccountFromJson(Map<String, dynamic> json) =>
    OrgAppAccount(
      id: (json['id'] as num).toInt(),
      orgName: json['orgName'] as String?,
      name: json['name'] as String,
      mobile: json['mobile'] as String?,
      countryCode: json['countryCode'] as String?,
      email: json['email'] as String?,
      clientId: json['clientId'] as String,
      clientSecret: json['clientSecret'] as String?,
      logo: json['logo'] as String?,
      clientWebsite: json['clientWebsite'] as String?,
    );

Map<String, dynamic> _$OrgAppAccountToJson(OrgAppAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgName': instance.orgName,
      'name': instance.name,
      'mobile': instance.mobile,
      'countryCode': instance.countryCode,
      'email': instance.email,
      'clientId': instance.clientId,
      'clientSecret': instance.clientSecret,
      'logo': instance.logo,
      'clientWebsite': instance.clientWebsite,
    };
