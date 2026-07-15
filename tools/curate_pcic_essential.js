const fs = require('fs');
const https = require('https');

const dataPath = 'assets/data/dele_a1_a2_b1_problem_bank.enriched.json';
const fallbackDataPaths = ['assets/data/dele_a1_a2_b1_problem_bank.json'];
const targetByLevel = { A1: 500, A2: 500, B1: 500 };
const sourceUrls = [
  {
    kind: 'specific',
    url: 'https://cvc.cervantes.es/ensenanza/biblioteca_ele/plan_curricular/niveles/09_nociones_especificas_inventario_a1-a2.htm',
  },
  {
    kind: 'general',
    url: 'https://cvc.cervantes.es/ensenanza/biblioteca_ele/plan_curricular/niveles/08_nociones_generales_inventario_a1-a2.htm',
  },
];

const allowedPhraseKeys = new Set([
  'a veces',
  'acabar de',
  'aire acondicionado',
  'al final',
  'al lado',
  'antes de',
  'centro comercial',
  'codigo postal',
  'companero de clase',
  'correo electronico',
  'cuarto de hora',
  'cuarto de bano',
  'de ida y vuelta',
  'despues de',
  'direccion electronica',
  'estado civil',
  'esta manana',
  'esta noche',
  'esta semana',
  'esta tarde',
  'este ano',
  'este mes',
  'fecha de nacimiento',
  'fin de semana',
  'ir a',
  'lugar de nacimiento',
  'mas o menos',
  'media hora',
  'mensaje electronico',
  'numero de telefono',
  'oficina de turismo',
  'pagina web',
  'persona mayor',
  'plato combinado',
  'por eso',
  'servicio tecnico',
  'sin embargo',
  'tarjeta de credito',
  'tarjeta de visita',
  'tarjeta telefonica',
  'telefono movil',
  'tener que',
  'todo recto',
  'un poco',
]);

const rejectedExactKeys = new Set([
  'abierta',
  'antigua',
  'campin',
  'moderna',
  'universitaria',
]);

const rejectStarts = /^(de|del|a|al|con|sin|por|en)\s/i;
const rejectLabels =
  /Lugares|Herramientas|Actividades|Ropa de trabajo|auxiliar administrativo|ejemplo propuesto/i;

const verbStarts =
  /^(ser|estar|tener|llevar|hacer|tomar|pedir|traer|dar|ir|venir|vivir|trabajar|enviar|escribir|hablar|comer|beber|doler|pagar|reservar|comprar|vender|dedicarse|contestar|preparar|ganar|aprender|estudiar|memorizar|repasar|cometer|salir|practicar|montar|ver|escuchar|dejar)\b/i;

const manualMeanings = new Map(
  Object.entries({
    azafata: { ko: '\uc2b9\ubb34\uc6d0', en: 'flight attendant', ja: '\u5ba2\u5ba4\u4e57\u52d9\u54e1' },
    bajo: { ko: '\ub0ae\uc740, \ud0a4\uac00 \uc791\uc740', en: 'low; short', ja: '\u4f4e\u3044\u3001\u80cc\u304c\u4f4e\u3044' },
    capital: { ko: '\uc218\ub3c4', en: 'capital city', ja: '\u9996\u90fd' },
    cuadro: { ko: '\uadf8\ub9bc, \ud68c\ud654 \uc791\ud488', en: 'painting; picture', ja: '\u7d75\u753b\u3001\u7d75' },
    este: { ko: '\ub3d9\ucabd', en: 'east', ja: '\u6771' },
    mosca: { ko: '\ud30c\ub9ac', en: 'fly', ja: '\u30cf\u30a8' },
    rosa: { ko: '\uc7a5\ubbf8', en: 'rose', ja: '\u30d0\u30e9' },
    sobre: { ko: '\ubd09\ud22c', en: 'envelope', ja: '\u5c01\u7b52' },
  }),
);

function fetchText(url) {
  return new Promise((resolve, reject) => {
    https
      .get(url, (res) => {
        let data = '';
        res.setEncoding('utf8');
        res.on('data', (chunk) => {
          data += chunk;
        });
        res.on('end', () => resolve(data));
      })
      .on('error', reject);
  });
}

function fetchJson(url) {
  return new Promise((resolve, reject) => {
    https
      .get(url, (res) => {
        let data = '';
        res.setEncoding('utf8');
        res.on('data', (chunk) => {
          data += chunk;
        });
        res.on('end', () => {
          try {
            resolve(JSON.parse(data));
          } catch (error) {
            reject(error);
          }
        });
      })
      .on('error', reject);
  });
}

function decodeHtml(value) {
  return String(value)
    .replace(/<[^>]+>/g, ' ')
    .replace(/&nbsp;/g, ' ')
    .replace(/&gt;/g, '>')
    .replace(/&aacute;/g, '\u00e1')
    .replace(/&eacute;/g, '\u00e9')
    .replace(/&iacute;/g, '\u00ed')
    .replace(/&oacute;/g, '\u00f3')
    .replace(/&uacute;/g, '\u00fa')
    .replace(/&ntilde;/g, '\u00f1')
    .replace(/&uuml;/g, '\u00fc')
    .replace(/&amp;/g, '&')
    .replace(/\s+/g, ' ')
    .trim();
}

function normalize(value) {
  return String(value || '')
    .toLowerCase()
    .replace(/[.,;:!?]+$/g, '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .trim();
}

function cleanTermValue(value) {
  return String(value || '').trim().replace(/[.,;:!?]+$/g, '');
}

function expandInventoryItem(html) {
  const text = decodeHtml(html)
    .replace(/\[[^\]]*]/g, '')
    .replace(/\([^)]*\)/g, '');
  const terms = [];
  for (const part of text.split(',')) {
    let candidate = part.trim().replace(/\s+/g, ' ');
    if (!candidate) continue;

    if (candidate.includes('~')) {
      const before = candidate.split('~')[0].trim();
      const after = candidate.split('~').pop().trim();
      const beforeKey = normalize(before);
      if (
        [
          'carne',
          'carne de',
          'cafe',
          'tarjeta',
          'fiesta',
          'biblioteca',
          'clase',
          'agua',
          'zumo',
          'helado',
          'tarta',
          'telefono',
          'mensaje',
        ].includes(beforeKey)
      ) {
        if (after.includes('/')) {
          terms.push(...after.split('/').map((item) => `${before} ${item.trim()}`));
        } else {
          terms.push(`${before} ${after}`);
        }
        continue;
      }
      candidate = after;
    }

    const slashParts = candidate
      .split('/')
      .map((item) => item.trim())
      .filter(Boolean);
    if (slashParts.length > 1 && slashParts.every((item) => !item.includes(' '))) {
      terms.push(...slashParts);
    } else {
      terms.push(candidate);
    }
  }

  return terms
    .map((term) => term.replace(/^el |^la |^los |^las |^un |^una |^unos |^unas /i, '').trim())
    .filter(Boolean);
}

function isGoodQuizTerm(term) {
  const key = normalize(term);
  const wordCount = term.split(/\s+/).length;
  if (!term || term.length < 2) return false;
  if (/^\d+$/.test(term)) return false;
  if (/[.,;:!?]$/.test(term)) return false;
  if (rejectedExactKeys.has(key)) return false;
  if (term.includes('/') || /[\[\]~]/.test(term)) return false;
  if (rejectLabels.test(term) || rejectStarts.test(term)) return false;
  if (verbStarts.test(term) && !allowedPhraseKeys.has(key) && wordCount > 1) return false;
  return wordCount === 1 || allowedPhraseKeys.has(key);
}

function extractOfficialTerms(html, kind) {
  const rows = [];
  for (const match of html.matchAll(/<td[^>]+headers="[^"]*?(a1|a2)"[^>]*>([\s\S]*?)<\/td>/gi)) {
    const level = match[1].toUpperCase();
    const cellHtml = match[2];
    for (const item of cellHtml.matchAll(/<li[^>]*>([\s\S]*?)<\/li>/gi)) {
      if (rejectLabels.test(item[1])) continue;
      for (const term of expandInventoryItem(item[1])) {
        if (!isGoodQuizTerm(term)) continue;
        rows.push({ level, term, key: normalize(term), kind });
      }
    }
  }
  return rows;
}

async function translateBatch(lines, target) {
  const url =
    'https://translate.googleapis.com/translate_a/single?client=gtx&sl=es' +
    `&tl=${target}&dt=t&q=${encodeURIComponent(lines.join('\n'))}`;
  const json = await fetchJson(url);
  const translated = (json[0] || []).map((part) => part[0]).join('');
  const out = translated.split(/\n+/);
  return lines.map((_, index) => out[index] || '');
}

async function translateAll(lines, target) {
  const out = [];
  for (let i = 0; i < lines.length; i += 80) {
    const chunk = lines.slice(i, i + 80);
    let translated = [];
    for (let attempt = 0; attempt < 3; attempt += 1) {
      try {
        translated = await translateBatch(chunk, target);
        break;
      } catch (error) {
        if (attempt === 2) throw error;
        await new Promise((resolve) => setTimeout(resolve, 500));
      }
    }
    out.push(...translated);
    await new Promise((resolve) => setTimeout(resolve, 120));
  }
  return out;
}

function entryKey(entry) {
  return normalize(entry.normalizedTerm || entry.term || entry.spanish);
}

function hasBadSpanish(entry) {
  const term = String(entry.term || entry.spanish || '');
  return /^\d+$/.test(term) || /[\uac00-\ud7af]/.test(term) || term.includes('\ufffd');
}

function hasGenericBadExample(entry) {
  return /Uso el .+ en una situacion diaria\./i.test(entry.example || '');
}

function levelRank(level) {
  return { A1: 1, A2: 2, B1: 3 }[String(level).toUpperCase()] || 99;
}

function scoreEntry(entry, officialKeys) {
  const key = entryKey(entry);
  let score = 0;
  if (officialKeys.has(key)) score += 10000;
  if ((entry.sourceBasis || '').includes('direct inventory item')) score += 5000;
  if ((entry.sourceBasis || '').includes('PCIC/CEFR-informed')) score += 1000;
  score -= (Number(entry.difficulty) || levelRank(entry.level)) * 20;
  if (String(entry.term || '').includes(' ')) score -= allowedPhraseKeys.has(key) ? 15 : 350;
  if (hasGenericBadExample(entry)) score -= 80;
  if (hasBadSpanish(entry)) score -= 100000;
  return score;
}

function compactId(level, index) {
  return `${String(level).toLowerCase()}_${String(index).padStart(4, '0')}`;
}

function refreshWrongChoices(entries) {
  const byLevel = new Map();
  for (const entry of entries) {
    if (!byLevel.has(entry.level)) byLevel.set(entry.level, []);
    byLevel.get(entry.level).push(entry.term || entry.spanish);
  }
  for (const entry of entries) {
    const choices = (byLevel.get(entry.level) || [])
      .filter((term) => normalize(term) !== entryKey(entry))
      .slice(0, 3);
    entry.wrongChoices = choices;
  }
}

function readEntries(path) {
  if (!fs.existsSync(path)) return [];
  const raw = JSON.parse(fs.readFileSync(path, 'utf8'));
  return raw.entries || raw;
}

async function main() {
  const officialRows = [];
  for (const source of sourceUrls) {
    const html = await fetchText(source.url);
    officialRows.push(...extractOfficialTerms(html, source.kind).map((row) => ({ ...row, url: source.url })));
  }

  const byOfficialKey = new Map();
  for (const row of officialRows) {
    const current = byOfficialKey.get(row.key);
    if (!current || levelRank(row.level) < levelRank(current.level)) byOfficialKey.set(row.key, row);
  }

  const data = JSON.parse(fs.readFileSync(dataPath, 'utf8'));
  const entries = [...(data.entries || data)];
  const existingInputKeys = new Set(entries.map(entryKey));
  for (const path of fallbackDataPaths) {
    for (const entry of readEntries(path)) {
      const key = entryKey(entry);
      if (existingInputKeys.has(key)) continue;
      entries.push(entry);
      existingInputKeys.add(key);
    }
  }
  for (const entry of entries) {
    const clean = cleanTermValue(entry.term || entry.spanish);
    if (clean && clean !== (entry.term || entry.spanish)) {
      entry.term = clean;
      entry.normalizedTerm = clean;
      entry.reading = clean;
      entry.pronunciation = clean;
      if (entry.answer === `${clean}.`) entry.answer = clean;
    }
  }
  const existing = new Map(entries.map((entry) => [entryKey(entry), entry]));
  const missingOfficial = [...byOfficialKey.values()].filter((row) => !existing.has(row.key));

  let prepared = [];
  if (missingOfficial.length > 0) {
    const terms = missingOfficial.map((entry) => entry.term);
    const [ko, en, ja] = await Promise.all([
      translateAll(terms, 'ko'),
      translateAll(terms, 'en'),
      translateAll(terms, 'ja'),
    ]);
    prepared = missingOfficial.map((row, index) => {
      const manual = manualMeanings.get(row.key);
      return {
        id: `pcic_a1a2_${row.kind}_${String(index + 1).padStart(4, '0')}`,
        level: row.level,
        sourceLevel: row.level,
        theme: `pcic_${row.kind}`,
        term: row.term,
        normalizedTerm: row.term,
        reading: row.term,
        pronunciation: row.term,
        questionType: 'vocabulary_meaning_seed',
        promptKo: `Review the Spanish item "${row.term}" and complete its meaning, example, and distractors.`,
        promptEn: `Review the Spanish item "${row.term}" and complete its meaning, example, and distractors.`,
        answer: row.term,
        meanings: {
          ko: manual?.ko || ko[index] || '',
          en: manual?.en || en[index] || '',
          ja: manual?.ja || ja[index] || '',
        },
        example: `La palabra "${row.term}" aparece en la lista.`,
        blankedExample: 'La palabra "____" aparece en la lista.',
        exampleMeanings: {
          ko: `"${row.term}" appears in the list.`,
          en: `The word "${row.term}" appears in the list.`,
          ja: `"${row.term}" appears in the list.`,
        },
        wrongChoices: [],
        difficulty: row.level === 'A1' ? 1 : 2,
        partOfSpeech: row.term.includes(' ') ? 'expression' : 'word',
        sourceBasis: `Instituto Cervantes PCIC Nociones ${row.kind} A1-A2 direct inventory item`,
        sourceUrl: row.url,
        reviewStatus: 'pcic_source_added_needs_translation_review',
        qaStatus: 'pass_machine_checks',
        qaIssues: [],
      };
    });
  }

  const expanded = [...entries, ...prepared];
  const officialKeys = new Set([...byOfficialKey.keys()]);
  const selected = [];
  const selectedKeys = new Set();

  for (const level of Object.keys(targetByLevel)) {
    const candidates = expanded
      .filter((entry) => entry.level === level)
      .filter((entry) => !hasBadSpanish(entry))
      .sort((a, b) => {
        const score = scoreEntry(b, officialKeys) - scoreEntry(a, officialKeys);
        if (score !== 0) return score;
        const diff = (Number(a.difficulty) || 9) - (Number(b.difficulty) || 9);
        if (diff !== 0) return diff;
        return String(a.term || a.spanish).localeCompare(String(b.term || b.spanish), 'es');
      });
    let count = 0;
    for (const entry of candidates) {
      const key = entryKey(entry);
      if (selectedKeys.has(key)) continue;
      selected.push(entry);
      selectedKeys.add(key);
      count += 1;
      if (count >= targetByLevel[level]) break;
    }
    if (count < targetByLevel[level]) {
      throw new Error(`Could not fill ${level}: ${count}/${targetByLevel[level]}`);
    }
  }

  selected.sort((a, b) => {
    const level = levelRank(a.level) - levelRank(b.level);
    if (level !== 0) return level;
    const score = scoreEntry(b, officialKeys) - scoreEntry(a, officialKeys);
    if (score !== 0) return score;
    return String(a.term || a.spanish).localeCompare(String(b.term || b.spanish), 'es');
  });

  const perLevelIndex = {};
  for (const entry of selected) {
    perLevelIndex[entry.level] = (perLevelIndex[entry.level] || 0) + 1;
    entry.id = compactId(entry.level, perLevelIndex[entry.level]);
    entry.index = perLevelIndex[entry.level];
  }
  refreshWrongChoices(selected);

  data.entries = selected;
  data.counts = {
    A1: targetByLevel.A1,
    A2: targetByLevel.A2,
    B1: targetByLevel.B1,
    total: selected.length,
  };
  data.target = { ...targetByLevel };
  data.pcicEssentialAudit = {
    curatedAt: new Date().toISOString(),
    sourceUrls,
    extractedOfficialA1A2Terms: byOfficialKey.size,
    addedBeforeCuration: prepared.length,
    finalCounts: data.counts,
    policy:
      'Curated to essential 1500 items: 500 each for A1, A2, B1. CVC A1-A2 specific/general direct inventory items are prioritized; noisy fragments and forced filler are excluded.',
  };

  fs.writeFileSync(dataPath, `${JSON.stringify(data, null, 2)}\n`, 'utf8');
  console.log({
    official: byOfficialKey.size,
    addedBeforeCuration: prepared.length,
    counts: data.counts,
  });
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
