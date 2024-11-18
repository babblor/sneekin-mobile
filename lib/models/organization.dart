import 'package:hive/hive.dart';

part 'organization.g.dart'; // For the Hive-generated file

@HiveType(typeId: 1) // Ensure this ID is unique within your app
class Organization {
  @HiveField(0)
  final int? org_id;

  @HiveField(1)
  final String? org_name;

  @HiveField(2)
  final String? org_website_name;

  @HiveField(3)
  final String? org_email;

  @HiveField(4)
  final String? org_cin;

  @HiveField(5)
  final String? org_pan;

  @HiveField(6)
  final String? org_gstin;

  @HiveField(7)
  final String? org_cin_url;

  @HiveField(8)
  final String? org_pan_url;

  @HiveField(9)
  final String? org_gstin_url;

  @HiveField(10)
  final String? org_logo_url;

  @HiveField(11)
  final String? org_address;

  @HiveField(12)
  final bool? org_pan_verified;

  @HiveField(13)
  final bool? org_cin_verified;

  @HiveField(14)
  final bool? org_gstin_verified;

  Organization(
      {this.org_address,
      this.org_cin,
      this.org_cin_url,
      this.org_cin_verified,
      this.org_email,
      this.org_gstin,
      this.org_gstin_url,
      this.org_gstin_verified,
      this.org_id,
      this.org_logo_url,
      this.org_name,
      this.org_pan,
      this.org_pan_url,
      this.org_pan_verified,
      this.org_website_name});
}

//   // Custom fromJson method
//   // factory User.fromJson(Map<String, dynamic> json) {
//   //   return User(
//   //     id: json['id'] as int?,
//   //     email: json['email'] as String?,
//   //     name: json['name'] as String?,
//   //     ageGroup: json['ageGroup'] as int?,
//   //     gender: json['gender'] as String?,
//   //     profileImageUrl: json['profileImageUrl'] as String?,
//   //     keycloakSecret: json['keycloakSecret'] as String?,
//   //     mobileNumbers: (json['mobileNumbers'] as List)
//   //         .map((e) => MobileNumber.fromJson(e as Map<String, dynamic>))
//   //         .toList(),
//   //   );
//   // }

//   // Custom toJson method
//   // Map<String, dynamic> toJson() {
//   //   return {
//   //     'id': id,
//   //     'email': email,
//   //     'name': name,
//   //     'ageGroup': ageGroup,
//   //     'gender': gender,
//   //     'profileImageUrl': profileImageUrl,
//   //     'keycloakSecret': keycloakSecret,
//   //     'mobileNumbers': mobileNumbers.map((e) => e.toJson()).toList(),
//   //   };
//   // }
// }

// // // A separate class for mobile numbers
// // @HiveType(typeId: 1)
// // class MobileNumber {
// //   @HiveField(0)
// //   final int id;

// //   @HiveField(1)
// //   final String mobileNumber;

// //   @HiveField(2)
// //   final String countryCode;

// //   @HiveField(3)
// //   final bool org;

// //   MobileNumber({
// //     required this.id,
// //     required this.mobileNumber,
// //     required this.countryCode,
// //     required this.org,
// //   });

// //   factory MobileNumber.fromJson(Map<String, dynamic> json) {
// //     return MobileNumber(
// //       id: json['id'] as int,
// //       mobileNumber: json['mobileNumber'] as String,
// //       countryCode: json['countryCode'] as String,
// //       org: json['org'] as bool,
// //     );
// //   }

// //   Map<String, dynamic> toJson() {
// //     return {
// //       'id': id,
// //       'mobileNumber': mobileNumber,
// //       'countryCode': countryCode,
// //       'org': org,
// //     };
// //   }
// // }
