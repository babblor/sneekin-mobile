// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrganizationAdapter extends TypeAdapter<Organization> {
  @override
  final int typeId = 1;

  @override
  Organization read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Organization(
      org_address: fields[11] as String?,
      org_cin: fields[4] as String?,
      org_cin_url: fields[7] as String?,
      org_cin_verified: fields[13] as bool?,
      org_email: fields[3] as String?,
      org_gstin: fields[6] as String?,
      org_gstin_url: fields[9] as String?,
      org_gstin_verified: fields[14] as bool?,
      org_id: fields[0] as int?,
      org_logo_url: fields[10] as String?,
      org_name: fields[1] as String?,
      org_pan: fields[5] as String?,
      org_pan_url: fields[8] as String?,
      org_pan_verified: fields[12] as bool?,
      org_website_name: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Organization obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.org_id)
      ..writeByte(1)
      ..write(obj.org_name)
      ..writeByte(2)
      ..write(obj.org_website_name)
      ..writeByte(3)
      ..write(obj.org_email)
      ..writeByte(4)
      ..write(obj.org_cin)
      ..writeByte(5)
      ..write(obj.org_pan)
      ..writeByte(6)
      ..write(obj.org_gstin)
      ..writeByte(7)
      ..write(obj.org_cin_url)
      ..writeByte(8)
      ..write(obj.org_pan_url)
      ..writeByte(9)
      ..write(obj.org_gstin_url)
      ..writeByte(10)
      ..write(obj.org_logo_url)
      ..writeByte(11)
      ..write(obj.org_address)
      ..writeByte(12)
      ..write(obj.org_pan_verified)
      ..writeByte(13)
      ..write(obj.org_cin_verified)
      ..writeByte(14)
      ..write(obj.org_gstin_verified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
