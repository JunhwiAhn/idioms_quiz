import '../models/idiom.dart';

const _morning = <String>[
  'Buenos días.',
  'Ready for today.',
  'Start with one word.',
];

const _noon = <String>[
  'Buen día.',
  'Keep practicing.',
  'One word at a time.',
];

const _afternoon = <String>[
  'Buena tarde.',
  'Small practice, real progress.',
  'Review and move on.',
];

const _evening = <String>[
  'Buenas tardes.',
  'Finish with one more word.',
  'A short review helps.',
];

const _late = <String>[
  'Buenas noches.',
  'Quiet review time.',
  'One last word.',
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
