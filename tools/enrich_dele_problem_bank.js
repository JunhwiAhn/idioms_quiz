const fs = require('fs');
const https = require('https');

const inputPath = 'assets/data/dele_a1_a2_b1_problem_bank.json';
const outputPath = 'assets/data/dele_a1_a2_b1_problem_bank.enriched.json';

const fixedExamples = {
  'buenos dias': 'Buenos dias, profesor.',
  'buenos días': 'Buenos días, profesor.',
  'buenas tardes': 'Buenas tardes, senora Garcia.',
  'buenas noches': 'Buenas noches, hasta manana.',
  'buenas noches': 'Buenas noches, hasta mañana.',
  'hasta luego': 'Hasta luego, nos vemos manana.',
  'hasta luego': 'Hasta luego, nos vemos mañana.',
  'hasta manana': 'Hasta manana, Ana.',
  'hasta mañana': 'Hasta mañana, Ana.',
  'por favor': 'Un cafe, por favor.',
  hola: 'Hola, me llamo Ana.',
  gracias: 'Gracias por tu ayuda.',
  perdon: 'Perdon, no entiendo.',
  perdón: 'Perdón, no entiendo.',
  casa: 'Mi casa esta cerca del parque.',
  familia: 'Mi familia vive en Madrid.',
  agua: 'Bebo agua despues de correr.',
  cafe: 'Tomo cafe por la manana.',
  café: 'Tomo café por la mañana.',
  tren: 'El tren sale a las ocho.',
  hotel: 'El hotel esta cerca de la playa.',
};

const accentFallback = new Map(
  Object.entries({
    dias: 'días',
    manana: 'mañana',
    telefono: 'teléfono',
    electronico: 'electrónico',
    direccion: 'dirección',
    habitacion: 'habitación',
    estacion: 'estación',
    avion: 'avión',
    autobus: 'autobús',
    cafe: 'café',
    medico: 'médico',
    pelicula: 'película',
    cancion: 'canción',
    tecnologia: 'tecnología',
    informacion: 'información',
    relacion: 'relación',
    corazon: 'corazón',
    pulmon: 'pulmón',
    musculo: 'músculo',
    muneca: 'muñeca',
    pestana: 'pestaña',
    rinon: 'riñón',
  }),
);

function restoreAccents(term) {
  return term
    .split(' ')
    .map((word) => accentFallback.get(word) || word)
    .join(' ');
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
            reject(new Error(`${error.message}: ${data.slice(0, 160)}`));
          }
        });
      })
      .on('error', reject);
  });
}

async function translateBatch(terms, target) {
  const text = terms.join('\n');
  const url =
    'https://translate.googleapis.com/translate_a/single?client=gtx&sl=es' +
    `&tl=${target}&dt=t&q=${encodeURIComponent(text)}`;
  const json = await fetchJson(url);
  const translated = (json[0] || []).map((part) => part[0]).join('');
  const lines = translated.split(/\n+/);
  if (lines.length !== terms.length) {
    return terms.map((term, index) => lines[index] || '');
  }
  return lines;
}

async function translateAll(terms, target) {
  const out = [];
  const size = 80;
  for (let i = 0; i < terms.length; i += size) {
    const chunk = terms.slice(i, i + size);
    let translated = [];
    for (let attempt = 0; attempt < 3; attempt += 1) {
      try {
        translated = await translateBatch(chunk, target);
        break;
      } catch (error) {
        if (attempt === 2) throw error;
        await new Promise((resolve) => setTimeout(resolve, 700));
      }
    }
    out.push(...translated);
    await new Promise((resolve) => setTimeout(resolve, 120));
  }
  return out;
}

function chooseDistractors(entry, allEntries) {
  const sameTheme = allEntries.filter(
    (candidate) =>
      candidate.level === entry.level &&
      candidate.theme === entry.theme &&
      candidate.term !== entry.term,
  );
  const sameLevel = allEntries.filter(
    (candidate) => candidate.level === entry.level && candidate.term !== entry.term,
  );
  const pool = sameTheme.length >= 3 ? sameTheme : sameLevel;
  const start = Number(entry.id.split('_')[1]) || 1;
  const choices = [];
  for (let i = 0; choices.length < 3 && i < pool.length * 2; i += 1) {
    const candidate = pool[(start + i * 7) % pool.length]?.term;
    if (candidate && !choices.includes(candidate)) choices.push(candidate);
  }
  return choices;
}

function makeExample(entry) {
  const term = restoreAccents(entry.term);
  const exact = fixedExamples[entry.term] || fixedExamples[term];
  if (exact) return exact;
  return `Estudio la palabra "${term}" en clase.`;
}

function blankExample(example, term) {
  const escaped = term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const regex = new RegExp(escaped, 'i');
  if (regex.test(example)) return example.replace(regex, '____');
  return example.replace(/"[^"]+"/, '"____"');
}

function qaEntry(entry) {
  const issues = [];
  if (!entry.meanings.ko) issues.push('missing_ko');
  if (!entry.meanings.en) issues.push('missing_en');
  if (!entry.meanings.ja) issues.push('missing_ja');
  if (!entry.example || !entry.blankedExample) issues.push('missing_example');
  if (!entry.exampleMeanings.ko) issues.push('missing_example_ko');
  if (!entry.exampleMeanings.en) issues.push('missing_example_en');
  if (!entry.exampleMeanings.ja) issues.push('missing_example_ja');
  if (entry.wrongChoices.length !== 3) issues.push('wrong_choice_count');
  if (entry.wrongChoices.includes(entry.answer)) issues.push('answer_in_wrong_choices');
  if (!entry.blankedExample.includes('____')) issues.push('blank_missing');
  return issues;
}

async function main() {
  const data = JSON.parse(fs.readFileSync(inputPath, 'utf8'));
  const entries = data.entries.map((entry) => ({
    ...entry,
    term: restoreAccents(entry.term),
    answer: restoreAccents(entry.answer),
    normalizedTerm: restoreAccents(entry.normalizedTerm),
  }));

  const terms = entries.map((entry) => entry.term);
  const [ko, en, ja] = await Promise.all([
    translateAll(terms, 'ko'),
    translateAll(terms, 'en'),
    translateAll(terms, 'ja'),
  ]);

  const prepared = entries.map((entry, index) => {
    const example = makeExample(entry);
    const wrongChoices = chooseDistractors(entry, entries);
    return {
      ...entry,
      meanings: {
        ko: ko[index] || '',
        en: en[index] || '',
        ja: ja[index] || '',
      },
      example,
      exampleMeanings: {
        ko: '',
        en: '',
        ja: '',
      },
      blankedExample: blankExample(example, entry.term),
      wrongChoices,
      sourceBasis: `${entry.sourceBasis}; machine translated with QA flags`,
      reviewStatus: 'machine_enriched_needs_human_review',
    };
  });

  const examples = prepared.map((entry) => entry.example);
  const [exampleKo, exampleEn, exampleJa] = await Promise.all([
    translateAll(examples, 'ko'),
    translateAll(examples, 'en'),
    translateAll(examples, 'ja'),
  ]);

  const enriched = prepared.map((entry, index) => {
    const next = {
      ...entry,
      exampleMeanings: {
        ko: exampleKo[index] || '',
        en: exampleEn[index] || '',
        ja: exampleJa[index] || '',
      },
    };
    const issues = qaEntry(next);
    return {
      ...next,
      qaStatus: issues.length === 0 ? 'pass_machine_checks' : 'needs_fix',
      qaIssues: issues,
    };
  });

  const counts = {};
  const qa = {};
  for (const entry of enriched) {
    counts[entry.level] = (counts[entry.level] || 0) + 1;
    qa[entry.qaStatus] = (qa[entry.qaStatus] || 0) + 1;
  }

  const payload = {
    ...data,
    enrichedAt: new Date().toISOString(),
    counts: { ...counts, total: enriched.length },
    qaSummary: qa,
    translationNote:
      'Translations are machine-generated first pass and must be reviewed before production publication.',
    entries: enriched,
  };

  fs.writeFileSync(outputPath, `${JSON.stringify(payload, null, 2)}\n`, 'utf8');
  console.log({ counts: payload.counts, qaSummary: payload.qaSummary });
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
