import 'package:hive/hive.dart';

part 'user.g.dart'; // For the Hive-generated file

@HiveType(typeId: 0) // Ensure this ID is unique within your app
class User {
  @HiveField(0)
  final int? user_id;

  @HiveField(1)
  final String? email_id;

  @HiveField(2)
  final String? name;

  @HiveField(3)
  final int? age;

  @HiveField(4)
  final String? gender;

  @HiveField(5)
  final String? created_at;

  @HiveField(6)
  final String? updated_at;

  @HiveField(7)
  final String? profile_image;

  @HiveField(8)
  final String? keyclock_secret;

  @HiveField(9)
  final bool? email_verified;

  User(
      {this.user_id,
      this.email_id,
      this.name,
      this.age,
      this.gender,
      this.created_at,
      this.updated_at,
      this.profile_image,
      this.keyclock_secret,
      this.email_verified});

  // Custom fromJson method
  // factory User.fromJson(Map<String, dynamic> json) {
  //   return User(
  //     id: json['id'] as int?,
  //     email: json['email'] as String?,
  //     name: json['name'] as String?,
  //     ageGroup: json['ageGroup'] as int?,
  //     gender: json['gender'] as String?,
  //     profileImageUrl: json['profileImageUrl'] as String?,
  //     keycloakSecret: json['keycloakSecret'] as String?,
  //     mobileNumbers: (json['mobileNumbers'] as List)
  //         .map((e) => MobileNumber.fromJson(e as Map<String, dynamic>))
  //         .toList(),
  //   );
  // }

  // Custom toJson method
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'email': email,
  //     'name': name,
  //     'ageGroup': ageGroup,
  //     'gender': gender,
  //     'profileImageUrl': profileImageUrl,
  //     'keycloakSecret': keycloakSecret,
  //     'mobileNumbers': mobileNumbers.map((e) => e.toJson()).toList(),
  //   };
  // }
}

// // A separate class for mobile numbers
// @HiveType(typeId: 1)
// class MobileNumber {
//   @HiveField(0)
//   final int id;

//   @HiveField(1)
//   final String mobileNumber;

//   @HiveField(2)
//   final String countryCode;

//   @HiveField(3)
//   final bool org;

//   MobileNumber({
//     required this.id,
//     required this.mobileNumber,
//     required this.countryCode,
//     required this.org,
//   });

//   factory MobileNumber.fromJson(Map<String, dynamic> json) {
//     return MobileNumber(
//       id: json['id'] as int,
//       mobileNumber: json['mobileNumber'] as String,
//       countryCode: json['countryCode'] as String,
//       org: json['org'] as bool,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'mobileNumber': mobileNumber,
//       'countryCode': countryCode,
//       'org': org,
//     };
//   }
// }
