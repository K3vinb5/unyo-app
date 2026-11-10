import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/core/services/update/update_checker_service.dart';

/// The update-available marker the Settings → About row keeps showing after the
/// category stopped expanding (WP #150).
///
/// Reads the verdict the startup check already produced — it never triggers a
/// check of its own, and it renders nothing (zero width, zero height) when the
/// app is up to date, so the default row appearance is unchanged. The dialog
/// carries the full notice and the "open releases page" action.
class UnyoSettingsUpdateBadge extends StatelessWidget {
  const UnyoSettingsUpdateBadge({super.key, this.result});

  /// The startup check's verdict. Injected by tests; defaults to the DI'd one.
  final UpdateCheckResult? result;

  @override
  Widget build(BuildContext context) {
    final UpdateCheckResult? lastResult = result ?? sl<UpdateCheckerService>().lastResult;
    if (lastResult is! UpdateAvailable) return const SizedBox.shrink();
    final ColorScheme scheme = ColorScheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: scheme.primary.withValues(alpha: 0.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.system_update_rounded, size: 15, color: scheme.tertiary),
          const SizedBox(width: 6),
          Text(
            'v${lastResult.latestVersion}',
            style: TextStyle(
              color: scheme.tertiary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
