// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/services/api/graphql/queries/shikimori_search_parameters.dart';

/// `OrderEnum` / `genre` / `SeasonString` rules probed live on 2026-10-29
/// (`research/unyo-64-shikimori-parity-proof/raws/api/gql-advanced-search-probes.txt`).
void main() {
  group('ShikimoriSearchParameters.orderFor', () {
    test('the cubit string collapses onto the accepted OrderEnum literals', () {
      expect(ShikimoriSearchParameters.orderFor('Popularity_Desc'), 'popularity');
      expect(ShikimoriSearchParameters.orderFor('POPULARITY_ASC'), 'popularity');
      expect(ShikimoriSearchParameters.orderFor('Ranked_Desc'), 'ranked');
      expect(ShikimoriSearchParameters.orderFor('Name_Desc'), 'name');
      expect(ShikimoriSearchParameters.orderFor('Aired on_Asc'), 'aired_on');
      expect(ShikimoriSearchParameters.orderFor('Episodes_Desc'), 'episodes');
      expect(ShikimoriSearchParameters.orderFor('Status_Desc'), 'status');
    });

    test('only id has a descending twin', () {
      expect(ShikimoriSearchParameters.orderFor('Id_Asc'), 'id');
      expect(ShikimoriSearchParameters.orderFor('Id_Desc'), 'id_desc');
    });

    test('unknown values degrade to popularity instead of sending a rejected literal', () {
      expect(ShikimoriSearchParameters.orderFor(''), 'popularity');
      expect(ShikimoriSearchParameters.orderFor('Trending_Desc'), 'popularity');
      expect(ShikimoriSearchParameters.orderFor('released_on_desc'), 'popularity');
    });
  });

  group('ShikimoriSearchParameters.choiceFor', () {
    test('display labels normalize to the wire value', () {
      expect(ShikimoriSearchParameters.choiceFor('Tv special', <String>['tv_special']), 'tv_special');
      expect(ShikimoriSearchParameters.choiceFor('Light novel', <String>['light_novel']), 'light_novel');
      expect(ShikimoriSearchParameters.choiceFor('Ongoing', <String>['ongoing']), 'ongoing');
    });

    test('a value outside the dictionary is dropped, not guessed', () {
      expect(ShikimoriSearchParameters.choiceFor('Releasing', <String>['ongoing', 'released']), isNull);
      expect(ShikimoriSearchParameters.choiceFor(null, <String>['ongoing']), isNull);
      expect(ShikimoriSearchParameters.choiceFor('  ', <String>['ongoing']), isNull);
    });
  });

  group('ShikimoriSearchParameters.seasonFor', () {
    test('season alone and season with year use SeasonString', () {
      expect(ShikimoriSearchParameters.seasonFor('Fall', null, <String>['fall']), 'fall');
      expect(ShikimoriSearchParameters.seasonFor('Fall', 2023, <String>['fall']), 'fall_2023');
      expect(ShikimoriSearchParameters.seasonFor(null, 2023, <String>['fall']), isNull,
          reason: 'the schema has no year-only argument');
    });
  });

  group('ShikimoriSearchParameters.years', () {
    test('the year dropdown feeds seasonFor: 2023 + Fall is reachable from the UI', () {
      final List<String> years = ShikimoriSearchParameters.years(now: DateTime(2026, 10, 29));

      expect(years.first, '2026', reason: 'newest first');
      expect(years.last, '1940');
      expect(years, contains('2023'));
      expect(
        ShikimoriSearchParameters.seasonFor('Fall', int.parse(years.firstWhere((String y) => y == '2023')), <String>['fall']),
        'fall_2023',
        reason: 'round 1 finding 2: a rendered year must actually reach the query variable',
      );
    });
  });

  group('ShikimoriSearchParameters.genreIdsFor', () {
    test('names become the comma-separated genre id argument', () {
      final Map<String, String> ids = <String, String>{'shounen': '27', 'action': '1'};

      expect(ShikimoriSearchParameters.genreIdsFor(<String>['Shounen', 'Action'], ids), '27,1');
      expect(ShikimoriSearchParameters.genreIdsFor(<String>['Shounen', 'Shounen'], ids), '27');
    });

    test('unknown names are dropped and a numeric selection is accepted as an id', () {
      final Map<String, String> ids = <String, String>{'shounen': '27'};

      expect(ShikimoriSearchParameters.genreIdsFor(<String>['Not a genre'], ids), isNull);
      expect(ShikimoriSearchParameters.genreIdsFor(<String>['47'], ids), '47');
      expect(ShikimoriSearchParameters.genreIdsFor(<String>[], ids), isNull);
    });
  });

  test('label capitalizes dictionary values', () {
    expect(ShikimoriSearchParameters.label('aired_on'), 'Aired on');
    expect(ShikimoriSearchParameters.label('tv'), 'Tv');
    expect(ShikimoriSearchParameters.label(''), '');
  });
}
