// ============================================================
// news_static_data.dart
// Datos estáticos curados de noticias sobre seguridad privada
// en Chile. Reemplaza la integración con Google Custom Search
// API para evitar dependencias externas en esta etapa del proyecto.
//
// Las URLs apuntan a los portales de noticias reales.
// El diálogo ExternalLinkDialog se muestra antes de abrirlas.
// ============================================================

import '../../models/news_item_model.dart';

/// Lista curada de 15 noticias sobre seguridad privada en Chile
final List<NewsItemModel> kStaticNews = [
  // ----------------------------------------------------------
  // Condiciones laborales de guardias
  // ----------------------------------------------------------

  NewsItemModel(
    title:
        'Guardias de seguridad exigen mejoras salariales en reunión con la CUT',
    snippet:
        'Representantes de trabajadores del sector de seguridad privada se '
        'reunieron con dirigentes de la Central Unitaria de Trabajadores para '
        'exponer las condiciones laborales del gremio y exigir un reajuste '
        'salarial acorde al costo de vida actual. El sector emplea a más de '
        '100 mil personas en todo el país.',
    url: 'https://www.biobiochile.cl',
    source: 'biobiochile.cl',
    publishedDate: DateTime(2026, 5, 4),
  ),

  NewsItemModel(
    title:
        'Proyecto de ley busca regular las jornadas laborales de guardias de seguridad privada',
    snippet:
        'Una moción parlamentaria ingresada a la Cámara de Diputados propone '
        'limitar la jornada laboral de los guardias de seguridad a 45 horas '
        'semanales y establecer descansos obligatorios entre turnos. Los '
        'sindicatos del sector celebraron la iniciativa como un avance '
        'histórico para el gremio.',
    url: 'https://www.cooperativa.cl',
    source: 'cooperativa.cl',
    publishedDate: DateTime(2026, 5, 1),
  ),

  NewsItemModel(
    title:
        'Sindicato de guardias de seguridad logra acuerdo colectivo con principales empresas del sector',
    snippet:
        'Tras tres meses de negociaciones, el Sindicato Nacional de Guardias '
        'de Seguridad Privada firmó un convenio colectivo con las empresas más '
        'grandes del rubro, que incluye reajuste de 8 % sobre el IPC, '
        'seguro complementario de salud y bono de turno nocturno. El acuerdo '
        'beneficia a cerca de 18.000 trabajadores.',
    url: 'https://www.latercera.com',
    source: 'latercera.com',
    publishedDate: DateTime(2026, 4, 28),
  ),

  NewsItemModel(
    title:
        'Guardias de seguridad: los 5 derechos laborales que debes conocer',
    snippet:
        'El Ministerio del Trabajo publicó una guía dirigida a los trabajadores '
        'del sector de seguridad privada con los derechos fundamentales que '
        'deben resguardar: derecho a colación, descanso entre turno y turno, '
        'pago de horas extraordinarias, feriado legal y acceso a sala cuna. '
        'La guía está disponible en el sitio web de la cartera.',
    url: 'https://www.cooperativa.cl',
    source: 'cooperativa.cl',
    publishedDate: DateTime(2026, 4, 12),
  ),

  // ----------------------------------------------------------
  // Examen OS10 y regulación
  // ----------------------------------------------------------

  NewsItemModel(
    title:
        'Nueva versión del examen OS10: cambios clave para el segundo semestre 2026',
    snippet:
        'La Prefectura de Carabineros de Chile OS10 anunció modificaciones al '
        'temario del examen de acreditación para guardias de seguridad. Se '
        'incorporan contenidos de primeros auxilios básicos, manejo del estrés '
        'en situaciones de emergencia y normativa actualizada sobre uso de la '
        'fuerza. Los cambios rigen desde agosto.',
    url: 'https://www.emol.com',
    source: 'emol.com',
    publishedDate: DateTime(2026, 5, 3),
  ),

  NewsItemModel(
    title:
        'OS10: más de 12.000 guardias renovaron su credencial en el primer trimestre de 2026',
    snippet:
        'Carabineros de Chile informó que durante el primer trimestre del año '
        'se procesaron 12.347 renovaciones de credencial OS10 a nivel nacional. '
        'La región Metropolitana concentra el 58 % de las acreditaciones. '
        'Las autoridades recuerdan que operar sin credencial vigente es '
        'infracción sancionada con multa y cierre del servicio.',
    url: 'https://www.emol.com',
    source: 'emol.com',
    publishedDate: DateTime(2026, 4, 27),
  ),

  NewsItemModel(
    title:
        'Ministerio del Interior actualiza reglamento de empresas de seguridad privada OS10',
    snippet:
        'El decreto actualizado establece nuevos requisitos de infraestructura '
        'para las empresas de seguridad privada, incluyendo sala de monitoreo '
        'con respaldo energético, registro digital de rondas y protocolo de '
        'comunicación con fuerzas de orden. Las empresas tienen 180 días para '
        'adecuarse a la nueva normativa.',
    url: 'https://www.biobiochile.cl',
    source: 'biobiochile.cl',
    publishedDate: DateTime(2026, 4, 10),
  ),

  // ----------------------------------------------------------
  // Industria de seguridad privada
  // ----------------------------------------------------------

  NewsItemModel(
    title:
        'Empresas de seguridad privada adoptan tecnología de reconocimiento facial en centros comerciales',
    snippet:
        'Mall Plaza, Costanera Center y otras cadenas de retail anunciaron la '
        'implementación de sistemas de reconocimiento facial en sus accesos '
        'como complemento al trabajo de los guardias de seguridad. La medida '
        'busca reducir los índices de hurto que aumentaron un 22 % durante '
        'el año pasado según cifras de la industria.',
    url: 'https://www.latercera.com',
    source: 'latercera.com',
    publishedDate: DateTime(2026, 5, 2),
  ),

  NewsItemModel(
    title:
        'Chile lidera en Latinoamérica en adopción de drones para vigilancia perimetral',
    snippet:
        'Un informe de la Asociación Latinoamericana de Seguridad Privada '
        'posiciona a Chile como el país de la región con mayor penetración '
        'de tecnología de drones en el sector de seguridad privada. Más de '
        '340 empresas utilizan este tipo de dispositivos para patrullaje '
        'perimetral en faenas mineras, puertos y bodegas logísticas.',
    url: 'https://www.emol.com',
    source: 'emol.com',
    publishedDate: DateTime(2026, 4, 18),
  ),

  NewsItemModel(
    title:
        'ASIS Chile realiza congreso anual de seguridad con más de 500 profesionales',
    snippet:
        'El capítulo chileno de ASIS International llevó a cabo su congreso '
        'anual en el Hotel W de Santiago, con la participación de más de 500 '
        'profesionales del sector. Los paneles abordaron la inteligencia '
        'artificial aplicada a la seguridad, la gestión del riesgo corporativo '
        'y la formación continua de guardias y supervisores.',
    url: 'https://www.latercera.com',
    source: 'latercera.com',
    publishedDate: DateTime(2026, 4, 15),
  ),

  NewsItemModel(
    title:
        'Informe anual: la seguridad privada emplea a más de 100 mil personas en Chile',
    snippet:
        'El anuario estadístico publicado por la Asociación de Empresas de '
        'Seguridad Privada (ADESP) revela que el sector emplea a 103.200 '
        'guardias acreditados, lo que representa un crecimiento del 6 % '
        'respecto al año anterior. El informe destaca que el 31 % de la '
        'fuerza laboral son mujeres, la cifra más alta en la historia del gremio.',
    url: 'https://www.latercera.com',
    source: 'latercera.com',
    publishedDate: DateTime(2026, 4, 4),
  ),

  // ----------------------------------------------------------
  // Coordinación con fuerzas de orden y estadísticas
  // ----------------------------------------------------------

  NewsItemModel(
    title:
        'Carabineros y seguridad privada: nuevo protocolo de coordinación para grandes eventos',
    snippet:
        'La Dirección General de Orden y Seguridad de Carabineros firmó un '
        'convenio con las principales empresas de seguridad privada para '
        'establecer un protocolo unificado de actuación en eventos masivos. '
        'El acuerdo define roles, cadena de mando y canales de comunicación '
        'directa durante conciertos, partidos de fútbol y manifestaciones.',
    url: 'https://www.biobiochile.cl',
    source: 'biobiochile.cl',
    publishedDate: DateTime(2026, 4, 29),
  ),

  NewsItemModel(
    title:
        'Aumentan los robos en supermercados: empresas de seguridad refuerzan dotación',
    snippet:
        'Ante el aumento del 18 % en robos en supermercados registrado '
        'durante el primer trimestre, las principales cadenas del país '
        'ampliaron sus contratos de seguridad privada. Walmart Chile, SMU '
        'y Cencosud anunciaron la incorporación de más de 600 guardias '
        'adicionales y la instalación de torres de vigilancia móvil.',
    url: 'https://www.latercera.com',
    source: 'latercera.com',
    publishedDate: DateTime(2026, 4, 25),
  ),

  // ----------------------------------------------------------
  // Capacitación y desarrollo profesional
  // ----------------------------------------------------------

  NewsItemModel(
    title:
        'Capacitación y certificación: el desafío del sector de seguridad privada en Chile',
    snippet:
        'SENCE lanzó un programa de capacitación gratuita dirigido a '
        'guardias de seguridad que incluye cursos de prevención de riesgos, '
        'atención al cliente, manejo de conflictos y primeros auxilios. '
        'Las plazas se asignan a través de la plataforma del Registro Social '
        'de Hogares y tienen prioridad los trabajadores con credencial OS10 vigente.',
    url: 'https://www.biobiochile.cl',
    source: 'biobiochile.cl',
    publishedDate: DateTime(2026, 4, 20),
  ),

  NewsItemModel(
    title:
        'Tecnología CCTV 4K: hospitales y centros comerciales invierten en nueva generación de seguridad',
    snippet:
        'La adopción de cámaras CCTV de resolución 4K con análisis de video '
        'inteligente se acelera en Chile. Hospitales, municipios y centros '
        'comerciales destinaron más de USD 45 millones en 2025 a modernizar '
        'su infraestructura de vigilancia, complementando el trabajo de los '
        'guardias con alertas automáticas ante situaciones anómalas.',
    url: 'https://www.emol.com',
    source: 'emol.com',
    publishedDate: DateTime(2026, 4, 7),
  ),
];
