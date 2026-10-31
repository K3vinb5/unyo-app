import 'package:material_ui/material_ui.dart';

/// Shared visual language of the profile, character and theme-picker dialogs
/// (WP #108): the three restyled dialogs have to read as one product family.
///
/// Only the values every card agrees on live here — the card surfaces stay with
/// their own dialog, because each artboard picks a different tonal surface.

/// Accent of the family: primary actions, eyebrows and the active mode marker.
const Color unyoDialogAccent = Color(0xFF9266A8);

/// Primary text of the family.
const Color unyoDialogText = Color(0xFFF4F2F7);

/// Secondary/dim text of the family (eyebrows, labels, provider subtitle).
const Color unyoDialogDim = Color(0xFFA9A3B4);

/// Corner radius every card in the family uses.
const double unyoDialogCardRadius = 24;
