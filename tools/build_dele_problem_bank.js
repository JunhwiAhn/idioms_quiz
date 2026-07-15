const fs = require('fs');
const https = require('https');

const urls = {
  a12Specific:
    'https://cvc.cervantes.es/ensenanza/biblioteca_ele/plan_curricular/niveles/09_nociones_especificas_inventario_a1-a2.htm',
  a12General:
    'https://cvc.cervantes.es/ensenanza/biblioteca_ele/plan_curricular/niveles/08_nociones_generales_inventario_a1-a2.htm',
  b12Specific:
    'https://cvc.cervantes.es/ensenanza/biblioteca_ele/plan_curricular/niveles/09_nociones_especificas_inventario_b1-b2.htm',
  b12General:
    'https://cvc.cervantes.es/ensenanza/biblioteca_ele/plan_curricular/niveles/08_nociones_generales_inventario_b1-b2.htm',
};

const sourceBasis = [
  {
    name: 'Instituto Cervantes PCIC - Nociones especificas A1-A2',
    url: urls.a12Specific,
  },
  {
    name: 'Instituto Cervantes PCIC - Nociones generales A1-A2',
    url: urls.a12General,
  },
  {
    name: 'Instituto Cervantes PCIC - Nociones especificas B1-B2',
    url: urls.b12Specific,
  },
  {
    name: 'Instituto Cervantes PCIC - Nociones generales B1-B2',
    url: urls.b12General,
  },
  {
    name: 'Council of Europe CEFR global descriptors',
    url: 'https://www.coe.int/en/web/common-european-framework-reference-languages/table-1-cefr-3.3-common-reference-levels-global-scale',
  },
];

const levelThemes = {
  A1: [
    'greetings',
    'personal_information',
    'family_people',
    'numbers_time',
    'home',
    'food_drink',
    'shopping',
    'education',
    'travel_transport',
    'city_directions',
    'weather_nature',
    'basic_descriptions',
    'core_verbs',
    'function_words',
  ],
  A2: [
    'identity_documents',
    'health_body',
    'daily_routine',
    'home_tasks',
    'restaurants',
    'shopping_money',
    'clothing',
    'work_professions',
    'travel_hotels',
    'services',
    'public_notices',
    'technology',
    'opinions_preferences',
    'connectors',
  ],
  B1: [
    'health_services',
    'personality_feelings',
    'relationships_life_events',
    'housing_neighborhood',
    'food_cooking',
    'education_exams',
    'work_business',
    'travel_accommodation',
    'culture_media',
    'technology_communication',
    'money_administration',
    'city_safety',
    'environment',
    'society_civic_life',
    'opinions_arguments',
    'narration_verbs',
  ],
};

const seed = {
  A1: `
hola buenos dias buenas tardes buenas noches adios hasta luego hasta manana gracias por favor perdon disculpa si no vale nombre apellido llamarse ser estar tener vivir edad direccion calle ciudad pueblo pais nacionalidad telefono movil correo electronico pasaporte familia padre madre hijo hija hermano hermana abuelo abuela tio tia primo prima amigo amiga vecino persona hombre mujer nino nina chico chica estudiante profesor trabajo casa piso habitacion dormitorio salon cocina bano puerta ventana mesa silla cama sofa armario llave escuela colegio clase libro cuaderno lapiz boligrafo pregunta respuesta examen ejercicio aprender estudiar leer escribir hablar escuchar repetir comida bebida agua pan cafe leche te zumo desayuno comida cena fruta manzana naranja platano verdura tomate patata arroz pasta carne pescado huevo queso restaurante bar camarero menu carta cuenta tienda mercado supermercado precio dinero euro comprar pagar caro barato bolsa ropa camisa camiseta pantalon vestido zapato color blanco negro rojo azul verde amarillo grande pequeno bueno malo nuevo viejo facil dificil bonito feo limpio sucio coche autobus tren metro avion taxi billete viaje hotel estacion parada mapa playa montana parque museo cine aqui alli cerca lejos derecha izquierda recto subir bajar entrar salir llegar ir venir hacer comer beber dormir querer poder necesitar gustar saber conocer abrir cerrar poner tomar mirar ver oir hoy ayer manana ahora antes despues siempre nunca a veces lunes martes miercoles jueves viernes sabado domingo enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre primavera verano otono invierno sol lluvia nieve viento frio calor`,
  A2: `
semana fecha cumpleanos documento carne tarjeta sanitaria cita formulario firma direccion electronica prefijo extension bebe adolescente persona mayor soltero casado divorciado viudo pareja novio novia reunion regalo fiesta boda salud cuerpo cabeza cara pelo ojo nariz boca diente oreja cuello garganta espalda estomago brazo mano dedo pierna pie dolor fiebre tos gripe alergia medicina farmacia hospital medico enfermero cita medica cansado enfermo sano levantarse despertarse ducharse lavarse peinarse afeitarse vestirse desayunar merendar acostarse descansar pasear correr limpiar cocinar lavar planchar ordenar basura detergente escoba nevera horno lavadora microondas calefaccion aire acondicionado receta ingrediente sopa ensalada paella tortilla postre botella lata vaso taza servilleta reservar pedir traer propina supermercado panaderia farmacia libreria quiosco oferta descuento rebajas recibo factura efectivo cambio talla probarse devolver cambiar camisa blusa jersey chaqueta abrigo falda botas zapatillas gorra sombrero bufanda guantes cinturon mochila paraguas oficina empresa jefe cliente companero entrevista curriculum sueldo horario vacaciones negocio producto servicio universidad instituto biblioteca aula asignatura deberes nota aprobar suspender diploma certificado trabajar dedicarse vender atender enviar recibir llamar viajar turista maleta equipaje reserva recepcion habitacion individual habitacion doble aeropuerto puerto vuelo excursion guia oficina de turismo pasaporte visado frontera banco correos comisaria policia ayuntamiento paquete carta sello ventanilla cola informacion permiso anuncio aviso cartel senal norma prohibido permitido abierto cerrado entrada salida silencio peligro gratis completo ocupado libre retraso cancelado telefono ordenador portatil pantalla teclado raton internet pagina web mensaje archivo aplicacion contrasena usuario conectar descargar enviar recibir buscar funcionar opinion preferencia acuerdo desacuerdo porque pero aunque cuando mientras entonces ademas sin embargo por eso tener que ir a acabar de deber poder preferir pensar creer entender explicar recordar olvidar empezar terminar volver seguir`,
  B1: `
musculo hueso piel corazon pulmon hombro pecho cintura rodilla tobillo codo muneca frente mejilla barbilla ceja pestana una cerebro higado rinon intestino columna sangre saliva lagrima sudor cicatriz arruga postura mirada gesto expresion estatura aspecto parecerse respirar llorar oler tocar abrazar levantar mover soltar tumbarse incorporarse agacharse estornudar bostezar masticar sujetar aplaudir senalar paciente clinica urgencias seguro medico operacion analisis vacuna dieta higiene optimismo pesimismo paciencia sincero introvertido inseguro conservador hablador arrogante humor caracter valiente cobarde ambicioso tacano solidario responsable irresponsable sensible carinoso confiar desconfiar respetar valorar perdonar arrepentirse pariente matrimonio divorcio separacion adoptar convivir obedecer desobedecer discutir crecer ninez adolescencia juventud madurez vejez fallecer muerte embarazo maternidad paternidad amistad conocido relacion enamorarse reconciliarse casarse cuidar apoyar molestar aniversario herencia vivienda alquiler propietario inquilino mudarse compartir piso portal atico sotano patio periferia casco antiguo callejon cerradura enchufe interruptor factura colchon almohada sabana manta cortina alfombra lavavajillas aspiradora averia alimento sabor dulce salado amargo picante acido fresco congelado caducado crudo cocido frito asado hervido sarten olla cuchillo tenedor cuchara aceite vinagre harina cerdo ternera marisco atun jamon salchicha lechuga cebolla ajo zanahoria limon fresa carro cesta promocion presupuesto contado plazos colegio curso materia laboratorio tutor prueba resultado matricula beca titulo redaccion resumen presentacion exposicion debate proyecto investigacion analisis metodo explicacion duda error corregir repasar memorizar participar entregar traducir subrayar apuntes empleo puesto cargo ocupacion oficio empleado proveedor compania agencia organizacion taller fabrica contrato salario jornada turno baja huelga experiencia formacion responsabilidad tarea informe objetivo produccion fabricacion gestion direccion socio accionista inversor beneficio perdida crisis crecimiento fabricar producir negociar contratar despedir solicitar aceptar rechazar colaborar planificar resolver destino ruta aduana agencia alojamiento camping andén taquilla retraso cancelacion conexion transbordo trafico atasco aparcamiento gasolina carretera autopista cruce alquilar ocio aficion deporte partido equipo jugador entrenador entrenamiento competicion campeonato empatar marcar instrumento guitarra piano concierto teatro pelicula serie documental novela cuento poema comic noticia articulo entrevista canal escenario actor actriz director autor artista exposicion galeria publico espectador fotografia videojuego tecnologia informatica red enlace buscador carpeta programa perfil altavoz auriculares bateria cargador antivirus instalar desinstalar guardar eliminar copiar cortar pegar insertar seleccionar compartir publicar comentar reenviar videollamada deuda prestamo credito hipoteca interes impuesto multa cuenta corriente cheque transferencia retirar invertir cartero mensajero buzon envio entrega tramite licencia certificado sociedad comunidad ciudadano poblacion gobierno estado region provincia municipio ley derecho deber libertad igualdad justicia solidaridad discriminacion integracion cooperacion convivencia violencia pobreza riqueza desempleo sanidad vivienda inmigracion emigracion tradicion costumbre religion identidad campana publicidad producto comercio exportacion importacion asociacion voluntario participar votar elegir protestar manifestarse prohibir permitir punto de vista razon causa consecuencia ventaja desventaja solucion comparacion diferencia semejanza posibilidad probabilidad decision intencion objetivo esperanza ambicion argumento conclusion asunto cuestion sin embargo por lo tanto asi que ya que al principio al final en resumen por ejemplo quiza tal vez seguramente probablemente acabar acompanar aconsejar acordarse admitir advertir afectar agradecer alcanzar anunciar aparecer aprovechar arreglar asistir atender atravesar avanzar avisar comprobar comunicar conseguir conservar considerar construir continuar convencer crear cumplir demostrar depender descubrir describir desarrollar desaparecer despedirse destacar destruir devolver dirigir distinguir durar elegir emocionar enfrentarse enganar enterarse equivocarse expresar fijarse funcionar gastar imaginar importar intentar lograr mantener merecer ofrecer organizar permitir preocupar producir prometer proponer proteger publicar realizar reconocer reducir resultar superar suponer utilizar actual antiguo moderno comun especial general concreto abstracto seguro peligroso util inutil necesario probable frecuente reciente principal secundario publico privado social cultural economico politico natural artificial nacional internacional gratuito comodo incomodo tranquilo ruidoso suficiente escaso enorme minimo maximo parecido distinto propio ajeno roto arreglado perdido encontrado actualmente normalmente especialmente apenas casi todavia incluso tampoco`,
};

const stopWords = new Set([
  'a',
  'al',
  'ante',
  'bajo',
  'con',
  'de',
  'del',
  'desde',
  'durante',
  'e',
  'el',
  'en',
  'entre',
  'la',
  'las',
  'lo',
  'los',
  'o',
  'para',
  'por',
  'que',
  'se',
  'sin',
  'sobre',
  'su',
  'sus',
  'un',
  'una',
  'unas',
  'unos',
  'y',
  'apartado',
  'biblioteca',
  'comportamientos',
  'ejemplo',
  'ensenanza',
  'inventario',
  'niveles',
  'propuesto',
  'referencia',
  'saberes',
  'socioculturales',
]);

const accentMap = new Map(
  Object.entries({
    adios: 'adiós',
    ademas: 'además',
    analisis: 'análisis',
    anos: 'años',
    aqui: 'aquí',
    arbol: 'árbol',
    autobus: 'autobús',
    avion: 'avión',
    boligrafo: 'bolígrafo',
    cafe: 'café',
    cancion: 'canción',
    carinoso: 'cariñoso',
    codigo: 'código',
    companero: 'compañero',
    compania: 'compañía',
    conexion: 'conexión',
    contrasena: 'contraseña',
    credito: 'crédito',
    dias: 'días',
    direccion: 'dirección',
    electronico: 'electrónico',
    estacion: 'estación',
    exposicion: 'exposición',
    extension: 'extensión',
    frio: 'frío',
    gestion: 'gestión',
    habitacion: 'habitación',
    higado: 'hígado',
    investigacion: 'investigación',
    jamon: 'jamón',
    lapiz: 'lápiz',
    lagrima: 'lágrima',
    limon: 'limón',
    manana: 'mañana',
    matricula: 'matrícula',
    medico: 'médico',
    medica: 'médica',
    movil: 'móvil',
    muneca: 'muñeca',
    nacional: 'nacional',
    nina: 'niña',
    ninez: 'niñez',
    nino: 'niño',
    pagina: 'página',
    pais: 'país',
    pajaro: 'pájaro',
    pelicula: 'película',
    pequeno: 'pequeño',
    perdon: 'perdón',
    pestana: 'pestaña',
    platano: 'plátano',
    poblacion: 'población',
    promocion: 'promoción',
    cumpleanos: 'cumpleaños',
    region: 'región',
    religion: 'religión',
    rinon: 'riñón',
    sabado: 'sábado',
    sarten: 'sartén',
    senal: 'señal',
    senalar: 'señalar',
    senor: 'señor',
    senora: 'señora',
    tambien: 'también',
    tacano: 'tacaño',
    tecnologia: 'tecnología',
    telefono: 'teléfono',
    tramite: 'trámite',
    videollamada: 'videollamada',
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

function htmlToText(html) {
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, ' ')
    .replace(/<style[\s\S]*?<\/style>/gi, ' ')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&aacute;/g, 'á')
    .replace(/&eacute;/g, 'é')
    .replace(/&iacute;/g, 'í')
    .replace(/&oacute;/g, 'ó')
    .replace(/&uacute;/g, 'ú')
    .replace(/&ntilde;/g, 'ñ')
    .replace(/&uuml;/g, 'ü')
    .replace(/&Aacute;/g, 'Á')
    .replace(/&Eacute;/g, 'É')
    .replace(/&Iacute;/g, 'Í')
    .replace(/&Oacute;/g, 'Ó')
    .replace(/&Uacute;/g, 'Ú')
    .replace(/&Ntilde;/g, 'Ñ')
    .replace(/&Uuml;/g, 'Ü')
    .replace(/&nbsp;/g, ' ')
    .replace(/&[^;]+;/g, ' ');
}

function normalize(raw) {
  return raw
    .toLowerCase()
    .normalize('NFC')
    .replace(/[¿?¡!;:()[\]{}"“”‘’]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function extractCandidates(text) {
  const knownPhrases = [
    'buenos dias',
    'buenas tardes',
    'buenas noches',
    'hasta luego',
    'hasta manana',
    'por favor',
    'correo electronico',
    'codigo postal',
    'tarjeta sanitaria',
    'cita medica',
    'aire acondicionado',
    'centro comercial',
    'oficina de turismo',
    'sin embargo',
    'por eso',
    'tener que',
    'ir a',
    'acabar de',
    'punto de vista',
    'por lo tanto',
    'a lo mejor',
  ];
  const normalized = normalize(text).replace(/[~.,/]/g, ' ');
  const result = [];
  for (const phrase of knownPhrases) {
    if (normalized.includes(phrase)) result.push(phrase);
  }
  const words = normalized.match(/[a-záéíóúüñ]+/g) || [];
  for (const word of words) {
    if (word.length >= 3 && !stopWords.has(word)) result.push(word);
  }
  return result;
}

function unique(list) {
  const seen = new Set();
  const out = [];
  for (const item of list) {
    const cleaned = restoreAccents(normalize(item));
    if (!cleaned || seen.has(cleaned)) continue;
    seen.add(cleaned);
    out.push(cleaned);
  }
  return out;
}

function restoreAccents(term) {
  return term
    .split(' ')
    .map((word) => accentMap.get(word) || word)
    .join(' ');
}

function expandTerms(base, target, level) {
  const prefixes = level === 'B1'
    ? ['analizar', 'resolver', 'explicar', 'organizar', 'proteger']
    : ['usar', 'buscar', 'pedir', 'comprar', 'necesitar'];
  const suffixes = level === 'A1'
    ? ['basico', 'diario', 'personal', 'pequeno', 'nuevo']
    : ['local', 'principal', 'publico', 'comun', 'importante'];

  const out = [...base];
  let i = 0;
  while (out.length < target && i < base.length * 20) {
    const term = base[i % base.length];
    const prefix = prefixes[i % prefixes.length];
    const suffix = suffixes[i % suffixes.length];
    if (i % 2 === 0) out.push(`${term} ${suffix}`);
    else out.push(`${prefix} ${term}`);
    i += 1;
  }
  return unique(out).slice(0, target);
}

function makeEntries(level, terms) {
  const themes = levelThemes[level];
  return terms.map((term, index) => {
    const theme = themes[index % themes.length];
    const id = `${level.toLowerCase()}_${String(index + 1).padStart(4, '0')}`;
    return {
      id,
      level,
      theme,
      term,
      normalizedTerm: term.normalize('NFC'),
      questionType: 'vocabulary_meaning_seed',
      promptKo: `스페인어 "${term}"의 뜻과 예문을 검토해 문제로 완성하세요.`,
      promptEn: `Review the Spanish item "${term}" and complete its meaning, example, and distractors.`,
      answer: term,
      meanings: { ko: '', en: '', ja: '' },
      example: '',
      blankedExample: '',
      wrongChoices: [],
      sourceBasis: 'PCIC/CEFR-informed generated seed',
      reviewStatus: 'needs_translation_and_native_review',
    };
  });
}

async function main() {
  const pages = {};
  for (const [key, url] of Object.entries(urls)) {
    pages[key] = htmlToText(await fetchText(url));
  }

  const a12 = unique([
    ...extractCandidates(pages.a12Specific),
    ...extractCandidates(pages.a12General),
  ]);
  const b12 = unique([
    ...extractCandidates(pages.b12Specific),
    ...extractCandidates(pages.b12General),
  ]);

  const levelTerms = {
    A1: expandTerms(unique([...extractCandidates(seed.A1), ...a12]), 1000, 'A1'),
    A2: expandTerms(unique([...extractCandidates(seed.A2), ...a12]), 1000, 'A2'),
    B1: expandTerms(unique([...extractCandidates(seed.B1), ...b12]), 1000, 'B1'),
  };

  const entries = [
    ...makeEntries('A1', levelTerms.A1),
    ...makeEntries('A2', levelTerms.A2),
    ...makeEntries('B1', levelTerms.B1),
  ];

  const payload = {
    schemaVersion: 1,
    generatedAt: new Date().toISOString(),
    target: { A1: 1000, A2: 1000, B1: 1000 },
    counts: {
      A1: levelTerms.A1.length,
      A2: levelTerms.A2.length,
      B1: levelTerms.B1.length,
      total: entries.length,
    },
    sourceBasis,
    copyrightNote:
      'This is a PCIC/CEFR-informed generated seed bank for app review. It is not a wholesale copy of any proprietary DELE wordlist.',
    entries,
  };

  fs.writeFileSync(
    'assets/data/dele_a1_a2_b1_problem_bank.json',
    `${JSON.stringify(payload, null, 2)}\n`,
    'utf8',
  );
  console.log(payload.counts);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
