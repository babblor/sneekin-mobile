import 'package:hive/hive.dart';
import 'package:sneekin/models/user.dart';

part 'organization.g.dart'; // For the Hive-generated file

@HiveType(typeId: 3) // Ensure this ID is unique within your app
class Organization {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? websiteName;

  @HiveField(3)
  final String? email;

  @HiveField(4)
  final String? cin;

  @HiveField(5)
  final String? pan;

  @HiveField(6)
  final String? gstin;

  @HiveField(7)
  final String? cinUrl;

  @HiveField(8)
  final String? panUrl;

  @HiveField(9)
  final String? gstinUrl;

  @HiveField(10)
  final String? logo;

  @HiveField(11)
  final String? address;

  @HiveField(12)
  final bool? isPanVerified;

  @HiveField(13)
  final bool? isCinVerified;

  @HiveField(14)
  final bool? isGstinVerified;
  @HiveField(15)
  final int? totalVirtualAccountUsers;
  @HiveField(16)
  final int? totalWebsites;

  @HiveField(17)
  final int? totalMobileApps;

  @HiveField(18)
  final bool? isEmailVerified;

  @HiveField(19)
  final List<MobileNumber>? mobileNumbers;

  Organization(
      {this.id,
      this.name,
      this.websiteName,
      this.email,
      this.cin,
      this.pan,
      this.gstin,
      this.cinUrl,
      this.panUrl,
      this.gstinUrl,
      this.logo,
      this.address,
      this.isPanVerified,
      this.isCinVerified,
      this.isGstinVerified,
      this.mobileNumbers,
      this.totalWebsites,
      this.totalMobileApps,
      this.totalVirtualAccountUsers,
      this.isEmailVerified});

  // Custom fromJson method to convert JSON into Organization
  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as int?,
      name: json['name'] as String?,
      websiteName: json['websiteName'] as String?,
      email: json['email'] as String?,
      cin: json['cin'] as String?,
      pan: json['pan'] as String?,
      gstin: json['gstIn'] as String?,
      cinUrl: json['cinUrl'] as String?,
      panUrl: json['panUrl'] as String?,
      gstinUrl: json['gstInUrl'] as String?,
      logo: json['logo'] as String?,
      address: json['address'] as String?,
      isPanVerified: json['isPanVerified'] as bool?,
      isCinVerified: json['isCinVerified'] as bool?,
      isGstinVerified: json['isGstInVerified'] as bool?,
      isEmailVerified: json['isEmailVerified'] as bool?,
      totalVirtualAccountUsers: json['totalVirtualAccountUsers'] as int?,
      totalWebsites: json['totalWebsites'] as int?,
      totalMobileApps: json['totalMobileApps'] as int?,
      mobileNumbers: (json['mobileNumbers'] as List?)
          ?.map((e) => MobileNumber.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Custom toJson method to convert Organization into JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'websiteName': websiteName,
      'email': email,
      'cin': cin,
      'pan': pan,
      'gstIn': gstin,
      'cinUrl': cinUrl,
      'panUrl': panUrl,
      'gstInUrl': gstinUrl,
      'logo': logo,
      'address': address,
      'isPanVerified': isPanVerified,
      'isCinVerified': isCinVerified,
      'isGstInVerified': isGstinVerified,
      'totalMobileApps': totalMobileApps,
      'isEmailVerified': isEmailVerified,
      'totalWebsites': totalWebsites,
      'totalVirtualAccountUsers': totalVirtualAccountUsers,
      'mobileNumbers': mobileNumbers?.map((e) => e.toJson()).toList(),
    };
  }
}
