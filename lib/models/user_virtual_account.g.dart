// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_virtual_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VirtualAccountResponse _$VirtualAccountResponseFromJson(Map<String, dynamic> json) => VirtualAccountResponse(
      totalPages: (json['totalPages'] as num).toInt(),
      groups:
          (json['groups'] as List<dynamic>).map((e) => Group.fromJson(e as Map<String, dynamic>)).toList(),
    );

Map<String, dynamic> _$VirtualAccountResponseToJson(VirtualAccountResponse instance) => <String, dynamic>{
      'totalPages': instance.totalPages,
      'groups': instance.groups,
    };

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      mobileId: (json['mobileId'] as num).toInt(),
      countryCode: json['countryCode'] as String,
      userVirtualAccounts: (json['userVirtualAccounts'] as List<dynamic>)
          .map((e) => VirtualAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'mobileId': instance.mobileId,
      'countryCode': instance.countryCode,
      'userVirtualAccounts': instance.userVirtualAccounts,
    };

VirtualAccount _$VirtualAccountFromJson(Map<String, dynamic> json) => VirtualAccount(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      mobileId: (json['mobileId'] as num?)?.toInt(),
      orgAppId: (json['orgAppId'] as num?)?.toInt(),
      client_website: json['client_website'] as String?,
      orgAppLogo: json['orgAppLogo'] as String?,
      username: json['username'] as String,
      createdApp: json['createdApp'] as String?,
      lastLoginApp: json['lastLoginApp'] as String?,
      lastLoginTime: json['lastLoginTime'] == null ? null : DateTime.parse(json['lastLoginTime'] as String),
      age: (json['age'] as num?)?.toInt(),
      paymentDueStatus: json['paymentDueStatus'] as bool?,
      mobileNumber: json['mobileNumber'] as String?,
      countryCode: json['countryCode'] as String?,
      isMobileApp: json['isMobileApp'] as bool?,
      lastLoginAppLogo: json['lastLoginAppLogo'] as String?,
    );

Map<String, dynamic> _$VirtualAccountToJson(VirtualAccount instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'mobileId': instance.mobileId,
      'orgAppId': instance.orgAppId,
      'client_website': instance.client_website,
      'orgAppLogo': instance.orgAppLogo,
      'username': instance.username,
      'createdApp': instance.createdApp,
      'lastLoginApp': instance.lastLoginApp,
      'lastLoginTime': instance.lastLoginTime?.toIso8601String(),
      'age': instance.age,
      'paymentDueStatus': instance.paymentDueStatus,
      'mobileNumber': instance.mobileNumber,
      'countryCode': instance.countryCode,
      'isMobileApp': instance.isMobileApp,
      'lastLoginAppLogo': instance.lastLoginAppLogo,
    };
