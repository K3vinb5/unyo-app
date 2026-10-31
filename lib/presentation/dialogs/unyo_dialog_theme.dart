import 'package:material_ui/material_ui.dart';

/// Shared visual language of the profile, character and theme-picker dialogs
/// (WP #108): the three restyled dialogs have to read as one product family.
///
/// Only the geometry every card agrees on lives here. The colours are derived
/// from the active [ColorScheme] instead of a baked palette (WP #117): the
/// dialogs used to paint a fixed purple accent, which kept the family purple
/// whatever theme colour the user picked. Every getter below
/// reads the scheme the app builds from `settings.themeColor`
/// (`lib/core/theme/theme_service.dart`), so a theme swap recolours the cards
/// exactly like the rest of the app.

/// Corner radius every card in the family uses.
const double unyoDialogCardRadius = 24;

/// Palette of the dialog family, derived from the current [ColorScheme].
///
/// Use through `ColorScheme.of(context)`, the idiom the rest of the app already
/// follows (`settings_screen.dart`, `root_screen.dart`).
extension UnyoDialogScheme on ColorScheme {
  /// Card body: the scheme surface nudged towards the accent, so the card is
  /// recognisably part of the theme without giving up its dark tone.
  Color get dialogSurface => Color.lerp(surface, primary, 0.06)!;

  /// Top of the profile card wash — the same surface with more accent in it.
  Color get dialogWashTop => Color.lerp(surface, primary, 0.16)!;

  /// Accent of the family: eyebrows, active markers, halos.
  Color get dialogAccent => primary;

  /// Copy that sits on top of an accent fill.
  Color get dialogOnAccent => onPrimary;

  /// Primary copy (names, fact values).
  Color get dialogText => onSurface;

  /// Secondary/dim copy: eyebrows, field labels, "Not available" placeholders.
  Color get dialogDim => onSurface.withValues(alpha: 0.7);

  /// Long body copy (the character description).
  Color get dialogBody => onSurface.withValues(alpha: 0.82);

  /// Hairline rules between fact rows.
  Color get dialogRule => onSurface.withValues(alpha: 0.12);

  /// Chip fill: a barely-there wash of the copy colour.
  Color get dialogChipFill => onSurface.withValues(alpha: 0.07);
}
