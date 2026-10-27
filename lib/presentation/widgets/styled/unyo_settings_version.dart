import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/core/di/locator.dart';
import 'package:unyo/core/services/update/release_page_launcher.dart';
import 'package:unyo/core/services/update/update_check_result.dart';
import 'package:unyo/core/services/update/update_checker_service.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';

/// Settings -> About: the running version and, when the startup check found a
/// newer release, a row linking to its GitHub page. Reads the verdict the
/// update check already produced — it never triggers a check of its own.
class UnyoSettingsVersion extends StatelessWidget {
  const UnyoSettingsVersion({super.key});

  @override
  Widget build(BuildContext context) {
    final updateCheckerService = sl<UpdateCheckerService>();
    final currentVersion = updateCheckerService.lastCheckedVersion;
    final lastResult = updateCheckerService.lastResult;
    return Column(
      children: [
        _SettingsInfoRow(
          title: "Version",
          description:
              currentVersion == null
                  ? "Version unavailable"
                  : "Unyo v$currentVersion",
        ),
        if (lastResult is UpdateAvailable)
          _SettingsInfoRow(
            title: "Update available: v${lastResult.latestVersion}",
            description: "A newer release is available to download from GitHub",
            icon: Icons.system_update_rounded,
            actionLabel: "Open releases page",
            onAction: () =>
                ReleasePageLauncher.openPage(lastResult.release.htmlUrl),
          ),
      ],
    );
  }
}

/// Read-only settings row: icon, title, description and an optional
/// call-to-action button. Private because [UnyoSettingsVersion] is its only
/// user; the settings options that other categories show are their own widgets.
class _SettingsInfoRow extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final void Function()? onAction;

  const _SettingsInfoRow({
    required this.title,
    required this.description,
    this.icon = Icons.info_rounded,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final showAction = actionLabel != null && onAction != null;
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      height: 75,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 47,
                  height: 47,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ColorScheme.of(context).primary.withValues(alpha: 0.2),
                  ),
                  child: Icon(icon, color: ColorScheme.of(context).tertiary),
                ),
                const SizedBox(width: 18.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            if (showAction)
              DarkUnyoButton(
                text: actionLabel,
                height: 40,
                minWidth: 160,
                onPressed: onAction!,
              ),
          ],
        ),
      ),
    );
  }
}
