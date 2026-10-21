import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/core/enums/media_type.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/presentation/widgets/styled/media_card.dart';
import 'package:unyo/presentation/widgets/styled/media_list_arrows.dart';

class MangaRecommendationCardList extends StatelessWidget {
  final void Function(Manga, MediaList) onPressed;
  final String listTitle;
  final List<Manga> mangaList;
  final ScrollController controller;
  final bool loadMore;

  const MangaRecommendationCardList({
    super.key,
    required this.onPressed,
    required this.listTitle,
    required this.mangaList,
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
                  "  ${mangaList.length.toString()} ${context.tr("entries")}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                MediaListArrows(
                  controller: controller,
                  visible: mangaList.length * 144 > 0.75.sw,
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h,),
          SizedBox(
            height: 260,
            width: 1.sw - 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              controller: controller,
              children: [
                ...mangaList.map(
                      (manga) => MediaCard(
                    title: manga.title.romaji,
                    score: manga.averageScore,
                    coverImage: manga.coverImage,
                    onPressed: () => onPressed(manga, MediaListModel(name: listTitle, mediaType: MediaType.manga)),
                    status: manga.status,
                    year: manga.startDate,
                    format: manga.format,
                    tag: "$listTitle-${manga.id}",
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