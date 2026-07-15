const fs = require('fs');
const https = require('https');

const path = 'assets/data/dele_a1_a2_b1_problem_bank.enriched.json';

const verbEndings = /(ar|er|ir|arse|erse|irse)$/;
const connectorTerms = new Set([
  'aunque',
  'cuando',
  'porque',
  'pero',
  'sin embargo',
  'por eso',
  'por lo tanto',
  'tambien',
  'también',
  'antes',
  'despues',
  'después',
  'mientras',
]);

const fixed = new Map(
  Object.entries({
    'buenos días': 'Buenos días, Ana.',
    'buenas tardes': 'Buenas tardes, señor García.',
    'buenas noches': 'Buenas noches, hasta mañana.',
    'hasta luego': 'Hasta luego, nos vemos mañana.',
    'hasta mañana': 'Hasta mañana, Ana.',
    'por favor': 'Un café, por favor.',
    hola: 'Hola, me llamo Ana.',
    gracias: 'Gracias por tu ayuda.',
    perdón: 'Perdón, no entiendo.',
    adiós: 'Adiós, hasta pronto.',
    casa: 'Mi casa está cerca del parque.',
    familia: 'Mi familia vive en Madrid.',
    amigo: 'Carlos es mi amigo.',
    agua: 'Bebo agua después de correr.',
    café: 'Tomo café por la mañana.',
    pan: 'Compro pan en la tienda.',
    leche: 'La leche está en la nevera.',
    comida: 'La comida está en la mesa.',
    bebida: 'Quiero una bebida fría.',
    tren: 'El tren sale a las ocho.',
    hotel: 'El hotel está cerca de la playa.',
    autobús: 'El autobús llega tarde.',
    avión: 'El avión sale mañana.',
    coche: 'El coche está delante de la casa.',
    mapa: 'Necesito un mapa de la ciudad.',
    pasaporte: 'Necesito mi pasaporte para viajar.',
    dinero: 'Necesito dinero para el autobús.',
    precio: 'El precio es bajo.',
    escuela: 'Los niños van a la escuela.',
    libro: 'Este libro es interesante.',
    pregunta: 'Tengo una pregunta.',
    respuesta: 'Tu respuesta es clara.',
    problema: 'Tenemos un problema con la reserva.',
    música: 'Escucho música por la tarde.',
    película: 'Vemos una película esta noche.',
    deporte: 'El deporte es bueno para la salud.',
    trabajo: 'Ana tiene mucho trabajo hoy.',
    oficina: 'La oficina está en el centro.',
    farmacia: 'Compro medicina en la farmacia.',
    hospital: 'El hospital está cerca de aquí.',
    lluvia: 'La lluvia moja las calles.',
    viento: 'El viento mueve las hojas.',
    sol: 'El sol sale temprano.',
    frío: 'Hace frío por la mañana.',
    calor: 'Hace calor en la cocina.',
  }),
);

const adjectiveMeanings = new Set([
  'good',
  'bad',
  'big',
  'small',
  'new',
  'old',
  'young',
  'pretty',
  'easy',
  'difficult',
  'fast',
  'slow',
  'expensive',
  'cheap',
  'clean',
  'happy',
  'sad',
  'important',
  'necessary',
  'possible',
]);

function normalize(value) {
  return (value || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .trim();
}

function guessKind(entry) {
  const term = entry.term;
  const normalized = normalize(term);
  const en = normalize(entry.meanings?.en || '');
  if (fixed.has(term)) return 'fixed';
  if (connectorTerms.has(term) || connectorTerms.has(normalized)) return 'connector';
  if (verbEndings.test(normalized)) return 'verb';
  if (adjectiveMeanings.has(en)) return 'adjective';
  if (term.split(/\s+/).length > 1) return 'phrase';
  return 'noun';
}

function articleFor(term) {
  if (/a$/.test(normalize(term)) && !/(ma|pa)$/.test(normalize(term))) {
    return 'una';
  }
  return 'un';
}

function makeExample(entry) {
  const term = entry.term;
  const kind = guessKind(entry);
  if (fixed.has(term)) return fixed.get(term);
  switch (kind) {
    case 'connector':
      if (normalize(term) === 'pero') return `Quiero ir, pero no tengo tiempo.`;
      if (normalize(term) === 'porque') return `Me quedo en casa porque estoy cansado.`;
      if (normalize(term) === 'aunque') return `Salimos aunque llueve un poco.`;
      if (normalize(term) === 'cuando') return `Te llamo cuando llego al hotel.`;
      return `Uso ${term} para unir dos ideas.`;
    case 'verb':
      return `Quiero ${term} con mis amigos.`;
    case 'adjective':
      return `El resultado es ${term}.`;
    case 'phrase':
      return `Necesito ${term} hoy.`;
    default:
      return `Hay ${articleFor(term)} ${term} en la mesa.`;
  }
}

function blankExample(example, term) {
  const escaped = term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const regex = new RegExp(escaped, 'i');
  if (regex.test(example)) return example.replace(regex, '____');
  return example.replace(/\b[a-záéíóúüñ]+(?:\s+[a-záéíóúüñ]+)?\b/i, '____');
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
        await new Promise((resolve) => setTimeout(resolve, 700));
      }
    }
    out.push(...translated);
    await new Promise((resolve) => setTimeout(resolve, 120));
  }
  return out;
}

function qa(entry) {
  const issues = [];
  const joined = [
    entry.example,
    entry.blankedExample,
    entry.exampleMeanings?.ko,
    entry.exampleMeanings?.en,
    entry.exampleMeanings?.ja,
  ].join(' ');
  if (/Estudio la palabra|La palabra|palabra correcta/i.test(joined)) {
    issues.push('meta_word_example');
  }
  if (joined.includes('"____"') || joined.includes('""')) {
    issues.push('quoted_blank_or_empty_quote');
  }
  if (!entry.blankedExample.includes('____')) issues.push('blank_missing');
  if (!entry.exampleMeanings?.ko || !entry.exampleMeanings?.en || !entry.exampleMeanings?.ja) {
    issues.push('missing_example_translation');
  }
  return issues;
}

async function main() {
  const data = JSON.parse(fs.readFileSync(path, 'utf8'));
  const entries = data.entries.map((entry) => {
    const example = makeExample(entry);
    return {
      ...entry,
      example,
      blankedExample: blankExample(example, entry.term),
    };
  });
  const examples = entries.map((entry) => entry.example);
  const [ko, en, ja] = await Promise.all([
    translateAll(examples, 'ko'),
    translateAll(examples, 'en'),
    translateAll(examples, 'ja'),
  ]);

  let badCount = 0;
  const repaired = entries.map((entry, index) => {
    const next = {
      ...entry,
      exampleMeanings: {
        ko: ko[index] || '',
        en: en[index] || '',
        ja: ja[index] || '',
      },
      reviewStatus: 'machine_example_repaired_needs_human_review',
    };
    const issues = qa(next);
    if (issues.length > 0) badCount += 1;
    return {
      ...next,
      qaStatus: issues.length === 0 ? 'pass_machine_checks' : 'needs_fix',
      qaIssues: issues,
    };
  });

  const qaSummary = {};
  for (const entry of repaired) {
    qaSummary[entry.qaStatus] = (qaSummary[entry.qaStatus] || 0) + 1;
  }
  const payload = {
    ...data,
    exampleRepairedAt: new Date().toISOString(),
    qaSummary,
    exampleRepairNote:
      'Removed metalinguistic word-study examples and regenerated sentence-style examples with machine translations.',
    entries: repaired,
  };
  fs.writeFileSync(path, `${JSON.stringify(payload, null, 2)}\n`, 'utf8');
  console.log({ total: repaired.length, badCount, qaSummary });
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
