import '../models/idiom.dart';

const _morning = <String>[
  'おはようございます。',
  'おはよう。',
  'おはようございます!',
];

const _noon = <String>[
  'こんにちは。',
  'こんにちは!',
  'どうも、こんにちは。',
];

const _afternoon = <String>[
  'こんにちは。',
  'どうも。',
  'こんにちは!',
];

const _evening = <String>[
  'こんばんは。',
  'こんばんは!',
  'どうも、こんばんは。',
];

const _late = <String>[
  'こんばんは。',
  'こんばんは!',
  'どうも。',
];

int _daySeed(DateTime now) =>
    now.year * 10000 + now.month * 100 + now.day;

String greetingFor(DateTime now) {
  final h = now.hour;
  final pool = h < 5
      ? _late
      : h < 10
          ? _morning
          : h < 14
              ? _noon
              : h < 18
                  ? _afternoon
                  : h < 22
                      ? _evening
                      : _late;
  return pool[_daySeed(now) % pool.length];
}

Idiom idiomOfTheDay(List<Idiom> pool, DateTime now) {
  if (pool.isEmpty) {
    throw StateError('idiomOfTheDay called with empty pool');
  }
  return pool[_daySeed(now) % pool.length];
}
