// ============================================================
// chile_locations.dart
// Mapa estático de las 16 regiones de Chile y sus comunas.
// Fuente: SUBDERE — División Político-Administrativa oficial.
// Orden: numeración oficial de regiones (I a XVI).
// ============================================================

/// Mapa con las 16 regiones de Chile y sus comunas oficiales.
/// Clave: nombre oficial de la región.
/// Valor: lista de comunas en orden alfabético.
const Map<String, List<String>> chileLocations = {
  // ----------------------------------------------------------
  // Región XV — Arica y Parinacota
  // ----------------------------------------------------------
  'Región de Arica y Parinacota': [
    'Arica',
    'Camarones',
    'General Lagos',
    'Putre',
  ],

  // ----------------------------------------------------------
  // Región I — Tarapacá
  // ----------------------------------------------------------
  'Región de Tarapacá': [
    'Alto Hospicio',
    'Camiña',
    'Colchane',
    'Huara',
    'Iquique',
    'Pica',
    'Pozo Almonte',
  ],

  // ----------------------------------------------------------
  // Región II — Antofagasta
  // ----------------------------------------------------------
  'Región de Antofagasta': [
    'Antofagasta',
    'Calama',
    'María Elena',
    'Mejillones',
    'Ollagüe',
    'San Pedro de Atacama',
    'Sierra Gorda',
    'Taltal',
    'Tocopilla',
  ],

  // ----------------------------------------------------------
  // Región III — Atacama
  // ----------------------------------------------------------
  'Región de Atacama': [
    'Alto del Carmen',
    'Caldera',
    'Chañaral',
    'Copiapó',
    'Diego de Almagro',
    'Freirina',
    'Huasco',
    'Tierra Amarilla',
    'Vallenar',
  ],

  // ----------------------------------------------------------
  // Región IV — Coquimbo
  // ----------------------------------------------------------
  'Región de Coquimbo': [
    'Andacollo',
    'Canela',
    'Combarbalá',
    'Coquimbo',
    'Illapel',
    'La Higuera',
    'La Serena',
    'Los Vilos',
    'Monte Patria',
    'Ovalle',
    'Paiguano',
    'Punitaqui',
    'Río Hurtado',
    'Salamanca',
    'Vicuña',
  ],

  // ----------------------------------------------------------
  // Región V — Valparaíso
  // ----------------------------------------------------------
  'Región de Valparaíso': [
    'Algarrobo',
    'Cabildo',
    'Calera',
    'Cartagena',
    'Casablanca',
    'Catemu',
    'Concón',
    'El Quisco',
    'El Tabo',
    'Hijuelas',
    'Isla de Pascua',
    'Juan Fernández',
    'La Cruz',
    'La Ligua',
    'Limache',
    'Llaillay',
    'Los Andes',
    'Nogales',
    'Olmué',
    'Panquehue',
    'Papudo',
    'Petorca',
    'Puchuncaví',
    'Putaendo',
    'Quilpué',
    'Quillota',
    'Quintero',
    'Rinconada',
    'San Antonio',
    'San Esteban',
    'San Felipe',
    'Santa María',
    'Santo Domingo',
    'Valparaíso',
    'Villa Alemana',
    'Viña del Mar',
    'Zapallar',
    'Calle Larga',
  ],

  // ----------------------------------------------------------
  // Región XIII — Metropolitana de Santiago
  // ----------------------------------------------------------
  'Región Metropolitana de Santiago': [
    'Alhué',
    'Buin',
    'Calera de Tango',
    'Cerrillos',
    'Cerro Navia',
    'Colina',
    'Conchalí',
    'Curacaví',
    'El Bosque',
    'El Monte',
    'Estación Central',
    'Huechuraba',
    'Independencia',
    'Isla de Maipo',
    'La Cisterna',
    'La Florida',
    'La Granja',
    'La Pintana',
    'La Reina',
    'Lampa',
    'Las Condes',
    'Lo Barnechea',
    'Lo Espejo',
    'Lo Prado',
    'Macul',
    'Maipú',
    'María Pinto',
    'Melipilla',
    'Ñuñoa',
    'Padre Hurtado',
    'Paine',
    'Pedro Aguirre Cerda',
    'Peñaflor',
    'Peñalolén',
    'Pirque',
    'Providencia',
    'Pudahuel',
    'Puente Alto',
    'Quilicura',
    'Quinta Normal',
    'Recoleta',
    'Renca',
    'San Bernardo',
    'San Joaquín',
    'San José de Maipo',
    'San Miguel',
    'San Ramón',
    'Santiago',
    'Talagante',
    'Tiltil',
    'Vitacura',
  ],

  // ----------------------------------------------------------
  // Región VI — O'Higgins (Libertador General Bernardo O'Higgins)
  // ----------------------------------------------------------
  "Región del Libertador General Bernardo O'Higgins": [
    'Chépica',
    'Chimbarongo',
    'Codegua',
    'Coinco',
    'Coltauco',
    'Doñihue',
    'Graneros',
    'La Estrella',
    'Las Cabras',
    'Litueche',
    'Lolol',
    'Machalí',
    'Malloa',
    'Marchihue',
    'Mostazal',
    'Nancagua',
    'Navidad',
    'Olivar',
    'Palmilla',
    'Paredones',
    'Peralillo',
    'Peumo',
    'Pichidegua',
    'Pichilemu',
    'Placilla',
    'Pumanque',
    'Quinta de Tilcoco',
    'Rancagua',
    'Rengo',
    'Requínoa',
    'San Fernando',
    'San Vicente',
    'Santa Cruz',
  ],

  // ----------------------------------------------------------
  // Región VII — Maule
  // ----------------------------------------------------------
  'Región del Maule': [
    'Cauquenes',
    'Chanco',
    'Colbún',
    'Constitución',
    'Curicó',
    'Empedrado',
    'Hualañé',
    'Licantén',
    'Linares',
    'Longaví',
    'Maule',
    'Molina',
    'Parral',
    'Pelarco',
    'Pelluhue',
    'Pencahue',
    'Rauco',
    'Retiro',
    'Río Claro',
    'Romeral',
    'Sagrada Familia',
    'San Clemente',
    'San Javier',
    'San Rafael',
    'Talca',
    'Teno',
    'Vichuquén',
    'Villa Alegre',
    'Yerbas Buenas',
  ],

  // ----------------------------------------------------------
  // Región XVI — Ñuble
  // ----------------------------------------------------------
  'Región del Ñuble': [
    'Bulnes',
    'Chillán',
    'Chillán Viejo',
    'Cobquecura',
    'Coelemu',
    'Coihueco',
    'El Carmen',
    'Ninhue',
    'Ñiquén',
    'Pemuco',
    'Pinto',
    'Portezuelo',
    'Quillón',
    'Quirihue',
    'Ránquil',
    'San Carlos',
    'San Fabián',
    'San Ignacio',
    'San Nicolás',
    'Treguaco',
    'Yungay',
  ],

  // ----------------------------------------------------------
  // Región VIII — Biobío
  // ----------------------------------------------------------
  'Región del Biobío': [
    'Alto Biobío',
    'Antuco',
    'Arauco',
    'Cabrero',
    'Cañete',
    'Concepción',
    'Contulmo',
    'Coronel',
    'Curanilahue',
    'Chiguayante',
    'Florida',
    'Hualpén',
    'Hualqui',
    'Laja',
    'Lebu',
    'Los Álamos',
    'Los Ángeles',
    'Lota',
    'Mulchén',
    'Nacimiento',
    'Negrete',
    'Penco',
    'Quilaco',
    'Quilleco',
    'San Pedro de la Paz',
    'San Rosendo',
    'Santa Bárbara',
    'Santa Juana',
    'Talcahuano',
    'Tirúa',
    'Tomé',
    'Tucapel',
    'Yumbel',
  ],

  // ----------------------------------------------------------
  // Región IX — La Araucanía
  // ----------------------------------------------------------
  'Región de La Araucanía': [
    'Angol',
    'Carahue',
    'Cholchol',
    'Collipulli',
    'Cunco',
    'Curacautín',
    'Curarrehue',
    'Ercilla',
    'Freire',
    'Galvarino',
    'Gorbea',
    'Lautaro',
    'Loncoche',
    'Lonquimay',
    'Los Sauces',
    'Lumaco',
    'Melipeuco',
    'Nueva Imperial',
    'Padre las Casas',
    'Perquenco',
    'Pitrufquén',
    'Pucón',
    'Purén',
    'Renaico',
    'Saavedra',
    'Temuco',
    'Teodoro Schmidt',
    'Toltén',
    'Traiguén',
    'Victoria',
    'Vilcún',
    'Villarrica',
  ],

  // ----------------------------------------------------------
  // Región XIV — Los Ríos
  // ----------------------------------------------------------
  'Región de Los Ríos': [
    'Corral',
    'Futrono',
    'La Unión',
    'Lago Ranco',
    'Lanco',
    'Los Lagos',
    'Máfil',
    'Mariquina',
    'Paillaco',
    'Panguipulli',
    'Río Bueno',
    'Valdivia',
  ],

  // ----------------------------------------------------------
  // Región X — Los Lagos
  // ----------------------------------------------------------
  'Región de Los Lagos': [
    'Ancud',
    'Calbuco',
    'Castro',
    'Chaitén',
    'Chonchi',
    'Cochamó',
    'Curaco de Vélez',
    'Dalcahue',
    'Fresia',
    'Frutillar',
    'Futaleufú',
    'Hualaihué',
    'Isla de Maipo',
    'Llanquihue',
    'Los Muermos',
    'Maullín',
    'Osorno',
    'Palena',
    'Puerto Montt',
    'Puerto Octay',
    'Puerto Varas',
    'Puqueldón',
    'Purranque',
    'Puyehue',
    'Queilén',
    'Quellón',
    'Quemchi',
    'Quinchao',
    'Río Negro',
    'San Juan de la Costa',
    'San Pablo',
  ],

  // ----------------------------------------------------------
  // Región XI — Aysén
  // ----------------------------------------------------------
  'Región de Aysén del General Carlos Ibáñez del Campo': [
    'Aysén',
    'Chile Chico',
    'Cisnes',
    'Cochrane',
    'Coihaique',
    'Guaitecas',
    'Lago Verde',
    "O'Higgins",
    'Río Ibáñez',
    'Tortel',
  ],

  // ----------------------------------------------------------
  // Región XII — Magallanes
  // ----------------------------------------------------------
  'Región de Magallanes y de la Antártica Chilena': [
    'Antártica',
    'Cabo de Hornos',
    'Laguna Blanca',
    'Porvenir',
    'Primavera',
    'Puerto Natales',
    'Punta Arenas',
    'Río Verde',
    'San Gregorio',
    'Timaukel',
    'Torres del Paine',
  ],
};
