import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/domain/entities/media/media_character.dart';
import 'package:unyo/presentation/dialogs/unyo_dialog_theme.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

/// Width of the card, matching the artboard (1280×768 design canvas).
const double characterDialogWidth = 880;

/// Height of the card. Fixed, not content-driven: the card used to grow with
/// the data, so a name-only character opened a short dialog and a described one
/// a tall one, which read as broken layout. Every section now stays present and
/// the card always occupies this height (capped to the window).
const double characterDialogHeight = 600;

/// Width of the portrait column.
const double characterDialogPortraitWidth = 292;

/// Measure of the description block.
const double characterDialogDescriptionWidth = 508;

/// What a slot with no data says, instead of collapsing its row.
const String characterDialogPlaceholder = 'Not available';

/// Which parts of a [MediaCharacter] are genuinely known.
///
/// Providers disagree on how "no value" looks: AniList sends an empty string, a
/// `0/0/0` birthday, an age of `-1`, while Shikimori sends the literal
/// `"Unknown"` / `"No description available"` sentinels. Every rule lives here
/// so the dialog never has to ask which provider produced the character.
extension MediaCharacterDetails on MediaCharacter {
  static const String _unknownWord = 'unknown';
  static const String _noDescription = 'no description available';
  static const String _emptyBirthday = '0/0/0';

  /// `""` (AniList) and `"Unknown"` (Shikimori) both mean "not provided".
  bool get hasGender {
    final String value = gender.trim().toLowerCase();
    return value.isNotEmpty && value != _unknownWord;
  }

  /// AniList reports an absent age as `-1`; zero is not a believable age either.
  bool get hasAge => age > 0;

  bool get hasDateOfBirth {
    final String value = dateOfBirth.trim();
    return value.isNotEmpty &&
        value != _emptyBirthday &&
        value.toLowerCase() != _unknownWord;
  }

  bool get hasDescription {
    final String value = description.trim().toLowerCase();
    return value.isNotEmpty && value != _noDescription;
  }

  /// The description as display text, or `null` when the provider sent only a
  /// sentinel. AniList descriptions are raw HTML, Shikimori's is plain text.
  String? get descriptionText =>
      hasDescription ? TextUtils.parseHtmlToPlainText(description) : null;
}

/// Read-only view of a character the details page already loaded.
///
/// Purely presentational: no fetch, no cubit, no navigation. Portrait and name
/// are always shown, and so are the chips, the three fact rows and the
/// description block — a slot the provider did not fill renders
/// [characterDialogPlaceholder] instead of disappearing, so the card keeps one
/// footprint whatever the character carries (WP #117). A long description
/// scrolls inside its own block rather than growing the card.
///
/// Restyled to the "Split profile" artboard (WP #108 / PR #159 D2): a full-bleed
/// portrait column on the left and a 32px name, 28px chips, dim/bold fact rows
/// and a 508-wide 160%-leading description on the right. Colours follow the
/// active [ColorScheme] (WP #117).
class CharacterDialog extends StatelessWidget {
  final MediaCharacter character;

  const CharacterDialog({super.key, required this.character});

  /// Chip label for the gender, when the provider supplied one.
  static const Key genderChipKey = ValueKey<String>('character-dialog-chip-gender');
  static const Key ageChipKey = ValueKey<String>('character-dialog-chip-age');

  /// The single chip that stands in for both facts when neither is known.
  static const Key placeholderChipKey = ValueKey<String>('character-dialog-chip-placeholder');
  static const Key nameKey = ValueKey<String>('character-dialog-name');
  static const Key descriptionKey = ValueKey<String>('character-dialog-description');
  static const Key closeKey = ValueKey<String>('character-dialog-close');
  static const Key cardKey = ValueKey<String>('character-dialog-card');

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.of(context);
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Dialog(
      backgroundColor: scheme.dialogSurface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(unyoDialogCardRadius)),
      child: SizedBox(
        key: CharacterDialog.cardKey,
        width: characterDialogWidth,
        height: characterDialogHeight < maxHeight ? characterDialogHeight : maxHeight,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 4,
              top: 4,
              bottom: 4,
              width: characterDialogPortraitWidth,
              child: Hero(
                tag: "${character.id}",
                child: UnyoNetworkImage(
                  url: character.image,
                  fit: BoxFit.cover,
                  borderRadius: 22,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                characterDialogPortraitWidth + 48,
                32,
                32,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(context, scheme),
                  const SizedBox(height: 17),
                  _buildChips(scheme),
                  const SizedBox(height: 24),
                  _buildFactRows(scheme),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SizedBox(
                      width: characterDialogDescriptionWidth,
                      child: SingleChildScrollView(
                        child: _buildDescription(scheme),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme scheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'CHARACTER',
                style: TextStyle(
                  color: scheme.dialogAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.32,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                character.name,
                key: nameKey,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.dialogText,
                  fontSize: 32,
                  height: 1.18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _CloseGlyph(scheme: scheme, onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }

  Widget _buildChips(ColorScheme scheme) {
    final List<Widget> chips = <Widget>[
      if (character.hasGender)
        _CharacterChip(
          key: genderChipKey,
          label: character.gender.trim(),
          scheme: scheme,
        ),
      if (character.hasAge)
        _CharacterChip(key: ageChipKey, label: "Age ${character.age}", scheme: scheme),
    ];
    if (chips.isEmpty) {
      chips.add(
        _CharacterChip(
          key: placeholderChipKey,
          label: characterDialogPlaceholder,
          scheme: scheme,
          isPlaceholder: true,
        ),
      );
    }
    return Wrap(spacing: 10, runSpacing: 8, children: chips);
  }

  /// The three fact rows, always: a missing value renders
  /// [characterDialogPlaceholder] rather than dropping its row.
  Widget _buildFactRows(ColorScheme scheme) {
    final List<(String, String?)> facts = <(String, String?)>[
      ('GENDER', character.hasGender ? character.gender.trim() : null),
      ('AGE', character.hasAge ? '${character.age}' : null),
      ('BIRTHDAY', character.hasDateOfBirth ? character.dateOfBirth.trim() : null),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final (String label, String? value) in facts)
          Padding(
            padding: EdgeInsets.only(bottom: label == facts.last.$1 ? 0 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    color: scheme.dialogDim,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? characterDialogPlaceholder,
                  style: TextStyle(
                    color: value == null ? scheme.dialogDim : scheme.dialogText,
                    fontSize: 14,
                    fontWeight: value == null ? FontWeight.w400 : FontWeight.w700,
                    fontStyle: value == null ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: characterDialogDescriptionWidth,
                  height: 1,
                  color: scheme.dialogRule,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// The description block, always present: the provider's text, or the
  /// placeholder when it sent only a sentinel.
  Widget _buildDescription(ColorScheme scheme) {
    final String? description = character.descriptionText;
    return Text(
      description ?? characterDialogPlaceholder,
      key: descriptionKey,
      style: TextStyle(
        color: description == null ? scheme.dialogDim : scheme.dialogBody,
        fontSize: 14,
        height: 1.6,
        fontStyle: description == null ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }
}

/// 28px chip of the family language: translucent fill, dim white label.
class _CharacterChip extends StatelessWidget {
  const _CharacterChip({
    super.key,
    required this.label,
    required this.scheme,
    this.isPlaceholder = false,
  });

  final String label;
  final ColorScheme scheme;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: scheme.dialogChipFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isPlaceholder ? scheme.dialogDim : scheme.dialogText,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }
}

/// The dialog's only action: a low-contrast circular glyph button (WP #117).
///
/// 44×44 hit target, no label, tooltip and semantics for screen readers, and
/// hover/pressed feedback from the ink well.
class _CloseGlyph extends StatelessWidget {
  const _CloseGlyph({required this.scheme, required this.onPressed});

  final ColorScheme scheme;
  final VoidCallback onPressed;

  static const double hitTarget = 44;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Close',
      excludeFromSemantics: true,
      child: Semantics(
        container: true,
        label: 'Close',
        button: true,
        onTap: onPressed,
        child: SizedBox(
          width: hitTarget,
          height: hitTarget,
          child: UnyoInkWell(
            key: CharacterDialog.closeKey,
            onTap: onPressed,
            customBorder: const CircleBorder(),
            borderRadius: BorderRadius.circular(hitTarget / 2),
            hoverColor: scheme.dialogText.withValues(alpha: 0.10),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.dialogText.withValues(alpha: 0.06),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                size: 18,
                color: scheme.dialogDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
