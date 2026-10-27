// Internal dependencies
import 'package:flutter_test/flutter_test.dart';
import 'package:unyo/domain/services/media_field_policy.dart';

void main() {
  group('MediaFieldPolicy', () {
    test('identity, list state and list-card fields always belong to the user provider', () {
      for (final MediaField field in MediaFieldPolicy.userOwnedFields) {
        expect(MediaFieldPolicy.ownerOf(field, mappingResolved: true), MediaFieldOwner.userProvider,
            reason: '$field must stay on the user provider even when the record is linked');
        expect(MediaFieldPolicy.ownerOf(field, mappingResolved: false), MediaFieldOwner.userProvider,
            reason: '$field must stay on the user provider when the mapping failed');
        expect(MediaFieldPolicy.isUserOwned(field), isTrue);
      }
    });

    test('presentation details come from the metadata provider once the record is linked', () {
      for (final MediaField field in MediaFieldPolicy.metadataOwnedFields) {
        expect(MediaFieldPolicy.ownerOf(field, mappingResolved: true), MediaFieldOwner.metadataProvider,
            reason: '$field is metadata-provider data');
        expect(MediaFieldPolicy.readsFromMetadata(field, mappingResolved: true), isTrue);
        expect(MediaFieldPolicy.isUserOwned(field), isFalse);
      }
    });

    test('an unresolved mapping falls back to the user provider for metadata fields', () {
      for (final MediaField field in MediaFieldPolicy.metadataOwnedFields) {
        expect(MediaFieldPolicy.ownerOf(field, mappingResolved: false), MediaFieldOwner.userProvider,
            reason: '$field must fall back instead of rendering an empty details screen');
        expect(MediaFieldPolicy.readsFromMetadata(field, mappingResolved: false), isFalse);
      }
    });

    test('the two tables are disjoint and cover every field', () {
      final Set<MediaField> user = MediaFieldPolicy.userOwnedFields;
      final Set<MediaField> metadata = MediaFieldPolicy.metadataOwnedFields;

      expect(user.intersection(metadata), isEmpty);
      expect({...user, ...metadata}, equals(MediaField.values.toSet()));
    });

    test('progress, score and dates are user-owned so writes never hit the metadata provider', () {
      expect(MediaFieldPolicy.isUserOwned(MediaField.progress), isTrue);
      expect(MediaFieldPolicy.isUserOwned(MediaField.score), isTrue);
      expect(MediaFieldPolicy.isUserOwned(MediaField.listStatus), isTrue);
      expect(MediaFieldPolicy.isUserOwned(MediaField.startedAt), isTrue);
      expect(MediaFieldPolicy.isUserOwned(MediaField.completedAt), isTrue);
      expect(MediaFieldPolicy.isUserOwned(MediaField.customLists), isTrue);
    });
  });
}
