// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'virtual_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VirtualAccount _$VirtualAccountFromJson(Map<String, dynamic> json) =>
    VirtualAccount(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      mobileID: (json['mobileID'] as num?)?.toInt(),
      orgAppId: (json['orgAppId'] as num).toInt(),
      orgAppName: json['orgAppName'] as String,
      orgAppLogo: json['orgAppLogo'] as String?,
      username: json['username'] as String,
      createdApp: json['createdApp'] as String,
      lastLoginApp: json['lastLoginApp'] as String,
      lastLoginTime: json['lastLoginTime'] == null
          ? null
          : DateTime.parse(json['lastLoginTime'] as String),
      ageGroup: (json['ageGroup'] as num?)?.toInt(),
      paymentDueStatus: json['paymentDueStatus'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      countryCode: json['countryCode'] as String?,
    );

Map<String, dynamic> _$VirtualAccountToJson(VirtualAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'mobileID': instance.mobileID,
      'orgAppId': instance.orgAppId,
      'orgAppName': instance.orgAppName,
      'orgAppLogo': instance.orgAppLogo,
      'username': instance.username,
      'createdApp': instance.createdApp,
      'lastLoginApp': instance.lastLoginApp,
      'lastLoginTime': instance.lastLoginTime?.toIso8601String(),
      'ageGroup': instance.ageGroup,
      'paymentDueStatus': instance.paymentDueStatus,
      'mobileNumber': instance.mobileNumber,
      'countryCode': instance.countryCode,
    };
