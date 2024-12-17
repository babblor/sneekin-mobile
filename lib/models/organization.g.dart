// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrganizationAdapter extends TypeAdapter<Organization> {
  @override
  final int typeId = 3;

  @override
  Organization read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Organization(
      id: fields[0] as int?,
      name: fields[1] as String?,
      websiteName: fields[2] as String?,
      email: fields[3] as String?,
      cin: fields[4] as String?,
      pan: fields[5] as String?,
      gstin: fields[6] as String?,
      cinUrl: fields[7] as String?,
      panUrl: fields[8] as String?,
      gstinUrl: fields[9] as String?,
      logo: fields[10] as String?,
      address: fields[11] as String?,
      isPanVerified: fields[12] as bool?,
      isCinVerified: fields[13] as bool?,
      isGstinVerified: fields[14] as bool?,
      mobileNumbers: (fields[19] as List).cast<MobileNumber>(),
      totalWebsites: fields[16] as int?,
      totalMobileApps: fields[17] as int?,
      totalVirtualAccountUsers: fields[15] as int?,
      isEmailVerified: fields[18] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Organization obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.websiteName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.cin)
      ..writeByte(5)
      ..write(obj.pan)
      ..writeByte(6)
      ..write(obj.gstin)
      ..writeByte(7)
      ..write(obj.cinUrl)
      ..writeByte(8)
      ..write(obj.panUrl)
      ..writeByte(9)
      ..write(obj.gstinUrl)
      ..writeByte(10)
      ..write(obj.logo)
      ..writeByte(11)
      ..write(obj.address)
      ..writeByte(12)
      ..write(obj.isPanVerified)
      ..writeByte(13)
      ..write(obj.isCinVerified)
      ..writeByte(14)
      ..write(obj.isGstinVerified)
      ..writeByte(15)
      ..write(obj.totalVirtualAccountUsers)
      ..writeByte(16)
      ..write(obj.totalWebsites)
      ..writeByte(17)
      ..write(obj.totalMobileApps)
      ..writeByte(18)
      ..write(obj.isEmailVerified)
      ..writeByte(19)
      ..write(obj.mobileNumbers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
