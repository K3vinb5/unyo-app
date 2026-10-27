import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_metrics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/domain/entities/media/media_character.dart' show MediaCharacter;
import 'package:unyo/presentation/widgets/styled/media_list_arrows.dart';
import 'package:unyo/presentation/widgets/styled/unyo_character.dart';

class UnyoCharacterList extends StatelessWidget {
  final List<MediaCharacter> characters;
  final ScrollController controller;

  const UnyoCharacterList({super.key, required this.characters, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 0.75.sw,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Characters",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ColorScheme.of(context).tertiary,
                  ),
                ),
                Text(
                  "  ${characters.length.toString()} ${context.tr("entries")}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                MediaListArrows(
                  controller: controller,
                  visible: characters.length * 144 > (0.75.sw),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: CardRowMetrics.rowHeight,
            width: 1.sw - 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              controller: controller,
              children: [
                ...characters.map(
                  (character) => UnyoCharacter(
                    tag: "${character.id}",
                    onPressed: null,
                    image: character.image,
                    name: character.name,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
