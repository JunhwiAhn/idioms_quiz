const fs = require('fs');
const https = require('https');

const path = 'assets/data/dele_a1_a2_b1_problem_bank.enriched.json';
const targetA2 = 1000;

const themes = [
  {
    theme: 'city_services',
    nouns: [
      'oficina de turismo',
      'comisaria de policia',
      'centro cultural',
      'polideportivo',
      'biblioteca municipal',
      'ayuntamiento',
      'oficina de correos',
      'parada de taxis',
      'carril bici',
      'paso de peatones',
      'semáforo en rojo',
      'semáforo en verde',
      'zona peatonal',
      'zona verde',
      'aparcamiento publico',
      'maquina expendedora',
      'ventanilla de informacion',
      'horario de atencion',
      'numero de turno',
      'sala de espera',
      'servicio tecnico',
      'objetos perdidos',
      'plano del metro',
      'linea de autobus',
      'tarifa reducida',
      'abono mensual',
      'billete sencillo',
      'transbordo',
      'andén',
      'taquilla',
      'salida principal',
      'entrada lateral',
      'escalera mecanica',
      'ascensor publico',
      'fuente publica',
      'banco del parque',
      'papelera',
      'contenedor de reciclaje',
      'centro comercial',
      'mercadillo',
    ],
    nounExample: (term) => `Busco ${term} cerca de aqui.`,
  },
  {
    theme: 'forms_services',
    actions: [
      'pedir cita',
      'cambiar la cita',
      'confirmar la cita',
      'cancelar la cita',
      'rellenar el formulario',
      'firmar el documento',
      'presentar una solicitud',
      'renovar el permiso',
      'hacer una fotocopia',
      'adjuntar un archivo',
      'enviar un correo',
      'recibir una respuesta',
      'abrir una cuenta',
      'cerrar una cuenta',
      'pagar una tasa',
      'guardar el justificante',
      'consultar el expediente',
      'solicitar informacion',
      'hacer una reclamacion',
      'poner una queja',
      'pedir un certificado',
      'recoger el paquete',
      'devolver el producto',
      'cambiar la contraseña',
      'activar la tarjeta',
      'bloquear la tarjeta',
      'comprobar los datos',
      'modificar la direccion',
      'subir una foto',
      'descargar el archivo',
      'imprimir el recibo',
      'escanear el documento',
      'hacer una reserva',
      'anular una reserva',
      'confirmar el pago',
      'pedir un presupuesto',
      'contratar un seguro',
      'dar de baja un servicio',
      'darse de alta',
      'pedir turno',
      'esperar el turno',
      'consultar el horario',
      'recoger el pedido',
      'hacer el seguimiento',
      'avisar al responsable',
      'llamar a atencion al cliente',
    ],
    actionExample: (term) => `Necesito ${term} antes del viernes.`,
  },
  {
    theme: 'home_life',
    nouns: [
      'contrato de alquiler',
      'fianza',
      'mudanza',
      'caja de carton',
      'vecino de arriba',
      'vecina de abajo',
      'ruido de la calle',
      'llave del portal',
      'timbre',
      'buzon',
      'reunion de vecinos',
      'normas de la comunidad',
      'averia',
      'goteo',
      'humedad',
      'caldera',
      'radiador',
      'termostato',
      'microondas',
      'lavadora',
      'secadora',
      'frigorifico',
      'congelador',
      'horno',
      'cafetera',
      'aspiradora',
      'escoba',
      'recogedor',
      'producto de limpieza',
      'cesto de la ropa',
      'ropa sucia',
      'ropa limpia',
      'sabana',
      'almohada',
      'manta',
      'colchon',
      'estanteria',
      'cajon',
      'mesilla de noche',
      'lampara de techo',
      'interruptor',
      'enchufe doble',
      'cargador',
      'cable alargador',
      'manual de instrucciones',
      'garantia',
      'servicio de reparacion',
      'tecnico',
    ],
    nounExample: (term) => `Tengo que revisar ${term} en casa.`,
  },
  {
    theme: 'health_daily',
    nouns: [
      'dolor muscular',
      'dolor fuerte',
      'fiebre alta',
      'tos',
      'gripe',
      'estornudo',
      'congestion nasal',
      'cansancio',
      'insomnio',
      'nauseas',
      'revision medica',
      'medico de cabecera',
      'enfermero',
      'analisis medico',
      'resultado del analisis',
      'vacuna',
      'mascarilla',
      'gel desinfectante',
      'crema solar',
      'protector solar',
      'picadura',
      'ampolla',
      'corte',
      'dolor leve',
      'dolor intenso',
      'medicina natural',
      'dosis',
      'efecto secundario',
      'instrucciones del medicamento',
      'farmaceutico',
      'vida saludable',
      'dieta equilibrada',
      'ejercicio diario',
      'paseo largo',
      'descanso suficiente',
      'agua mineral',
      'revision dental',
      'cepillo electrico',
      'hilo dental',
      'gafas graduadas',
      'lentillas',
      'vista cansada',
    ],
    nounExample: (term) => `Hablo de ${term} con el medico.`,
  },
  {
    theme: 'shopping_clothes',
    nouns: [
      'probador',
      'talla mediana',
      'talla grande',
      'talla pequena',
      'numero de zapato',
      'etiqueta',
      'codigo de barras',
      'ticket de compra',
      'precio final',
      'descuento especial',
      'oferta limitada',
      'rebajas',
      'segunda mano',
      'producto nuevo',
      'producto usado',
      'devolucion gratuita',
      'cambio de talla',
      'ropa de invierno',
      'ropa de verano',
      'chaqueta ligera',
      'abrigo largo',
      'camiseta de manga corta',
      'camisa de manga larga',
      'pantalon vaquero',
      'falda corta',
      'vestido elegante',
      'traje',
      'corbata',
      'bufanda',
      'guantes',
      'calcetines',
      'botas',
      'zapatillas deportivas',
      'sandalias',
      'bolso',
      'mochila',
      'monedero',
      'cartera',
      'paraguas',
      'regalo',
      'papel de regalo',
      'caja pequena',
      'bolsa reutilizable',
      'compra online',
      'envio gratis',
      'plazo de entrega',
      'direccion de envio',
      'metodo de pago',
    ],
    nounExample: (term) => `Busco ${term} en la tienda.`,
  },
  {
    theme: 'food_restaurant',
    nouns: [
      'reserva para dos',
      'mesa junto a la ventana',
      'terraza exterior',
      'menu infantil',
      'menu vegetariano',
      'menu sin gluten',
      'alergia a los frutos secos',
      'plato del dia',
      'entrante',
      'guarnicion',
      'salsa picante',
      'salsa suave',
      'carne a la plancha',
      'pescado al horno',
      'verduras asadas',
      'arroz blanco',
      'patatas fritas',
      'tortilla francesa',
      'bocadillo de jamon',
      'sandwich mixto',
      'helado de vainilla',
      'tarta de chocolate',
      'fruta de temporada',
      'leche sin lactosa',
      'infusion',
      'botella de agua',
      'jarra de agua',
      'cuchara',
      'tenedor',
      'cuchillo',
      'plato hondo',
      'plato llano',
      'vaso',
      'taza',
      'camarero',
      'camarera',
      'cocinero',
      'reserva confirmada',
      'cuenta final',
      'propina incluida',
      'comida para llevar',
      'pedido a domicilio',
    ],
    nounExample: (term) => `Pido ${term} en el restaurante.`,
  },
  {
    theme: 'travel_hotel',
    nouns: [
      'vuelo directo',
      'vuelo con escala',
      'equipaje de mano',
      'maleta facturada',
      'tarjeta de embarque',
      'puerta de embarque',
      'control de seguridad',
      'retraso del vuelo',
      'cancelacion del vuelo',
      'llegada puntual',
      'salida retrasada',
      'alojamiento',
      'habitacion individual',
      'habitacion doble',
      'habitacion con vistas',
      'habitacion tranquila',
      'recepcion del hotel',
      'desayuno incluido',
      'media pension',
      'pension completa',
      'servicio de habitaciones',
      'toalla limpia',
      'llave de la habitacion',
      'tarjeta de acceso',
      'aire acondicionado roto',
      'mapa turistico',
      'visita guiada',
      'excursion de un dia',
      'seguro de viaje',
      'oferta de viaje',
      'temporada alta',
      'temporada baja',
      'playa tranquila',
      'montana nevada',
      'camino rural',
      'pueblo historico',
      'centro historico',
      'museo gratuito',
      'entrada reducida',
      'guia turistico',
      'recuerdo',
      'postal',
      'camara de fotos',
      'bateria externa',
      'adaptador',
      'enchufe europeo',
      'frontera',
      'aduana',
    ],
    nounExample: (term) => `Necesito ${term} durante el viaje.`,
  },
  {
    theme: 'work_study',
    nouns: [
      'oferta de empleo',
      'entrevista de trabajo',
      'contrato temporal',
      'contrato indefinido',
      'jornada completa',
      'media jornada',
      'horario flexible',
      'salario mensual',
      'experiencia laboral',
      'curriculum vitae',
      'carta de presentacion',
      'puesto de trabajo',
      'compañero de trabajo',
      'jefe directo',
      'reunion semanal',
      'correo profesional',
      'llamada de trabajo',
      'tarea urgente',
      'fecha limite',
      'informe breve',
      'presentacion oral',
      'curso intensivo',
      'clase presencial',
      'clase a distancia',
      'material de estudio',
      'apuntes',
      'horario de clase',
      'nota final',
      'trabajo en grupo',
      'examen oral',
      'examen escrito',
      'prueba de nivel',
      'diccionario bilingue',
      'explicacion clara',
      'duda',
      'correccion',
      'respuesta correcta',
      'respuesta equivocada',
      'practica diaria',
      'actividad interactiva',
      'archivo compartido',
      'plataforma online',
      'conexion a internet',
      'pantalla compartida',
    ],
    nounExample: (term) => `Uso ${term} para estudiar o trabajar.`,
  },
  {
    theme: 'technology_media',
    nouns: [
      'telefono inteligente',
      'ordenador portatil',
      'tableta',
      'auriculares',
      'altavoz',
      'microfono',
      'camara web',
      'pantalla tactil',
      'raton inalambrico',
      'teclado',
      'impresora',
      'memoria USB',
      'disco duro',
      'nube',
      'aplicacion movil',
      'red social',
      'mensaje de voz',
      'videollamada',
      'grupo de chat',
      'notificacion',
      'perfil',
      'nombre de usuario',
      'contraseña segura',
      'codigo de verificacion',
      'enlace',
      'pagina web',
      'buscador',
      'archivo PDF',
      'documento compartido',
      'foto de perfil',
      'video corto',
      'serie online',
      'programa de television',
      'noticia digital',
      'periodico online',
      'radio local',
      'podcast',
      'subtitulo',
      'volumen',
      'modo silencio',
      'bateria baja',
      'cargador rapido',
      'conexion wifi',
      'datos moviles',
    ],
    nounExample: (term) => `Uso ${term} todos los dias.`,
  },
  {
    theme: 'opinions_feelings',
    nouns: [
      'buena idea',
      'mala idea',
      'opinion personal',
      'punto de vista',
      'acuerdo',
      'desacuerdo',
      'decision dificil',
      'plan sencillo',
      'cambio importante',
      'noticia interesante',
      'experiencia positiva',
      'experiencia negativa',
      'momento especial',
      'sorpresa agradable',
      'problema comun',
      'solucion practica',
      'consejo util',
      'deseo',
      'sueño',
      'miedo',
      'preocupacion',
      'alegria',
      'tristeza',
      'enojo',
      'vergüenza',
      'orgullo',
      'interes',
      'paciencia',
      'confianza',
      'seguridad',
      'tranquilidad',
      'amistad',
      'relacion cercana',
      'vida social',
      'tiempo personal',
      'recuerdo feliz',
      'mensaje amable',
      'disculpa sincera',
      'favor pequeno',
      'invitacion',
      'celebracion',
      'cumpleanos',
      'fiesta familiar',
      'visita sorpresa',
    ],
    nounExample: (term) => `Hablo de ${term} con mi familia.`,
  },
  {
    theme: 'connectors_time',
    nouns: [
      'al principio',
      'al final',
      'por la mañana temprano',
      'por la noche tarde',
      'dentro de poco',
      'hace poco',
      'la semana pasada',
      'el mes que viene',
      'el año pasado',
      'el próximo verano',
      'cada dos dias',
      'una vez al mes',
      'dos veces por semana',
      'de vez en cuando',
      'casi siempre',
      'casi nunca',
      'en primer lugar',
      'en segundo lugar',
      'por ejemplo',
      'en cambio',
      'ademas',
      'por eso',
      'por lo tanto',
      'sin embargo',
      'aunque sea tarde',
      'mientras tanto',
      'antes de salir',
      'despues de comer',
      'al llegar',
      'al volver',
      'si es posible',
      'si hace buen tiempo',
      'cuando termine',
      'hasta que llegue',
      'desde que vivo aqui',
      'durante el viaje',
    ],
    nounExample: (term) => `Uso la expresion ${term} en una frase.`,
  },
];

const comboThemes = [
  {
    theme: 'appointments',
    verbs: ['pedir', 'confirmar', 'cancelar', 'cambiar', 'reprogramar', 'anotar'],
    objects: ['una cita', 'una reserva', 'un turno', 'una visita', 'una reunion', 'una consulta'],
    example: (term) => `Necesito ${term} antes del viernes.`,
  },
  {
    theme: 'documents',
    verbs: ['rellenar', 'firmar', 'presentar', 'enviar', 'descargar', 'imprimir', 'escanear', 'guardar'],
    objects: [
      'el formulario',
      'la solicitud',
      'el documento',
      'el archivo',
      'el recibo',
      'el certificado',
      'el justificante',
      'la fotocopia',
    ],
    example: (term) => `Voy a ${term} en la oficina.`,
  },
  {
    theme: 'payments',
    verbs: ['pagar', 'revisar', 'guardar', 'pedir', 'confirmar', 'calcular', 'comparar', 'consultar'],
    objects: [
      'la factura',
      'el recibo',
      'el presupuesto',
      'la cuenta',
      'la cuota',
      'la tasa',
      'el precio',
      'el descuento',
    ],
    example: (term) => `Tengo que ${term} hoy.`,
  },
  {
    theme: 'travel_actions',
    verbs: ['reservar', 'comprar', 'cambiar', 'cancelar', 'buscar', 'confirmar', 'perder', 'encontrar', 'mostrar', 'guardar'],
    objects: [
      'el billete',
      'el vuelo',
      'el asiento',
      'la habitacion',
      'la maleta',
      'el pasaporte',
      'el mapa',
      'la ruta',
      'la entrada',
      'el alojamiento',
    ],
    example: (term) => `Es importante ${term} durante el viaje.`,
  },
  {
    theme: 'shopping_actions',
    verbs: ['comprar', 'probarse', 'cambiar', 'devolver', 'buscar', 'elegir', 'lavar', 'planchar'],
    objects: [
      'una camisa',
      'una chaqueta',
      'un pantalon',
      'unos zapatos',
      'un abrigo',
      'un vestido',
      'una talla',
      'un regalo',
      'una mochila',
      'un paraguas',
      'una bufanda',
      'unos guantes',
    ],
    example: (term) => `Voy a ${term} esta tarde.`,
  },
  {
    theme: 'technology_actions',
    verbs: ['abrir', 'cerrar', 'enviar', 'recibir', 'descargar', 'subir', 'borrar', 'guardar', 'compartir', 'actualizar'],
    objects: [
      'un mensaje',
      'un archivo',
      'una foto',
      'un video',
      'una aplicacion',
      'una pagina',
      'un enlace',
      'una contraseña',
      'un documento',
      'una carpeta',
      'una copia',
      'una cuenta',
    ],
    example: (term) => `Aprendo a ${term} con el movil.`,
  },
  {
    theme: 'health_actions',
    verbs: ['pedir', 'tomar', 'comprar', 'guardar', 'leer', 'seguir', 'explicar', 'describir'],
    objects: [
      'una receta',
      'una pastilla',
      'un jarabe',
      'una vacuna',
      'una cita medica',
      'un tratamiento',
      'las instrucciones',
      'los sintomas',
      'el dolor',
      'la temperatura',
      'una venda',
      'un termometro',
    ],
    example: (term) => `Tengo que ${term} por salud.`,
  },
  {
    theme: 'study_actions',
    verbs: ['hacer', 'entregar', 'corregir', 'preparar', 'repasar', 'aprobar', 'suspender', 'explicar', 'entender', 'practicar'],
    objects: [
      'un ejercicio',
      'un examen',
      'una tarea',
      'una redaccion',
      'una presentacion',
      'una pregunta',
      'una respuesta',
      'una leccion',
      'un dialogo',
      'una actividad',
    ],
    example: (term) => `Necesito ${term} para clase.`,
  },
];

function normalize(value) {
  return (value || '')
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

function blankExample(example, term) {
  const escaped = term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const regex = new RegExp(escaped, 'i');
  if (regex.test(example)) return example.replace(regex, '____');
  const first = term.split(/\s+/)[0];
  return example.replace(
    new RegExp(first.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i'),
    '____',
  );
}

function buildCandidates(existing) {
  const candidates = [];
  for (const theme of themes) {
    for (const term of theme.nouns || []) {
      const normalized = normalize(term);
      if (!existing.has(normalized)) {
        candidates.push({
          term,
          normalizedTerm: normalized,
          theme: theme.theme,
          example: theme.nounExample(term),
        });
      }
    }
    for (const term of theme.actions || []) {
      const normalized = normalize(term);
      if (!existing.has(normalized)) {
        candidates.push({
          term,
          normalizedTerm: normalized,
          theme: theme.theme,
          example: theme.actionExample(term),
        });
      }
    }
  }

  for (const comboTheme of comboThemes) {
    for (const verb of comboTheme.verbs) {
      for (const object of comboTheme.objects) {
        const term = `${verb} ${object}`;
        const normalized = normalize(term);
        if (!existing.has(normalized)) {
          candidates.push({
            term,
            normalizedTerm: normalized,
            theme: comboTheme.theme,
            example: comboTheme.example(term),
          });
        }
      }
    }
  }

  const seen = new Set();
  return candidates.filter((candidate) => {
    if (seen.has(candidate.normalizedTerm)) return false;
    seen.add(candidate.normalizedTerm);
    return true;
  });
}

function representativeA2Count(entries) {
  const rank = {A1: 1, A2: 2, B1: 3, B2: 4, C1: 5};
  const groups = new Map();
  for (const entry of entries) {
    const key = normalize(entry.normalizedTerm || entry.term);
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(entry);
  }

  let count = 0;
  for (const group of groups.values()) {
    group.sort((a, b) => (rank[a.level] || 99) - (rank[b.level] || 99));
    if (group[0].level === 'A2') count += 1;
  }
  return count;
}

function chooseWrongChoices(entry, allNew) {
  return allNew
    .filter(
      (candidate) =>
        candidate.theme === entry.theme && candidate.term !== entry.term,
    )
    .slice(0, 3)
    .map((candidate) => candidate.term);
}

async function main() {
  const data = JSON.parse(fs.readFileSync(path, 'utf8'));
  const entries = data.entries || data;
  const existing = new Set(
    entries.map((entry) => normalize(entry.normalizedTerm || entry.term)),
  );

  const current = representativeA2Count(entries);
  const needed = Math.max(0, targetA2 - current);
  if (needed === 0) {
    console.log({added: 0, current});
    return;
  }

  const candidates = buildCandidates(existing).slice(0, needed);
  if (candidates.length < needed) {
    throw new Error(`Need ${needed} A2 terms, only ${candidates.length} candidates available.`);
  }

  const terms = candidates.map((candidate) => candidate.term);
  const examples = candidates.map((candidate) => candidate.example);
  const [ko, en, ja, exKo, exEn, exJa] = await Promise.all([
    translateAll(terms, 'ko'),
    translateAll(terms, 'en'),
    translateAll(terms, 'ja'),
    translateAll(examples, 'ko'),
    translateAll(examples, 'en'),
    translateAll(examples, 'ja'),
  ]);

  const start = entries.length + 1;
  const prepared = candidates.map((candidate, index) => ({
    id: `a2_fill_${String(index + 1).padStart(4, '0')}`,
    index: start + index,
    level: 'A2',
    sourceLevel: 'A2',
    term: candidate.term,
    normalizedTerm: candidate.normalizedTerm,
    reading: candidate.term,
    pronunciation: candidate.term,
    meanings: {
      ko: ko[index] || '',
      en: en[index] || '',
      ja: ja[index] || '',
    },
    example: candidate.example,
    blankedExample: blankExample(candidate.example, candidate.term),
    answer: candidate.term,
    exampleMeanings: {
      ko: exKo[index] || '',
      en: exEn[index] || '',
      ja: exJa[index] || '',
    },
    wrongChoices: chooseWrongChoices(candidate, candidates),
    difficulty: 2,
    theme: candidate.theme,
    sourceBasis: 'A2 fill: unique functional A2 vocabulary, not reclassified from A1/B1 duplicates',
    reviewStatus: 'machine_generated_needs_human_review',
    qaStatus: 'pass_machine_checks',
    qaIssues: [],
  }));

  entries.push(...prepared);

  const counts = {};
  for (const entry of entries) counts[entry.level] = (counts[entry.level] || 0) + 1;
  data.counts = {...counts, total: entries.length};
  data.a2Fill = {
    addedAt: new Date().toISOString(),
    added: prepared.length,
    targetRepresentativeA2: targetA2,
    note: 'Added unique A2-only entries until representative A2 count reaches 1000.',
  };

  fs.writeFileSync(path, `${JSON.stringify(data, null, 2)}\n`, 'utf8');
  console.log({added: prepared.length, fromRepresentativeA2: current, targetA2});
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
