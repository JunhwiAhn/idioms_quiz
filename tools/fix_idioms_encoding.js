const fs = require('fs');

const path = 'assets/data/idioms.json';
const entries = JSON.parse(fs.readFileSync(path, 'utf8'));

const fixes = {
  aunque: {
    pronunciation: '\u02c8au\u014bke',
    ja: '\u301c\u3060\u3051\u308c\u3069\u3082',
  },
  cuando: {
    pronunciation: '\u02c8kwando',
    ja: '\u301c\u3059\u308b\u3068\u304d',
  },
  'tener que': {
    pronunciation: 'te\u02c8ne\u027e ke',
    ja: '\u301c\u3057\u306a\u3051\u308c\u3070\u306a\u3089\u306a\u3044',
  },
  'ir a': {
    pronunciation: 'i\u027e a',
    ja: '\u301c\u3059\u308b\u4e88\u5b9a\u3060',
  },
};

for (const entry of entries) {
  const fix = fixes[entry.spanish];
  if (!fix) continue;
  entry.pronunciation = fix.pronunciation;
  entry.meanings.ja = fix.ja;
}

fs.writeFileSync(path, JSON.stringify(entries), 'utf8');
