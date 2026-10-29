import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Internal dependencies
import 'package:unyo/domain/entities/media/media_character.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

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
/// are always shown; the chips and the description only appear when the data is
/// real (see [MediaCharacterDetails]). The portrait reuses the character card's
/// Hero tag so the shared-element transition carries over from the row.
class CharacterDialog extends StatelessWidget {
  final MediaCharacter character;

  const CharacterDialog({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? description = character.descriptionText;

    return Dialog(
      backgroundColor: scheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 760.w, maxHeight: 620.h),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.0.w, vertical: 24.0.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      character.name,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  IconButton(
                    tooltip: "Close",
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: "${character.id}",
                        child: UnyoNetworkImage(
                          url: character.image,
                          width: 200.w,
                          height: 280.h,
                          fit: BoxFit.cover,
                          borderRadius: 16.0,
                        ),
                      ),
                      SizedBox(width: 24.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: [
                                if (character.hasGender)
                                  _CharacterInfoChip(
                                    icon: Icons.person,
                                    label: character.gender.trim(),
                                  ),
                                if (character.hasAge)
                                  _CharacterInfoChip(
                                    icon: Icons.numbers,
                                    label: "Age ${character.age}",
                                  ),
                                if (character.hasDateOfBirth)
                                  _CharacterInfoChip(
                                    icon: Icons.cake,
                                    label:
                                        "Born ${character.dateOfBirth.trim()}",
                                  ),
                              ],
                            ),
                            if (description != null) ...[
                              SizedBox(height: 20.h),
                              Text(
                                description,
                                style: textTheme.bodyMedium?.copyWith(
                                  height: 1.45,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
}

class _CharacterInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CharacterInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
