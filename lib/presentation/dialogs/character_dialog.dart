import 'package:material_ui/material_ui.dart';

// Internal dependencies
import 'package:unyo/domain/entities/media/media_character.dart';
import 'package:unyo/presentation/dialogs/unyo_dialog_theme.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

/// Surface the split-profile card paints on (the "Split profile" artboard).
const Color characterDialogSurface = Color(0xFF1F1F1F);

/// Body copy of the description block.
const Color characterDialogBody = Color(0xFFB8B8B8);

/// Hairline between two fact rows.
const Color characterDialogRule = Color(0xFF2A2A2A);

/// Width of the card, matching the artboard (1280×768 design canvas).
const double characterDialogWidth = 880;

/// Height the card grows to at most; shorter characters keep a shorter card.
///
/// The artboard draws the card at 540 with a 12px description; the family body
/// (14px, 165%) and the bold fact values need the extra room, so the card gets
/// 600 before the description block starts scrolling.
const double characterDialogMaxHeight = 600;

/// Width of the portrait column.
const double characterDialogPortraitWidth = 292;

/// Measure of the description block.
const double characterDialogDescriptionWidth = 508;

/// Height the description block may occupy before it scrolls, keeping the card
/// at the artboard height whatever the provider sends.
const double characterDialogDescriptionMaxHeight = 171;

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
/// are always shown; the chips, the fact rows and the description only appear
/// when the data is real (see [MediaCharacterDetails]). The portrait reuses the
/// character card's Hero tag so the shared-element transition carries over from
/// the row.
///
/// Restyled to the "Split profile" artboard (WP #108 / PR #159 D2): a full-bleed
/// portrait column on the left and a 32px name, 28px chips, dim/bold fact rows
/// and a 508-wide 160%-leading description on the right.
class CharacterDialog extends StatelessWidget {
  final MediaCharacter character;

  const CharacterDialog({super.key, required this.character});

  /// Chip label for the gender, when the provider supplied one.
  static const Key genderChipKey = ValueKey<String>('character-dialog-chip-gender');
  static const Key ageChipKey = ValueKey<String>('character-dialog-chip-age');
  static const Key nameKey = ValueKey<String>('character-dialog-name');
  static const Key descriptionKey = ValueKey<String>('character-dialog-description');
  static const Key closeKey = ValueKey<String>('character-dialog-close');
  static const Key cardKey = ValueKey<String>('character-dialog-card');

  @override
  Widget build(BuildContext context) {
    final String? description = character.descriptionText;
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Dialog(
      backgroundColor: characterDialogSurface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(unyoDialogCardRadius)),
      child: SizedBox(
        key: CharacterDialog.cardKey,
        width: characterDialogWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: characterDialogMaxHeight < maxHeight ? characterDialogMaxHeight : maxHeight,
          ),
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
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildHeader(context),
                      if (character.hasGender || character.hasAge) ...<Widget>[
                        const SizedBox(height: 17),
                        _buildChips(),
                      ],
                      if (character.hasGender || character.hasAge || character.hasDateOfBirth) ...<Widget>[
                        const SizedBox(height: 24),
                        _buildFactRows(),
                      ],
                      if (description != null) ...<Widget>[
                        const SizedBox(height: 24),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: characterDialogDescriptionWidth,
                            maxHeight: characterDialogDescriptionMaxHeight,
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              description,
                              key: descriptionKey,
                              style: const TextStyle(
                                color: characterDialogBody,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'CHARACTER',
                style: TextStyle(
                  color: unyoDialogAccent,
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
                style: const TextStyle(
                  color: unyoDialogText,
                  fontSize: 32,
                  height: 1.18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _ClosePill(onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }

  Widget _buildChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: <Widget>[
        if (character.hasGender)
          _CharacterChip(key: genderChipKey, label: character.gender.trim()),
        if (character.hasAge)
          _CharacterChip(key: ageChipKey, label: "Age ${character.age}"),
      ],
    );
  }

  Widget _buildFactRows() {
    final List<(String, String)> facts = <(String, String)>[
      if (character.hasGender) ('GENDER', character.gender.trim()),
      if (character.hasAge) ('AGE', '${character.age}'),
      if (character.hasDateOfBirth) ('BIRTHDAY', character.dateOfBirth.trim()),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final (String label, String value) in facts)
          Padding(
            padding: EdgeInsets.only(bottom: label == facts.last.$1 ? 0 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: unyoDialogDim,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: unyoDialogText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: characterDialogDescriptionWidth,
                  height: 1,
                  color: characterDialogRule,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// 28px chip of the family language: translucent white fill, dim white label.
class _CharacterChip extends StatelessWidget {
  const _CharacterChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: unyoDialogText,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// The family's primary action: a filled accent pill.
class _ClosePill extends StatelessWidget {
  const _ClosePill({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return UnyoInkWell(
      key: CharacterDialog.closeKey,
      onTap: onPressed,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: unyoDialogAccent,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.close, size: 16, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Close',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
