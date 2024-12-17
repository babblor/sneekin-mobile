// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as int,
      email: fields[1] as String,
      name: fields[2] as String,
      age: fields[3] as int,
      gender: fields[4] as String,
      profileImageUrl: fields[5] as String?,
      mobileNumbers: (fields[6] as List).cast<MobileNumber>(),
      isEmailVerified: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.profileImageUrl)
      ..writeByte(6)
      ..write(obj.mobileNumbers)
      ..writeByte(7)
      ..write(obj.isEmailVerified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MobileNumberAdapter extends TypeAdapter<MobileNumber> {
  @override
  final int typeId = 1;

  @override
  MobileNumber read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MobileNumber(
      id: fields[0] as int,
      mobileNumber: fields[1] as String,
      countryCode: fields[2] as String,
      is_org: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MobileNumber obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mobileNumber)
      ..writeByte(2)
      ..write(obj.countryCode)
      ..writeByte(3)
      ..write(obj.is_org);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MobileNumberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
