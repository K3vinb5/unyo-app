import 'dart:math' as math;

/// Minimal semver-ish comparison used by the update check.
///
/// Rules:
/// * a leading `v`/`V` is ignored (`v1.2.3` == `1.2.3`)
/// * `+build` metadata is ignored (`1.0.0+42` == `1.0.0`)
/// * core segments are compared numerically, so `1.10.0 > 1.9.0`
/// * missing core segments count as zero (`1.2` == `1.2.0`)
/// * a pre-release suffix sorts below its release (`1.0.0-beta < 1.0.0`),
///   and identifiers are compared per semver (`1.0.0-beta.2 < 1.0.0-beta.10`)
///
/// Returns a negative number when [a] is older than [b], zero when they are
/// equal and a positive number when [a] is newer than [b].
int compareVersions(String a, String b) {
  final left = _ParsedVersion.parse(a);
  final right = _ParsedVersion.parse(b);

  final coreLength = math.max(left.core.length, right.core.length);
  for (var i = 0; i < coreLength; i++) {
    final leftSegment = i < left.core.length ? left.core[i] : 0;
    final rightSegment = i < right.core.length ? right.core[i] : 0;
    if (leftSegment != rightSegment) {
      return leftSegment.compareTo(rightSegment);
    }
  }

  final leftPreRelease = left.preRelease;
  final rightPreRelease = right.preRelease;
  if (leftPreRelease == null && rightPreRelease == null) return 0;
  // A release outranks any of its pre-releases.
  if (leftPreRelease == null) return 1;
  if (rightPreRelease == null) return -1;
  return _comparePreRelease(leftPreRelease, rightPreRelease);
}

/// True when [candidate] is a strictly newer version than [current].
bool isVersionNewer(String candidate, String current) => compareVersions(candidate, current) > 0;

int _comparePreRelease(List<String> left, List<String> right) {
  final length = math.max(left.length, right.length);
  for (var i = 0; i < length; i++) {
    // A shorter pre-release sorts first ("1.0.0-alpha" < "1.0.0-alpha.1").
    if (i >= left.length) return -1;
    if (i >= right.length) return 1;
    final leftIdentifier = left[i];
    final rightIdentifier = right[i];
    final leftNumber = int.tryParse(leftIdentifier);
    final rightNumber = int.tryParse(rightIdentifier);
    if (leftNumber != null && rightNumber != null) {
      final comparison = leftNumber.compareTo(rightNumber);
      if (comparison != 0) return comparison;
      continue;
    }
    // Numeric identifiers always sort below alphanumeric ones.
    if (leftNumber != null) return -1;
    if (rightNumber != null) return 1;
    final comparison = leftIdentifier.compareTo(rightIdentifier);
    if (comparison != 0) return comparison;
  }
  return 0;
}

class _ParsedVersion {
  final List<int> core;
  final List<String>? preRelease;

  const _ParsedVersion(this.core, this.preRelease);

  factory _ParsedVersion.parse(String raw) {
    var value = raw.trim();
    if (value.startsWith('v') || value.startsWith('V')) {
      value = value.substring(1);
    }
    final buildSeparator = value.indexOf('+');
    if (buildSeparator >= 0) {
      value = value.substring(0, buildSeparator);
    }
    final preReleaseSeparator = value.indexOf('-');
    final corePart = preReleaseSeparator >= 0 ? value.substring(0, preReleaseSeparator) : value;
    final preReleasePart = preReleaseSeparator >= 0 ? value.substring(preReleaseSeparator + 1) : '';
    final core = corePart
        .split('.')
        .map((segment) => int.tryParse(segment.trim()) ?? 0)
        .toList(growable: false);
    final preRelease =
        preReleasePart.trim().isEmpty
            ? null
            : preReleasePart.split('.').map((identifier) => identifier.trim()).toList(growable: false);
    return _ParsedVersion(core, preRelease);
  }
}
