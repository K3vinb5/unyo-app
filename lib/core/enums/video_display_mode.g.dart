// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_display_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoDisplayModeAdapter extends TypeAdapter<VideoDisplayMode> {
  @override
  final typeId = 11;

  @override
  VideoDisplayMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VideoDisplayMode.fit;
      case 1:
        return VideoDisplayMode.crop;
      case 2:
        return VideoDisplayMode.stretch;
      default:
        return VideoDisplayMode.fit;
    }
  }

  @override
  void write(BinaryWriter writer, VideoDisplayMode obj) {
    switch (obj) {
      case VideoDisplayMode.fit:
        writer.writeByte(0);
      case VideoDisplayMode.crop:
        writer.writeByte(1);
      case VideoDisplayMode.stretch:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoDisplayModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
