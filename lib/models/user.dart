import 'package:hive/hive.dart';

part 'user.g.dart'; // For the Hive-generated file

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final int age;

  @HiveField(4)
  final String gender;

  @HiveField(5)
  final String? profileImageUrl;

  @HiveField(6)
  final List<MobileNumber> mobileNumbers;

  @HiveField(7)
  final bool isEmailVerified;

  User(
      {required this.id,
      required this.email,
      required this.name,
      required this.age,
      required this.gender,
      this.profileImageUrl,
      required this.mobileNumbers,
      required this.isEmailVerified});

  // From JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      profileImageUrl: json['profileImageUrl'],
      isEmailVerified: json['isEmailVerified'],
      mobileNumbers: (json['mobileNumbers'] as List<dynamic>).map((e) => MobileNumber.fromJson(e)).toList(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'profileImageUrl': profileImageUrl,
      'isEmailVerified': isEmailVerified,
      'mobileNumbers': mobileNumbers.map((e) => e.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 1)
class MobileNumber {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String mobileNumber;

  @HiveField(2)
  final String countryCode;

  @HiveField(3)
  final bool is_org;

  MobileNumber({
    required this.id,
    required this.mobileNumber,
    required this.countryCode,
    required this.is_org,
  });

  // From JSON
  factory MobileNumber.fromJson(Map<String, dynamic> json) {
    return MobileNumber(
      id: json['id'],
      mobileNumber: json['mobileNumber'],
      countryCode: json['countryCode'],
      is_org: json['is_org'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobileNumber': mobileNumber,
      'countryCode': countryCode,
      'is_org': is_org,
    };
  }
}
