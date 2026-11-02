// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/application/states/anime_advanced_search_state.dart';
import 'package:unyo/application/states/manga_advanced_search_state.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/entities/user/settings.dart';
import 'package:unyo/domain/entities/user/user.dart';

/// The advanced-search screens paint a grid placeholder while
/// `isSearching` is true - the flag the cubits flip around the results
/// request. Both states must default to "not searching" so the screens open
/// on their normal (empty) grid.
void main() {
  const UserModel user = UserModel(
    id: '1',
    name: 'Test User',
    settings: SettingsModel(service: Service.anilist),
    avatarImage: 'avatar.png',
    bannerImage: 'banner.png',
  );

  test('the anime search state starts idle and toggles with copyWith', () {
    final AnimeAdvancedSearchState state = const AnimeAdvancedSearchState(
      loggedUser: user,
    );

    expect(state.isSearching, isFalse);
    expect(state.copyWith(isSearching: true).isSearching, isTrue);
    expect(
      state.copyWith(isSearching: true).copyWith(isSearching: false).isSearching,
      isFalse,
    );
  });

  test('the manga search state starts idle and toggles with copyWith', () {
    final MangaAdvancedSearchState state = const MangaAdvancedSearchState(
      loggedUser: user,
    );

    expect(state.isSearching, isFalse);
    expect(state.copyWith(isSearching: true).isSearching, isTrue);
    expect(
      state.copyWith(isSearching: true).copyWith(isSearching: false).isSearching,
      isFalse,
    );
  });
}
