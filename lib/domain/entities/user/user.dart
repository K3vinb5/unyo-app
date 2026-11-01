import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:unyo/domain/entities/user/settings.dart';

part 'user.freezed.dart';

abstract class User {
  final String id;
  final String name;
  final Settings settings;
  final String avatarImage;
  final String bannerImage;

  User(this.id, {required this.settings, required this.name, required this.avatarImage, required this.bannerImage});
}

@freezed
abstract class UserModel with _$UserModel implements User {
  const factory UserModel({
    required String id,
    required String name,
    required Settings settings,
    required String avatarImage,
    required String bannerImage,
  }) = _UserModel;

  factory UserModel.empty() => UserModel(
    id: '',
    name: '',
    settings: SettingsModel.empty(),
    // Empty = no picture: the UI renders the bundled default avatar
    // (WP #102). Never a third-party URL — a local account must not
    // depend on a remote image host for its placeholder.
    avatarImage: '',
    bannerImage: '',
  );
}