// External dependencies
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

// Internal dependencies
import 'package:unyo/application/cubits/effect_mixin.dart';
import 'package:unyo/application/effects/app_effects.dart';
import 'package:unyo/application/states/update_state.dart';
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/update/app_version_provider.dart';
import 'package:unyo/core/services/update/release_page_launcher.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/core/services/update/update_checker_service.dart';

/// Owns the single, app-wide update check.
///
/// Notify-only: it never downloads or installs anything. The check runs once
/// per process launch (kicked from `main`) and every failure is silent apart
/// from a log line.
class UpdateCubit extends Cubit<UpdateState> with EffectMixin<UpdateState> {
  final UpdateCheckerService _updateCheckerService;
  final AppVersionProvider _versionProvider;
  final Logger _logger;

  /// Guards "once per process launch": repeat calls (hot reload, a second
  /// widget kick-off) are no-ops.
  bool _checkStarted = false;

  UpdateCubit(
    this._updateCheckerService,
    this._versionProvider, {
    Logger? logger,
  }) : _logger = logger ?? sl<Logger>(),
       super(const UpdateState());

  @override
  Logger get logger => _logger;

  @override
  UpdateState copyStateWithEffects(UpdateState state, List<AppEffect> effects) {
    return state.copyWith(effects: effects);
  }

  Future<void> checkForUpdate() async {
    if (_checkStarted) {
      _logger.d("Update check already ran in this process launch, skipping");
      return;
    }
    _checkStarted = true;

    final currentVersion = await _versionProvider.currentVersion();
    if (isClosed) return;
    emit(UpdateState(status: UpdateStatus.checking, currentVersion: currentVersion));
    if (currentVersion == null) {
      _logger.w("Cannot check for updates: the current app version is unavailable");
      emit(const UpdateState(status: UpdateStatus.checkFailed, failureReason: 'Current version unavailable'));
      return;
    }

    final result = await _updateCheckerService.checkForUpdate(currentVersion);
    if (isClosed) return;
    switch (result) {
      case UpToDate():
        emit(UpdateState(status: UpdateStatus.upToDate, currentVersion: currentVersion));
      case UpdateAvailable(:final latestVersion, :final releaseUrl):
        // Emit the result and its one-shot notice together so the listener sees
        // a single state change (the effect instance is handled only once).
        emit(
          UpdateState(
            status: UpdateStatus.updateAvailable,
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            releaseUrl: releaseUrl,
            effects: [
              ShowSnackbarEffect(
                "Update available",
                message: "Unyo v$latestVersion is ready to download.",
                contentType: ContentType.warning,
                actionLabel: "Open releases page",
                onAction: () => openReleasePage(releaseUrl),
                duration: const Duration(seconds: 10),
              ),
            ],
          ),
        );
      case UpdateCheckFailed(:final reason):
        _logger.w("Update check failed: $reason");
        emit(
          UpdateState(
            status: UpdateStatus.checkFailed,
            currentVersion: currentVersion,
            failureReason: reason,
          ),
        );
    }
  }
}
