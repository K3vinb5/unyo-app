import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/presentation/dialogs/unyo_dialog_theme.dart';
import 'package:unyo/presentation/widgets/styled/light_unyo_button.dart';

/// Every unfinished feature that the UI offers (WP #148).
///
/// This enum is the single registry: a feature is added by adding one value,
/// and removed by deleting the value plus its call site. [titleKey] and
/// [bodyKey] are translation keys so the dialog is translated like the rest of
/// the app, and neither is a free-form string at a call site.
enum ComingSoonFeature {
  malAccounts(titleKey: 'coming_soon_mal_accounts_title', bodyKey: 'coming_soon_mal_accounts_body'),
  localAccounts(titleKey: 'coming_soon_local_accounts_title', bodyKey: 'coming_soon_local_accounts_body'),
  mangaReader(titleKey: 'coming_soon_manga_reader_title', bodyKey: 'coming_soon_manga_reader_body'),
  mangaReaderSettings(titleKey: 'coming_soon_reader_settings_title', bodyKey: 'coming_soon_reader_settings_body'),
  mangaProviderMissing(titleKey: 'coming_soon_manga_provider_title', bodyKey: 'coming_soon_manga_provider_body');

  const ComingSoonFeature({required this.titleKey, required this.bodyKey});

  /// What the feature is.
  final String titleKey;

  /// That it is not available yet, plus what works instead where relevant.
  final String bodyKey;
}

/// One dismiss-only notice for a feature that is not implemented yet.
///
/// Deliberately one shape for every feature: the copy varies through
/// [ComingSoonFeature], not through a bespoke layout. It reuses the profile
/// dialog family's geometry and colours ([unyoDialogCardRadius],
/// [UnyoDialogScheme]) so it reads as the same product as the rest of the
/// dialogs (WP #108/#117).
///
/// Call [show] so the route above the current screen is pushed the same way at
/// every dead end. The widget itself stays usable directly (the effect pipeline
/// can host it too).
class ComingSoonDialog extends StatelessWidget {
  /// Width of the card, matching the other confirmation dialogs.
  static const double width = 420;

  /// The single action: acknowledge and close.
  static const Key dismissKey = ValueKey<String>('coming-soon-dismiss');

  /// Key of the dialog for [feature], so a driven run can tell features apart.
  static Key dialogKey(ComingSoonFeature feature) => ValueKey<String>('coming-soon-${feature.name}');

  final ComingSoonFeature feature;

  const ComingSoonDialog({super.key, required this.feature});

  /// Opens the notice above [context]'s route.
  ///
  /// Defaults to the root navigator on purpose: login is opened from the
  /// Add-account dialog, and the notice must sit above it instead of replacing
  /// it.
  static Future<void> show(BuildContext context, ComingSoonFeature feature) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) => ComingSoonDialog(feature: feature),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.of(context);
    return Dialog(
      key: dialogKey(feature),
      backgroundColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(unyoDialogCardRadius)),
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
                        color: scheme.dialogAccent.withValues(alpha: 0.16),
                      ),
                      child: Icon(Icons.hourglass_bottom_rounded, color: scheme.dialogAccent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        context.tr(feature.titleKey),
                        style: TextStyle(color: scheme.dialogText, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  context.tr(feature.bodyKey),
                  style: TextStyle(color: scheme.dialogBody, fontSize: 13, height: 1.45),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: LightUnyoButton(
                    key: dismissKey,
                    text: context.tr('coming_soon_dismiss'),
                    minWidth: 110,
                    height: 44,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
