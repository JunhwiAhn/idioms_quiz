import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/idiom.dart';

class IdiomRepository {
  static const _assetPath = 'assets/data/idioms.json';

  List<Idiom>? _cache;

  Future<List<Idiom>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = json.decode(raw) as List<dynamic>;
    _cache = decoded
        .map((e) => Idiom.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    return _cache!;
  }
}
