// External dependencies
import 'package:flutter_test/flutter_test.dart';

// Internal dependencies
import 'package:unyo/core/enums/service.dart';
import 'package:unyo/core/services/media/media_service.dart';
import 'package:unyo/presentation/widgets/text/text_utils.dart';

/// WP #166: the settings "Media metadata service" dropdown is fed straight from
/// [ProviderCapabilities.metadataProviders] and shows each entry as
/// `TextUtils.capitalize(service.name)`. The picked label then travels back
/// through `SettingsCubit.updateMediaMetadataService` →
/// [MediaServiceFactory.getEnumMediaService], so an offered entry must resolve
/// to the service it stands for — a mismatch silently stores the default.
///
/// There is no widget test for the settings screen (it needs the whole cubit
/// graph), so the picker's contract is tested where it lives: the capability
/// list it renders and the round trip its selection takes.
void main() {
  group('media metadata service picker', () {
    test('offers MyAnimeList next to AniList and Shikimori', () {
      expect(ProviderCapabilities.isMetadata(Service.mal), isTrue);
      expect(
        ProviderCapabilities.metadataProviders,
        <Service>[Service.anilist, Service.shikimori, Service.mal],
      );
      expect(
        ProviderCapabilities.metadataProviders.map((Service service) => TextUtils.capitalize(service.name)),
        <String>['Anilist', 'Shikimori', 'Mal'],
      );
    });

    test('every offered label resolves back to the service it stands for', () {
      for (final Service service in ProviderCapabilities.metadataProviders) {
        final String label = TextUtils.capitalize(service.name);

        expect(
          MediaServiceFactory.getEnumMediaService(label),
          service,
          reason: 'picking "$label" must store $service instead of falling back to the AniList default',
        );
      }
    });

    test('MAL is reachable by its enum label and by its brand name', () {
      expect(MediaServiceFactory.getEnumMediaService('Mal'), Service.mal);
      expect(MediaServiceFactory.getEnumMediaService('MyAnimeList'), Service.mal);
    });
  });
}
