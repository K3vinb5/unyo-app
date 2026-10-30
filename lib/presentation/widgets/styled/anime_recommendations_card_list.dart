import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:unyo/presentation/widgets/skeleton/skeleton_metrics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/core/enums/media_type.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/presentation/widgets/styled/media_card.dart';
import 'package:unyo/presentation/widgets/styled/media_list_arrows.dart';
import 'package:unyo/presentation/widgets/text/media_title_text.dart';

class AnimeRecommendationCardList extends StatelessWidget {
  final void Function(Anime, MediaList) onPressed;
  final String listTitle;
  final List<Anime> animeList;
  final ScrollController controller;
  final bool loadMore;

  const AnimeRecommendationCardList({
    super.key,
    required this.onPressed,
    required this.listTitle,
    required this.animeList,
    required this.controller,
    required this.loadMore,
  });

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
                  listTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ColorScheme.of(context).tertiary,
                  ),
                ),
                Text(
                  "  ${animeList.length.toString()} ${context.tr("entries")}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                MediaListArrows(
                  controller: controller,
                  visible: animeList.length * 144 > 0.75.sw,
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h,),
          SizedBox(
            height: CardRowMetrics.rowHeight,
            width: 1.sw - 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              controller: controller,
              children: [
                ...animeList.map(
                  (anime) => MediaCard(
                    title: displayMediaTitle(anime.title),
                    score: anime.averageScore,
                    coverImage: anime.coverImage,
                    onPressed: () => onPressed(anime, MediaListModel(name: listTitle, mediaType: MediaType.anime)),
                    status: anime.status,
                    year: anime.startDate,
                    format: anime.format,
                    tag: "$listTitle-${anime.id}",
                  ),
                ),
                // TODO loadMore Widget
              ],
            ),
          ),
        ],
      ),
    );
  }
}