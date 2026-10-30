// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shikimori_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShikimoriUserModelAdapter extends TypeAdapter<ShikimoriUserModel> {
  @override
  final typeId = 10;

  @override
  ShikimoriUserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShikimoriUserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      settings: fields[2] as Settings,
      avatarImage: fields[3] as String,
      bannerImage: fields[4] as String,
      accessToken: fields[5] as String,
      refreshToken: fields[6] as String,
      accessTokenExpiresAt: fields[7] as String,
      profileUrl: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShikimoriUserModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.settings)
      ..writeByte(3)
      ..write(obj.avatarImage)
      ..writeByte(4)
      ..write(obj.bannerImage)
      ..writeByte(5)
      ..write(obj.accessToken)
      ..writeByte(6)
      ..write(obj.refreshToken)
      ..writeByte(7)
      ..write(obj.accessTokenExpiresAt)
      ..writeByte(8)
      ..write(obj.profileUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShikimoriUserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShikimoriUserModel _$ShikimoriUserModelFromJson(Map<String, dynamic> json) =>
    _ShikimoriUserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      settings: const SettingsConverter().fromJson(
        json['settings'] as Map<String, dynamic>,
      ),
      avatarImage: json['avatarImage'] as String,
      bannerImage: json['bannerImage'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiresAt: json['accessTokenExpiresAt'] as String,
      profileUrl: json['profileUrl'] as String,
    );

Map<String, dynamic> _$ShikimoriUserModelToJson(_ShikimoriUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'settings': const SettingsConverter().toJson(instance.settings),
      'avatarImage': instance.avatarImage,
      'bannerImage': instance.bannerImage,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'accessTokenExpiresAt': instance.accessTokenExpiresAt,
      'profileUrl': instance.profileUrl,
    };
