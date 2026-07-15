const fs = require('fs');
const https = require('https');

const path = 'assets/data/dele_a1_a2_b1_problem_bank.enriched.json';

const badPattern =
  /Hay un .* en la mesa|Hay una .* en la mesa|Quiero .* con mis amigos|Estudio la palabra|""/i;

const fixedExamples = new Map(
  Object.entries({
    dias: 'Trabajo tres dias esta semana.',
    tardes: 'Estudio por las tardes.',
    noches: 'Duermo bien por las noches.',
    hasta: 'Camino hasta la estacion.',
    luego: 'Primero estudio y luego descanso.',
    manana: 'Nos vemos manana por la tarde.',
    favor: 'Necesito un favor pequeno.',
    vale: 'Vale, nos vemos a las ocho.',
    ser: 'Quiero ser puntual en clase.',
    estar: 'Voy a estar en casa esta noche.',
    tener: 'Voy a tener tiempo manana.',
    vivir: 'Quiero vivir cerca del centro.',
    mujer: 'La mujer trabaja en una oficina.',
    mesa: 'Pon el libro sobre la mesa.',
    aprender: 'Quiero aprender espanol este ano.',
    estudiar: 'Voy a estudiar en la biblioteca.',
    leer: 'Me gusta leer por la noche.',
    escribir: 'Voy a escribir un mensaje.',
    hablar: 'Necesito hablar con el profesor.',
    escuchar: 'Voy a escuchar la conversacion.',
    repetir: 'Puedes repetir la frase, por favor.',
    llamar: 'Voy a llamar a mi amigo esta tarde.',
    llamarse: 'Ella se llama Ana.',
  }),
);

const peopleEn = new Set([
  'father',
  'mother',
  'son',
  'daughter',
  'brother',
  'sister',
  'grandfather',
  'grandmother',
  'uncle',
  'aunt',
  'cousin',
  'friend',
  'neighbor',
  'person',
  'man',
  'woman',
  'child',
  'girl',
  'boy',
  'student',
  'teacher',
  'doctor',
  'dentist',
  'colleague',
  'boyfriend',
  'girlfriend',
]);

const adjectiveEn = new Set([
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
  'electronic',
  'digital',
  'analog',
  'single',
  'adopted',
  'healthy',
  'familiar',
  'near',
  'far',
  'rich',
  'humble',
  'social',
]);

const commonNounContexts = [
  {
    words: ['calle', 'ciudad', 'pueblo', 'pais', 'plaza', 'barrio', 'estacion'],
    example: (term) => `Camino por la ${term} cada manana.`,
  },
  {
    words: ['telefono', 'movil', 'correo', 'numero', 'direccion'],
    example: (term) => `Apunto mi ${term} en el formulario.`,
  },
  {
    words: ['pasaporte', 'documento', 'permiso', 'certificado', 'tarjeta', 'fotocopia'],
    example: (term) => `Necesito el ${term} para el tramite.`,
  },
  {
    words: ['piso', 'habitacion', 'dormitorio', 'salon', 'cocina', 'bano', 'puerta', 'ventana'],
    example: (term) => `La ${term} de la casa es pequena.`,
  },
  {
    words: ['colegio', 'clase', 'cuaderno', 'lapiz', 'boligrafo', 'examen', 'ejercicio'],
    example: (term) => `Uso el ${term} en clase.`,
  },
  {
    words: ['zumo', 'desayuno', 'cena', 'fruta', 'manzana', 'naranja', 'cafe', 'agua', 'pan'],
    example: (term) => `Tomo ${term} en el desayuno.`,
  },
  {
    words: ['factura', 'precio', 'dinero', 'cuenta', 'recibo', 'gasto'],
    example: (term) => `Reviso el ${term} antes de pagar.`,
  },
  {
    words: ['tren', 'autobus', 'avion', 'billete', 'viaje', 'hotel', 'reserva'],
    example: (term) => `Necesito el ${term} para viajar.`,
  },
  {
    words: ['salud', 'dolor', 'sintoma', 'receta', 'pastilla', 'hospital', 'farmacia'],
    example: (term) => `Hablo del ${term} con el medico.`,
  },
];

function normalize(value) {
  return (value || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .trim();
}

function isVerb(term) {
  return /(ar|er|ir|arse|erse|irse)$/.test(normalize(term));
}

function articleFor(term) {
  const normalized = normalize(term);
  if (/a$/.test(normalized) && !/(ma|pa)$/.test(normalized)) return 'la';
  return 'el';
}

function personArticle(term) {
  const normalized = normalize(term);
  if (/a$/.test(normalized) && !/(ma|pa)$/.test(normalized)) return 'una';
  return 'un';
}

function makeVerbExample(term) {
  const normalized = normalize(term);
  if (/(arse|erse|irse)$/.test(normalized)) {
    return `Voy a ${term.slice(0, -2)}me esta tarde.`;
  }
  return `Voy a ${term} esta tarde.`;
}

function makeExample(entry) {
  const term = entry.term;
  const normalized = normalize(term);
  const en = normalize(entry.meanings?.en || '');

  if (fixedExamples.has(normalized)) return fixedExamples.get(normalized);

  if (isVerb(term)) return makeVerbExample(term);

  if (peopleEn.has(en)) {
    return `Conozco a ${personArticle(term)} ${term} del barrio.`;
  }

  if (adjectiveEn.has(en)) {
    return `Este resultado es ${term}.`;
  }

  for (const context of commonNounContexts) {
    if (context.words.some((word) => normalized.includes(word))) {
      return context.example(term);
    }
  }

  if (term.includes(' ')) {
    return `Necesito ${term} hoy.`;
  }

  return `Uso ${articleFor(term)} ${term} en una situacion diaria.`;
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

async function main() {
  const data = JSON.parse(fs.readFileSync(path, 'utf8'));
  const entries = data.entries || data;
  const targets = [];

  for (const entry of entries) {
    const joined = [
      entry.example,
      entry.blankedExample,
      entry.exampleMeanings?.ko,
      entry.exampleMeanings?.en,
      entry.exampleMeanings?.ja,
    ].join(' ');
    if (!badPattern.test(joined)) continue;

    const example = makeExample(entry);
    targets.push({entry, example});
  }

  const examples = targets.map((target) => target.example);
  const [ko, en, ja] = await Promise.all([
    translateAll(examples, 'ko'),
    translateAll(examples, 'en'),
    translateAll(examples, 'ja'),
  ]);

  for (let index = 0; index < targets.length; index += 1) {
    const {entry, example} = targets[index];
    entry.example = example;
    entry.blankedExample = blankExample(example, entry.term);
    entry.exampleMeanings = {
      ko: ko[index] || '',
      en: en[index] || '',
      ja: ja[index] || '',
    };
    entry.reviewStatus = 'bad_pattern_repaired_needs_human_review';
    entry.qaStatus = badPattern.test([entry.example, entry.blankedExample].join(' '))
      ? 'needs_fix'
      : 'pass_machine_checks';
    entry.qaIssues = entry.qaStatus === 'needs_fix' ? ['bad_example_pattern'] : [];
  }

  fs.writeFileSync(path, `${JSON.stringify(data, null, 2)}\n`, 'utf8');
  console.log({repaired: targets.length});
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
