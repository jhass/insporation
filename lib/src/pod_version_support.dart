class PodVersionSupport {
  static const minimumSupportedDiasporaVersion = "0.9.0";
  static final _nodeInfoRelPattern = RegExp(r'^http://nodeinfo\.diaspora\.software/ns/schema/(\d+\.\d+)$');

  static bool supportsRequiredVersion(String? serverVersion) {
    final parsedServerVersion = _LooseVersion.tryParse(serverVersion),
      parsedMinimumVersion = _LooseVersion.tryParse(minimumSupportedDiasporaVersion);

    if (parsedServerVersion == null || parsedMinimumVersion == null) {
      return true;
    }

    return parsedServerVersion.compareTo(parsedMinimumVersion) >= 0;
  }

  static Uri? bestNodeInfoUri(Uri baseUri, dynamic links) {
    if (links is! List) {
      return null;
    }

    _LooseVersion? bestSchemaVersion;
    Uri? bestUri;
    for (final entry in links) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }

      final rel = entry["rel"],
        href = entry["href"];
      if (rel is! String || href is! String) {
        continue;
      }

      final match = _nodeInfoRelPattern.firstMatch(rel);
      if (match == null) {
        continue;
      }

      final schemaVersion = _LooseVersion.tryParse(match.group(1));
      if (schemaVersion == null || (bestSchemaVersion != null && schemaVersion.compareTo(bestSchemaVersion) <= 0)) {
        continue;
      }

      bestSchemaVersion = schemaVersion;
      bestUri = baseUri.resolve(href);
    }

    return bestUri;
  }
}

class _LooseVersion implements Comparable<_LooseVersion> {
  final List<int> _components;

  const _LooseVersion(this._components);

  static _LooseVersion? tryParse(String? rawVersion) {
    if (rawVersion == null) {
      return null;
    }

    final normalizedVersion = rawVersion.trim().replaceFirst(RegExp(r'^[vV]'), "");
    final components = RegExp(r'\d+').allMatches(normalizedVersion).map((m) => int.parse(m[0]!)).toList();
    return components.isEmpty ? null : _LooseVersion(components);
  }

  @override
  int compareTo(_LooseVersion other) {
    for (var i = 0; i < _components.length || i < other._components.length; i++) {
      final current = i < _components.length ? _components[i] : 0;
      final target = i < other._components.length ? other._components[i] : 0;
      if (current != target) {
        return current.compareTo(target);
      }
    }

    return 0;
  }
}
