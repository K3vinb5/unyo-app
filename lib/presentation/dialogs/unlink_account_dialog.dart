import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/domain/entities/user/user.dart';
import 'package:unyo/presentation/dialogs/unyo_dialog_theme.dart';
import 'package:unyo/presentation/dialogs/user_profile_dialog.dart';
import 'package:unyo/presentation/widgets/styled/dark_unyo_button.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';

/// Confirmation between the drawer's "Unlink account…" and the removal (WP
/// #151). It names the account and the provider, because the drawer is showing
/// the signed-in user's own card and the destructive action deserves an explicit
/// "which one".
///
/// Cancel is the safe default: it is the dark, secondary button, and it is the
/// only one focus starts on. The confirm button is the family's standard
/// [LightUnyoButton] tinted with the scheme error colour instead of a bespoke
/// destructive pill (WP #117).
class UnlinkAccountDialog extends StatelessWidget {
  /// Width of the confirmation card, in the profile card's family proportions.
  static const double width = 420;

  /// The destructive action, for tests and the driven run.
  static const Key confirmKey = ValueKey<String>('unlink-dialog-confirm');

  /// The safe default.
  static const Key cancelKey = ValueKey<String>('unlink-dialog-cancel');

  final User user;

  /// Runs the removal. The dialog closes first so the effect lands on the screen
  /// the routing replaces, not on a dialog that is about to be unmounted.
  final VoidCallback onConfirm;

  const UnlinkAccountDialog({
    super.key,
    required this.user,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(unyoDialogCardRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: width),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[scheme.dialogWashTop, scheme.dialogSurface],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: scheme.error.withValues(alpha: 0.18),
                      ),
                      child: Icon(Icons.link_off_rounded, color: scheme.error),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            context.tr('dialog_unlink_title'),
                            style: TextStyle(
                              color: scheme.dialogText,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            UserProfileDialog.providerLabel(context, user),
                            style: TextStyle(color: scheme.dialogDim, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  context.tr(
                    'dialog_unlink_body',
                    namedArgs: <String, String>{'name': user.name},
                  ),
                  style: TextStyle(
                    color: scheme.dialogBody,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    DarkUnyoButton(
                      key: cancelKey,
                      text: context.tr('common_cancel'),
                      minWidth: 110,
                      height: 44,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    LightUnyoButton(
                      key: confirmKey,
                      text: context.tr('dialog_unlink_confirm'),
                      color: scheme.error,
                      textColor: Colors.white,
                      minWidth: 160,
                      height: 44,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
