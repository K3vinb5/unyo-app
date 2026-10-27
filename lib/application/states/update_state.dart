// External dependencies
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';

enum UpdateStatus { initial, checking, upToDate, updateAvailable, checkFailed }

class UpdateState implements HasEffects {
  final UpdateStatus status;

  /// Version the running build reports (null until it has been read).
  final String? currentVersion;
  final String? latestVersion;
  final String? releaseUrl;
  final String? failureReason;
  final List<AppEffect> effects;

  const UpdateState({
    this.status = UpdateStatus.initial,
    this.currentVersion,
    this.latestVersion,
    this.releaseUrl,
    this.failureReason,
    this.effects = const <AppEffect>[],
  });

  bool get isUpdateAvailable => status == UpdateStatus.updateAvailable;

  UpdateState copyWith({
    UpdateStatus? status,
    String? currentVersion,
    String? latestVersion,
    String? releaseUrl,
    String? failureReason,
    List<AppEffect>? effects,
  }) {
    return UpdateState(
      status: status ?? this.status,
      currentVersion: currentVersion ?? this.currentVersion,
      latestVersion: latestVersion ?? this.latestVersion,
      releaseUrl: releaseUrl ?? this.releaseUrl,
      failureReason: failureReason ?? this.failureReason,
      effects: effects ?? this.effects,
    );
  }

  @override
  List<AppEffect> get stateEffects => effects;
}
