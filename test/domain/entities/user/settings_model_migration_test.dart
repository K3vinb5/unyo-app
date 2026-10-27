// Internal dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/domain/entities/user/settings.dart';

void main() {
  group('SettingsModel.fromJson', () {
    test('pre-split payload migrates the old service into metadataService', () {
      final SettingsModel settings = SettingsModel.fromJson(<String, dynamic>{
        'service': 'shikimori',
        'language': 'en',
      });

      expect(settings.metadataService, Service.shikimori);
      expect(settings.userService, Service.anilist,
          reason: 'existing installs used AniList for the account, that default must survive the split');
    });

    test('post-split payload keeps both services independent', () {
      final SettingsModel settings = SettingsModel.fromJson(<String, dynamic>{
        'service': 'anilist',
        'userService': 'anilist',
        'metadataService': 'shikimori',
      });

      expect(settings.userService, Service.anilist);
      expect(settings.metadataService, Service.shikimori);
    });

    test('payload without any service key falls back to the anilist defaults', () {
      final SettingsModel settings = SettingsModel.fromJson(<String, dynamic>{});

      expect(settings.userService, Service.anilist);
      expect(settings.metadataService, Service.anilist);
    });

    test('an explicit metadataService is never overwritten by the legacy key', () {
      // A migrated install that later had its metadata provider reset to AniList
      // still carries the stale legacy key; key presence wins over its value.
      final SettingsModel settings = SettingsModel.fromJson(<String, dynamic>{
        'service': 'shikimori',
        'metadataService': 'anilist',
      });

      expect(settings.metadataService, Service.anilist);
    });

    test('a migrated settings object round-trips through toJson', () {
      final SettingsModel settings = SettingsModel.empty().copyWith(metadataService: Service.shikimori);
      final SettingsModel reloaded = SettingsModel.fromJson(settings.toJson());

      expect(reloaded.metadataService, Service.shikimori);
      expect(reloaded.userService, Service.anilist);
    });
  });
}
