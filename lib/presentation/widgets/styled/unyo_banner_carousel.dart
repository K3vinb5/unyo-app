import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unyo/core/enums/media_type.dart';
import 'package:unyo/domain/entities/media/anime.dart';
import 'package:unyo/domain/entities/media/manga.dart';
import 'package:unyo/domain/entities/list/media_list.dart';
import 'package:unyo/presentation/widgets/styled/media_hero_art.dart';
import 'package:unyo/presentation/widgets/styled/unyo_ink_well.dart';
import 'package:unyo/presentation/widgets/styled/unyo_network_image.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';
import 'package:unyo/presentation/widgets/text/texts.dart';
import 'package:unyo/presentation/widgets/text/media_title_text.dart';

/// What the browse screens' banner slot shows.
///
/// Every provider resolves hero art now: the banner when the API has one, else
/// the card's cover (MAL/Jikan v4 exposes no banner asset at all —
/// `MalAnimeModel.fromNode` sets `bannerImage: ''` — so before covers counted,
/// the slot shimmered forever for that provider; WP #166 live evidence
/// `research/unyo-166-mal-metadata-proof/EVIDENCE.md` §1 3a).
enum BannerHeaderMode {
  /// First load in flight and no art yet.
  skeleton,

  /// The loaded provider has hero art.
  carousel,

  /// Loaded and the provider returned no art at all (neither banner nor
  /// cover on any card): the slot collapses instead of reserving an empty
  /// band, so the page starts at the button row.
  hidden,
}

/// Resolves the banner slot state from the cubit's flags. Pulled out of the two
/// screens so the rule is one place and directly testable.
///
/// [isLoading] is the cubits' first-load flag (false once the first refresh
/// settled, success or failure); a provider switch clears the lists without
/// flipping it back, so a switch shows the collapsed slot rather than a shimmer.
BannerHeaderMode bannerHeaderMode({
  required bool isLoading,
  required bool hasBanners,
}) {
  if (hasBanners) return BannerHeaderMode.carousel;
  return isLoading ? BannerHeaderMode.skeleton : BannerHeaderMode.hidden;
}

/// The browse screens' hero carousel: page art with the title, the 0-10 score
/// and the description underneath.
///
/// The art per page is [Anime.bannerImage] when the provider has one, else
/// [Anime.coverImage] — see [_UnyoBannerCarouselState._artAt]. The cubits keep
/// only cards with at least one of them, so every page has art.
class UnyoBannerCarousel extends StatefulWidget {
  final List<Anime>? animeList;
  final List<Manga>? mangaList;
  final void Function(Anime, MediaList)? onTapAnime;
  final void Function(Manga, MediaList)? onTapManga;

  const UnyoBannerCarousel({
    super.key,
    this.animeList,
    this.mangaList,
    this.onTapAnime,
    this.onTapManga,
  });

  @override
  State<UnyoBannerCarousel> createState() => _UnyoBannerCarouselState();
}

class _UnyoBannerCarouselState extends State<UnyoBannerCarousel> {
  static const Duration _autoScrollInterval = Duration(seconds: 10);
  static const Duration _autoScrollDuration = Duration(milliseconds: 800);
  static const double _bannerHeight = 350;
  static const double _carouselHeight = 520;

  /// Only the text block and the page indicators listen to this. The
  /// [PageView] must never be rebuilt because the active page changed.
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  final PageController _controller = PageController(
    initialPage: 0,
    viewportFraction: 1.00,
  );

  Timer? _autoScrollTimer;
  bool _isForward = true;

  /// True while the previous auto-scroll animation is still running, so a
  /// timer tick - or the end-of-list bounce - can never start a second
  /// [PageController.animateToPage] on top of it. Starting a new driven
  /// animation aborts the running one from its current (mid-flight) offset,
  /// which is what made the carousel visibly twitch.
  bool _isAnimating = false;

  /// True between pointer down and pointer up/cancel, i.e. while the user is
  /// dragging (or holding) the carousel. Auto-scrolling then would fight the
  /// drag.
  bool _isUserInteracting = false;

  int get _itemCount =>
      widget.animeList?.length ?? widget.mangaList?.length ?? 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(covariant UnyoBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final itemCount = _itemCount;
    if (itemCount == 0) {
      _stopAutoScroll();
      return;
    }
    if (_currentPage.value > itemCount - 1) {
      _currentPage.value = itemCount - 1;
      _syncPageWithoutAnimation(itemCount - 1);
    }
    _startAutoScroll();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _currentPage.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// (Re)starts the auto-scroll watchdog so that the next advance is a full
  /// interval after the last user interaction / page change.
  void _startAutoScroll() {
    _stopAutoScroll();
    if (_itemCount <= 1) return;
    _autoScrollTimer = Timer.periodic(
      _autoScrollInterval,
      (_) => _autoScroll(),
    );
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _handlePointerDown(PointerDownEvent _) {
    _isUserInteracting = true;
    _stopAutoScroll();
  }

  void _handlePointerEnd(PointerEvent _) {
    if (!_isUserInteracting) return;
    _isUserInteracting = false;
    _startAutoScroll();
  }

  void _handlePageChanged(int index) {
    if (_currentPage.value != index) {
      _currentPage.value = index;
    }
  }

  void _syncPageWithoutAnimation(int page) {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (_isAnimating || position.isScrollingNotifier.value) return;
    _controller.jumpToPage(page);
  }

  Future<void> _autoScroll() async {
    if (!mounted || _isAnimating || _isUserInteracting) return;
    if (!_controller.hasClients) return;

    final itemCount = _itemCount;
    if (itemCount <= 1) {
      _stopAutoScroll();
      return;
    }

    // Another scroll activity (user drag, fling or a previous animation) owns
    // the position right now; leave it alone and try again on the next tick.
    if (_controller.position.isScrollingNotifier.value) return;

    final current = _controller.page?.round() ?? _currentPage.value;
    if (current <= 0) _isForward = true;
    if (current >= itemCount - 1) _isForward = false;

    final target = _isForward ? current + 1 : current - 1;
    if (target < 0 || target > itemCount - 1 || target == current) return;

    _isAnimating = true;
    try {
      await _controller.animateToPage(
        target,
        duration: _autoScrollDuration,
        curve: Curves.easeInOut,
      );
    } finally {
      _isAnimating = false;
    }
  }

  String _titleAt(int index) {
    final animeList = widget.animeList;
    if (animeList != null && index < animeList.length) {
      return displayMediaTitle(animeList[index].title);
    }
    return displayMediaTitle(widget.mangaList![index].title);
  }

  int _scoreAt(int index) {
    final animeList = widget.animeList;
    if (animeList != null && index < animeList.length) {
      return animeList[index].meanScore;
    }
    return widget.mangaList![index].meanScore;
  }

  String _descriptionAt(int index) {
    final animeList = widget.animeList;
    if (animeList != null && index < animeList.length) {
      return animeList[index].description;
    }
    return widget.mangaList![index].description;
  }

  /// The hero art of a page: the real banner when the provider has one, else
  /// the card's cover, painted with the same [BoxFit.cover] center-crop the
  /// banners get. MAL/Jikan v4 ships no banner asset (`bannerImage: ''`), and a
  /// banner slot with nothing in it read as a broken app (WP #166 evidence §1
  /// 3a), so the cover is the honest hero art for that provider. Nothing is
  /// copied between the two fields: the models stay truthful, the choice is
  /// made here at render time.
  String _artAt(int index) {
    final animeList = widget.animeList;
    if (animeList != null && index < animeList.length) {
      return animeList[index].heroArt;
    }
    return widget.mangaList![index].heroArt;
  }

  void _openMedia(int index) {
    if (widget.animeList != null && widget.onTapAnime != null) {
      widget.onTapAnime!(
        widget.animeList![index],
        const MediaListModel(
          name: "BannerCarousel",
          mediaType: MediaType.anime,
        ),
      );
    } else if (widget.mangaList != null && widget.onTapManga != null) {
      widget.onTapManga!(
        widget.mangaList![index],
        const MediaListModel(
          name: "BannerCarousel",
          mediaType: MediaType.manga,
        ),
      );
    }
  }

  Widget _buildBannerPage(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50.0.r),
      child: UnyoInkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openMedia(index),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: double.infinity,
            height: _bannerHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // The image
                UnyoNetworkImage(url: _artAt(index), fit: BoxFit.cover),

                // Dark overlay
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    // Optional: add gradient for more dramatic effect
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPageText(int page) {
    final index = page.clamp(0, _itemCount - 1);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextTitleSmall(
              text: _titleAt(index),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              // Hugs the 0-10 score ("9.0", "10.0") instead of clipping it: the
              // old fixed 50x25 box fit the raw "90" but not the three- and
              // four-character form every surface now renders. The minimum keeps
              // the badge exactly 50x25 for the production font.
              constraints: const BoxConstraints(minWidth: 50, minHeight: 25),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.star,
                    color: ColorScheme.of(context).tertiary,
                    size: 17,
                  ),
                  TextLabelLarge(
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    text: TextUtils.scoreOutOfTen(_scoreAt(index)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextBodyMedium(
                text: TextUtils.parseHtmlToPlainText(_descriptionAt(index)),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageIndicators(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: _currentPage.value == index ? 8 : 6,
          // Make current one larger
          width: _currentPage.value == index ? 8 : 6,
          // Make them circular
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage.value == index
                ? ColorScheme.of(context).tertiary
                : Colors.grey.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _itemCount;
    if (itemCount == 0) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: _carouselHeight,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              SizedBox(
                height: _bannerHeight,
                child: Listener(
                  onPointerDown: _handlePointerDown,
                  onPointerUp: _handlePointerEnd,
                  onPointerCancel: _handlePointerEnd,
                  child: PageView.builder(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: _handlePageChanged,
                    itemCount: itemCount,
                    itemBuilder: (context, index) => _buildBannerPage(index),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Only this text block rebuilds when the page changes: the
              // PageView above is untouched, so no animation is interrupted.
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentPage,
                  builder: (context, page, _) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.0.r),
                    child: _buildCurrentPageText(page),
                  ),
                ),
              ),
            ],
          ),
        ),
        // The indicators listen to the page too, but stay outside the PageView.
        ValueListenableBuilder<int>(
          valueListenable: _currentPage,
          builder: (context, _, _) => _buildPageIndicators(itemCount),
        ),
      ],
    );
  }
}
