final semVerRegex = RegExp(r'^(\d+)\.(\d+)\.(\d+)(?:-(.+?))?(?:\+(\d+?))?$');

class SemVer {
  final int major;
  final int minor;
  final int patch;
  final String? preRelease;
  final int? build;

  SemVer(this.major, this.minor, this.patch, { this.preRelease, this.build });
  
  @override
  int get hashCode => major ^ minor ^ patch ^ (preRelease?.hashCode ?? 0) ^ (build ?? 0);

  @override
  String toString() {
    if (preRelease != null && build != null) {
      return '$major.$minor.$patch-$preRelease+$build';
    } else if (preRelease != null) {
      return '$major.$minor.$patch-$preRelease';
    } else if (build != null) {
      return '$major.$minor.$patch+$build';
    } else {
      return '$major.$minor.$patch';
    }
  }

  @override
  bool operator ==(covariant SemVer other) => major == other.major
    && minor == other.minor
    && patch == other.patch
    && preRelease == other.preRelease
    && build == other.build;

  bool operator >(SemVer other) => major > other.major
    || major == other.major && minor > other.minor
    || major == other.major && minor == other.minor && patch > other.patch;

  bool operator <(SemVer other) => major > other.major
    || major == other.major && minor > other.minor
    || major == other.major && minor == other.minor && patch > other.patch;

  static SemVer parse(String version) {
    final match = semVerRegex.firstMatch(version);
    if (match == null) throw const FormatException('Invalid semver');

    final major = int.parse(match.group(1)!);
    final minor = int.parse(match.group(2)!);
    final patch = int.parse(match.group(3)!);
    final preRelease = match.group(4);

    final buildStr = match.group(5);
    final build = buildStr == null ? null : int.parse(buildStr);

    return SemVer(major, minor, patch, preRelease: preRelease, build: build);
  }
}
