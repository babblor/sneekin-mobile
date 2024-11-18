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
      user_id: fields[0] as int?,
      email_id: fields[1] as String?,
      name: fields[2] as String?,
      age: fields[3] as int?,
      gender: fields[4] as String?,
      created_at: fields[5] as String?,
      updated_at: fields[6] as String?,
      profile_image: fields[7] as String?,
      keyclock_secret: fields[8] as String?,
      email_verified: fields[9] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.user_id)
      ..writeByte(1)
      ..write(obj.email_id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.created_at)
      ..writeByte(6)
      ..write(obj.updated_at)
      ..writeByte(7)
      ..write(obj.profile_image)
      ..writeByte(8)
      ..write(obj.keyclock_secret)
      ..writeByte(9)
      ..write(obj.email_verified);
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
