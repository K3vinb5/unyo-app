/// Shared skeleton-loading module.
///
/// Every skeleton in the app lives here: the [SkeletonScope] that owns one
/// shimmer animation per screen, the [SkeletonBlock] primitive and the
/// composites that mirror the real components' geometry. Nothing outside this
/// module should implement skeleton/shimmer logic.
library;

export 'banner_carousel_skeleton.dart';
export 'detail_header_skeleton.dart';
export 'episode_row_skeleton.dart';
export 'extension_row_skeleton.dart';
export 'list_tile_skeleton.dart';
export 'media_card_skeleton.dart';
export 'skeleton_block.dart';
export 'skeleton_metrics.dart';
export 'skeleton_scope.dart';
