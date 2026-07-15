const fs = require('fs');
const https = require('https');

const path = 'assets/data/dele_a1_a2_b1_problem_bank.enriched.json';

const themes = [
  {
    theme: 'identity_documents',
    terms: [
      'solicitud', 'certificado medico', 'certificado de empadronamiento',
      'permiso de trabajo', 'permiso de residencia', 'tarjeta de transporte',
      'tarjeta bancaria', 'tarjeta de credito', 'documento de identidad',
      'numero de pasaporte', 'fecha de nacimiento', 'lugar de nacimiento',
      'estado civil', 'codigo de seguridad', 'firma digital', 'fotocopia',
      'original', 'copia', 'archivo adjunto', 'justificante',
      'resguardo', 'formulario online', 'datos personales', 'apellidos',
      'nombre completo', 'nacionalidad extranjera', 'renovacion',
      'caducidad', 'expediente', 'registro',
    ],
    example: (term) => `Necesito ${term} para el tramite.`,
  },
  {
    theme: 'health_body',
    terms: [
      'dolor de cabeza', 'dolor de espalda', 'dolor de garganta',
      'dolor de muelas', 'dolor de estomago', 'pastilla', 'jarabe',
      'receta medica', 'analisis de sangre', 'radiografia',
      'centro de salud', 'sala de espera', 'consulta medica',
      'seguro de salud', 'tarjeta sanitaria', 'cita previa',
      'urgencias', 'ambulancia', 'dentista', 'oculista',
      'dermatologo', 'pediatra', 'especialista', 'tratamiento',
      'reposo', 'resfriado', 'tos seca', 'mareo',
      'herida', 'quemadura', 'venda', 'termometro',
      'temperatura', 'sintoma', 'alergia alimentaria', 'vida sana',
    ],
    example: (term) => `Tengo que pedir cita por ${term}.`,
  },
  {
    theme: 'daily_routine',
    terms: [
      'despertador', 'rutina diaria', 'hora de comer', 'hora de dormir',
      'siesta', 'ducha rapida', 'cepillo de dientes', 'pasta de dientes',
      'gel de ducha', 'champu', 'toalla', 'maquinilla',
      'crema', 'perfume', 'desodorante', 'peine',
      'secador', 'espejo', 'agenda', 'calendario',
      'recordatorio', 'plan semanal', 'tiempo libre', 'descanso',
      'paseo corto', 'ejercicio fisico', 'clase online', 'tarea pendiente',
      'recado', 'costumbre', 'habito', 'puntualidad',
    ],
    example: (term) => `El ${term} forma parte de mi dia.`,
  },
  {
    theme: 'home_tasks',
    terms: [
      'alquiler mensual', 'gastos de luz', 'gastos de agua', 'factura de gas',
      'comunidad', 'ascensor', 'portero', 'vecindario',
      'balcon', 'terraza', 'pasillo', 'entrada',
      'salida de emergencia', 'planta baja', 'primer piso', 'segundo piso',
      'cubo de basura', 'bolsa de basura', 'lavavajillas', 'tendedero',
      'plancha', 'tabla de planchar', 'detergente', 'suavizante',
      'fregona', 'trapo', 'esponja', 'cubo',
      'enchufe', 'bombilla', 'persiana', 'cortina',
      'calefaccion central', 'aire acondicionado', 'mando a distancia',
      'llave de repuesto',
    ],
    example: (term) => `En casa tenemos ${term}.`,
  },
  {
    theme: 'restaurants',
    terms: [
      'mesa libre', 'mesa reservada', 'carta de bebidas', 'menu del dia',
      'primer plato', 'segundo plato', 'plato principal', 'plato vegetariano',
      'plato combinado', 'ensalada mixta', 'sopa del dia', 'postre casero',
      'agua con gas', 'agua sin gas', 'copa de vino', 'cerveza sin alcohol',
      'cafe solo', 'cafe con leche', 'cafe cortado', 'te verde',
      'zumo natural', 'racion', 'tapa', 'aperitivo',
      'cubiertos', 'servilleta', 'mantel', 'propina',
      'cuenta separada', 'pagar con tarjeta', 'pagar en efectivo',
      'llevarse la comida',
    ],
    example: (term) => `En el restaurante pido ${term}.`,
  },
  {
    theme: 'shopping_money',
    terms: [
      'precio final', 'precio especial', 'descuento', 'oferta',
      'rebajas', 'devolucion', 'cambio de talla', 'ticket de compra',
      'recibo', 'caja', 'carrito', 'cesta',
      'probador', 'escaparate', 'mostrador', 'dependiente',
      'cliente habitual', 'producto local', 'marca', 'modelo',
      'garantia', 'envio a domicilio', 'pedido online', 'compra segura',
      'monedero', 'billete', 'moneda', 'cuenta bancaria',
      'cajero automatico', 'transferencia', 'pago movil', 'codigo descuento',
    ],
    example: (term) => `Quiero preguntar por ${term}.`,
  },
  {
    theme: 'clothing',
    terms: [
      'ropa interior', 'traje de bano', 'chandal', 'vaqueros',
      'camisa de manga corta', 'camisa de manga larga', 'chaqueta ligera',
      'abrigo de invierno', 'zapatos comodos', 'zapatos de tacon',
      'zapatillas deportivas', 'botas de lluvia', 'calcetines',
      'medias', 'pijama', 'corbata', 'collar',
      'pendientes', 'pulsera', 'anillo', 'reloj de pulsera',
      'gafas de sol', 'gafas graduadas', 'bolso', 'cartera',
      'mochila pequena', 'talla pequena', 'talla mediana', 'talla grande',
      'probador libre', 'color oscuro', 'color claro',
    ],
    example: (term) => `Busco ${term} en esta tienda.`,
  },
  {
    theme: 'work_professions',
    terms: [
      'puesto de trabajo', 'oferta de empleo', 'entrevista de trabajo',
      'contrato temporal', 'contrato fijo', 'jornada completa',
      'media jornada', 'turno de manana', 'turno de tarde',
      'horas extra', 'sueldo mensual', 'nomina', 'vacaciones pagadas',
      'baja medica', 'compañero de trabajo', 'reunion de equipo',
      'correo de trabajo', 'llamada de trabajo', 'informe sencillo',
      'tarea urgente', 'fecha limite', 'cliente nuevo',
      'atencion al cliente', 'oficina central', 'formacion profesional',
      'practicas', 'curriculum actualizado', 'experiencia laboral',
      'responsable de ventas', 'cajero', 'recepcionista', 'repartidor',
      'peluquero', 'cocinero', 'mecanico', 'electricista',
    ],
    example: (term) => `Hablo con mi jefe sobre ${term}.`,
  },
  {
    theme: 'travel_hotels',
    terms: [
      'billete de ida', 'billete de vuelta', 'tarjeta de embarque',
      'puerta de embarque', 'control de seguridad', 'equipaje de mano',
      'maleta facturada', 'retraso del vuelo', 'cancelacion del vuelo',
      'estacion de autobuses', 'anden', 'taquilla', 'horario de trenes',
      'plano de la ciudad', 'alquiler de coches', 'gasolinera',
      'peaje', 'area de descanso', 'habitacion individual',
      'habitacion doble', 'cama supletoria', 'recepcion del hotel',
      'desayuno incluido', 'media pension', 'pension completa',
      'reserva confirmada', 'entrada al museo', 'visita guiada',
      'oficina de turismo', 'excursion de un dia', 'seguro de viaje',
      'temporada alta', 'temporada baja',
    ],
    example: (term) => `Para el viaje necesito ${term}.`,
  },
  {
    theme: 'services',
    terms: [
      'oficina de correos', 'carta certificada', 'paquete urgente',
      'sello', 'buzon', 'numero de seguimiento',
      'comisaria', 'denuncia', 'policia local', 'ayuntamiento',
      'biblioteca publica', 'centro cultural', 'polideportivo',
      'piscina municipal', 'servicio tecnico', 'averia',
      'reparacion', 'cita telefonica', 'atencion telefonica',
      'numero gratuito', 'horario de apertura', 'horario de cierre',
      'lista de espera', 'turno', 'ventanilla', 'informacion general',
      'queja', 'reclamacion', 'solucion rapida', 'servicio a domicilio',
    ],
    example: (term) => `Necesito informacion sobre ${term}.`,
  },
  {
    theme: 'public_notices',
    terms: [
      'prohibido fumar', 'prohibido aparcar', 'entrada gratuita',
      'entrada principal', 'salida de emergencia', 'aforo completo',
      'cerrado por vacaciones', 'abierto al publico', 'fuera de servicio',
      'en obras', 'suelo mojado', 'silencio por favor',
      'perros permitidos', 'zona peatonal', 'zona azul',
      'direccion obligatoria', 'paso de peatones', 'parada temporal',
      'desvio', 'informacion turistica', 'objetos perdidos',
      'caja abierta', 'caja cerrada', 'solo efectivo',
      'solo tarjeta', 'reserva necesaria', 'cita previa obligatoria',
    ],
    example: (term) => `En el cartel leo ${term}.`,
  },
  {
    theme: 'technology',
    terms: [
      'telefono movil', 'cargador', 'bateria baja', 'pantalla tactil',
      'ordenador portatil', 'raton', 'teclado', 'impresora',
      'conexion wifi', 'datos moviles', 'pagina web', 'correo electronico',
      'mensaje de texto', 'mensaje de voz', 'videollamada',
      'aplicacion movil', 'nombre de usuario', 'contraseña segura',
      'codigo de acceso', 'archivo pdf', 'foto adjunta',
      'enlace', 'buscador', 'red social', 'perfil publico',
      'notificacion', 'descarga', 'actualizacion', 'copia de seguridad',
      'configuracion', 'modo avion',
    ],
    example: (term) => `Uso ${term} todos los dias.`,
  },
  {
    theme: 'opinions_preferences',
    terms: [
      'opinion personal', 'punto a favor', 'punto en contra',
      'estar de acuerdo', 'no estar de acuerdo', 'me parece bien',
      'me parece mal', 'prefiero quedarme', 'prefiero salir',
      'me apetece', 'no me apetece', 'me interesa',
      'no me interesa', 'me preocupa', 'me da igual',
      'tengo dudas', 'tengo razon', 'tienes razon',
      'idea principal', 'ejemplo claro', 'explicacion sencilla',
      'decision importante', 'posible solucion', 'plan alternativo',
      'ventaja', 'desventaja', 'comparacion', 'diferencia',
      'parecido', 'distinto',
    ],
    example: (term) => `Quiero dar mi opinion sobre ${term}.`,
  },
  {
    theme: 'connectors',
    terms: [
      'al principio', 'al final', 'por ejemplo', 'por eso',
      'ademas', 'sin embargo', 'en cambio', 'entonces',
      'despues de eso', 'antes de salir', 'mientras tanto',
      'a lo mejor', 'tal vez', 'seguro que', 'en mi opinion',
      'por una parte', 'por otra parte', 'en resumen', 'es decir',
      'por lo menos', 'en primer lugar', 'en segundo lugar',
      'de repente', 'poco a poco', 'cada vez mas',
    ],
    example: (term) => `Uso ${term} para conectar ideas.`,
  },
];

function normalize(value) {
  return String(value || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .trim();
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
  for (let i = 0; i < lines.length; i += 60) {
    const chunk = lines.slice(i, i + 60);
    let translated = [];
    for (let attempt = 0; attempt < 3; attempt += 1) {
      try {
        translated = await translateBatch(chunk, target);
        break;
      } catch (error) {
        if (attempt === 2) throw error;
        await new Promise((resolve) => setTimeout(resolve, 600));
      }
    }
    out.push(...translated);
    await new Promise((resolve) => setTimeout(resolve, 120));
  }
  return out;
}

function blankExample(example, term) {
  const escaped = term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const regex = new RegExp(escaped, 'i');
  if (regex.test(example)) return example.replace(regex, '____');
  const first = term.split(/\s+/)[0];
  return example.replace(new RegExp(first.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i'), '____');
}

function chooseWrongChoices(entry, allNew) {
  return allNew
    .filter((candidate) => candidate.theme === entry.theme && candidate.term !== entry.term)
    .slice(0, 3)
    .map((candidate) => candidate.term);
}

async function main() {
  const data = JSON.parse(fs.readFileSync(path, 'utf8'));
  const entries = data.entries || data;
  const existing = new Set(
    entries.map((entry) => normalize(entry.normalizedTerm || entry.term)),
  );
  const newSeeds = [];
  for (const group of themes) {
    for (const term of group.terms) {
      const normalized = normalize(term);
      if (!normalized || existing.has(normalized)) continue;
      existing.add(normalized);
      newSeeds.push({
        term,
        normalizedTerm: term,
        level: 'A2',
        theme: group.theme,
        example: group.example(term),
      });
    }
  }

  const terms = newSeeds.map((entry) => entry.term);
  const examples = newSeeds.map((entry) => entry.example);
  const [ko, en, ja, exampleKo, exampleEn, exampleJa] = await Promise.all([
    translateAll(terms, 'ko'),
    translateAll(terms, 'en'),
    translateAll(terms, 'ja'),
    translateAll(examples, 'ko'),
    translateAll(examples, 'en'),
    translateAll(examples, 'ja'),
  ]);

  const start = entries.length + 1;
  const prepared = newSeeds.map((entry, index) => ({
    id: `a2_sup_${String(index + 1).padStart(4, '0')}`,
    level: 'A2',
    theme: entry.theme,
    term: entry.term,
    normalizedTerm: entry.normalizedTerm,
    questionType: 'vocabulary_meaning_seed',
    promptKo: `스페인어 "${entry.term}"의 뜻과 예문을 검토해 문제로 완성하세요.`,
    promptEn: `Review the Spanish item "${entry.term}" and complete its meaning, example, and distractors.`,
    answer: entry.term,
    meanings: {
      ko: ko[index] || '',
      en: en[index] || '',
      ja: ja[index] || '',
    },
    example: entry.example,
    exampleMeanings: {
      ko: exampleKo[index] || '',
      en: exampleEn[index] || '',
      ja: exampleJa[index] || '',
    },
    blankedExample: blankExample(entry.example, entry.term),
    wrongChoices: [],
    sourceBasis: 'A2 supplement: functional DELE A2 themes, added to replace A1/A2 duplicates with real A2-only items',
    reviewStatus: 'machine_enriched_needs_human_review',
    qaStatus: 'pass_machine_checks',
    qaIssues: [],
  }));

  for (const entry of prepared) {
    entry.wrongChoices = chooseWrongChoices(entry, prepared);
    if (entry.wrongChoices.length < 3) {
      entry.wrongChoices = prepared
        .filter((candidate) => candidate.term !== entry.term)
        .slice(0, 3)
        .map((candidate) => candidate.term);
    }
  }

  entries.push(...prepared);
  const counts = {};
  for (const entry of entries) counts[entry.level] = (counts[entry.level] || 0) + 1;
  data.counts = {...counts, total: entries.length};
  data.a2Supplement = {
    addedAt: new Date().toISOString(),
    added: prepared.length,
    startingIndex: start,
    note: 'These are new A2-only entries, not relabeled duplicates.',
  };
  fs.writeFileSync(path, `${JSON.stringify(data, null, 2)}\n`, 'utf8');
  console.log({added: prepared.length, counts: data.counts});
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
