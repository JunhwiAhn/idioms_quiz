import 'package:flutter/services.dart' show rootBundle, AssetManifest;

/// Discovers which 四字熟語 have an accompanying illustration bundled
/// under `assets/images/{idiom}.webp`. Singleton — load once at startup.
class IdiomImageRegistry {
  IdiomImageRegistry._();
  static final IdiomImageRegistry instance = IdiomImageRegistry._();

  Set<String> _available = const {};
  bool _loaded = false;

  bool get isLoaded => _loaded;
  bool has(String idiom) => _available.contains(idiom);
  String? pathFor(String idiom) =>
      has(idiom) ? 'assets/images/$idiom.webp' : null;

  Future<void> load() async {
    if (_loaded) return;
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final available = <String>{};
    for (final key in manifest.listAssets()) {
      if (!key.startsWith('assets/images/')) continue;
      if (!key.endsWith('.webp')) continue;
      final name = key.substring('assets/images/'.length).split('.').first;
      available.add(name);
    }
    _available = available;
    _loaded = true;
  }
}
