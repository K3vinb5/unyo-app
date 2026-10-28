import 'package:unyo/core/enums/service.dart';

/// One row a target-provider title search (or a pivot probe) produced.
class MediaLinkCandidate {
  final Service service;
  final String nativeId;
  final int? malId;
  final String title;
  final int? year;
  final String? format;

  const MediaLinkCandidate({
    required this.service,
    required this.nativeId,
    required this.title,
    this.malId,
    this.year,
    this.format,
  });

  @override
  bool operator ==(Object other) => other is MediaLinkCandidate && other.service == service && other.nativeId == nativeId;

  @override
  int get hashCode => Object.hash(service, nativeId);

  @override
  String toString() => 'MediaLinkCandidate(${service.name}:$nativeId "$title" $year ${format ?? ''})';
}
