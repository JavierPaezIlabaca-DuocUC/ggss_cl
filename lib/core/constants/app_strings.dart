// ============================================================
// app_strings.dart
// Todos los textos visibles al usuario en español (Chile).
// Centralizar aquí facilita futuras traducciones (i18n).
//
// PUNTO DE EXTENSIÓN i18n: cuando se implemente soporte
// multiidioma, reemplazar este archivo por AppLocalizations
// generado por flutter_gen / arb files. La estructura de clases
// se mantiene igual para facilitar la migración.
// ============================================================

/// Cadenas de texto de la interfaz de GGSS.cl en español (Chile)
class AppStrings {
  // Constructor privado: esta clase no debe instanciarse
  AppStrings._();

  // ----------------------------------------------------------
  // Nombre de la app
  // ----------------------------------------------------------
  static const String appName = 'GGSS.cl';
  static const String appTagline = 'Plataforma para guardias de seguridad';

  // ----------------------------------------------------------
  // Navegación principal (barra inferior)
  // ----------------------------------------------------------
  static const String navJobs = 'Ofertas';
  static const String navAcademic = 'Academia';
  static const String navOs10 = 'OS10';
  static const String navNews = 'Noticias';
  static const String navForum = 'Foro';

  // ----------------------------------------------------------
  // Títulos de secciones
  // ----------------------------------------------------------
  static const String titleJobs = 'Ofertas Laborales';
  static const String titleAcademic = 'Ofertas Académicas';
  static const String titleOs10 = 'Simulador OS10';
  static const String titleNews = 'Noticias';
  static const String titleForum = 'Foro Comunitario';
  static const String titleProfile = 'Mi Perfil';
  static const String titleSettings = 'Configuración';
  static const String titleSearch = 'Buscar';

  // ----------------------------------------------------------
  // Autenticación
  // ----------------------------------------------------------
  static const String authLogin = 'Iniciar sesión';
  static const String authRegister = 'Crear cuenta';
  static const String authLogout = 'Cerrar sesión';
  static const String authForgotPassword = '¿Olvidaste tu contraseña?';
  static const String authRecoverPassword = 'Recuperar contraseña';
  static const String authEmail = 'Correo electrónico';
  static const String authPassword = 'Contraseña';
  static const String authConfirmPassword = 'Confirmar contraseña';
  static const String authFullName = 'Nombre completo';
  static const String authNoAccount = '¿No tienes cuenta? ';
  static const String authHasAccount = '¿Ya tienes cuenta? ';
  static const String authPasswordHint = 'Ingresa tu contraseña';
  static const String authEmailHint = 'ejemplo@correo.cl';
  static const String authRecoveryEmailSent =
      'Revisa tu correo para recuperar tu contraseña.';

  // Campos de registro
  static const String authRut = 'RUT';
  static const String authRutHint = '12.345.678-9';
  static const String authRutHelper = 'Ingresa tu RUT con puntos y guión';
  static const String authFullNameHint = 'Ej: Juan Pérez González';
  static const String authConfirmPasswordHint = 'Repite tu contraseña';
  static const String authRegisterTitle = 'Crear cuenta en GGSS.cl';
  static const String authLoginTitle = 'Bienvenido a GGSS.cl';
  static const String authLoginSubtitle = 'Inicia sesión para continuar';
  static const String authRegisterSubtitle =
      'Regístrate para acceder a todas las funciones';
  static const String authForgotPasswordTitle = 'Recuperar contraseña';
  static const String authForgotPasswordSubtitle =
      'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.';
  static const String authRecoverySuccessTitle = '¡Correo enviado!';
  static const String authRecoverySuccessBody =
      'Revisa tu bandeja de entrada y sigue el enlace para crear una nueva contraseña. '
      'Si no lo encuentras, revisa la carpeta de spam.';
  static const String authBackToLogin = 'Volver al inicio de sesión';

  // Verificación de correo electrónico
  static const String emailVerifTitle = 'Verifica tu correo electrónico';
  static const String emailVerifSubtitlePre = 'Te enviamos un correo a ';
  static const String emailVerifSubtitlePost =
      '. Abre el enlace para activar tu cuenta y acceder a GGSS.cl.';
  static const String emailVerifResend = 'Reenviar correo de verificación';
  static const String emailVerifAlreadyDone = 'Ya verifiqué mi correo';
  static const String emailVerifResendSuccess =
      'Correo reenviado. Revisa tu bandeja de entrada.';
  static const String emailVerifNotYet =
      'Tu correo aún no ha sido verificado. Revisa tu bandeja de entrada.';
  static const String emailVerifResendError =
      'No se pudo reenviar el correo. Intenta nuevamente.';
  static const String emailVerifCheckError =
      'Error al verificar. Intenta nuevamente.';

  // Mensajes de error de autenticación (traducidos del inglés de Supabase)
  static const String authErrorInvalidCredentials =
      'Correo o contraseña incorrectos.';
  static const String authErrorEmailAlreadyRegistered =
      'Este correo ya está registrado. Intenta iniciar sesión.';
  static const String authErrorEmailNotConfirmed =
      'Debes confirmar tu correo antes de iniciar sesión.';
  static const String authErrorWeakPassword =
      'La contraseña es muy débil. Usa al menos 6 caracteres.';
  static const String authErrorTooManyRequests =
      'Demasiados intentos. Espera unos minutos antes de reintentar.';

  // ----------------------------------------------------------
  // Búsqueda
  // ----------------------------------------------------------
  static const String searchHint = 'Buscar en GGSS.cl...';
  static const String searchAdvanced = 'Búsqueda avanzada';
  static const String searchNoResults = 'Sin resultados para esta búsqueda.';
  static const String searchMinChars = 'Ingresa al menos 3 caracteres para buscar.';
  static const String searchFilterJobs = 'Ofertas laborales';
  static const String searchFilterAcademic = 'Ofertas académicas';
  static const String searchFilterNews = 'Noticias';
  static const String searchFilterForum = 'Foro';
  static const String searchFilterToday = 'Hoy';
  static const String searchFilterThisWeek = 'Esta semana';
  static const String searchFilterThisMonth = 'Este mes';
  static const String searchFilterThisYear = 'Este año';
  static const String searchFilterAllTime = 'Todo el período';
  static const String searchFilterCustomRange = 'Rango personalizado';
  static const String searchFilterSections = 'Secciones a buscar';
  static const String searchFilterPeriod = 'Período de tiempo';
  static const String searchFilterDateFrom = 'Desde';
  static const String searchFilterDateTo = 'Hasta';
  static const String searchApplyFilters = 'Aplicar filtros';
  static const String searchError = 'Ocurrió un error al buscar. Intenta nuevamente.';

  // ----------------------------------------------------------
  // Diálogo de enlace externo
  // ----------------------------------------------------------
  static const String externalLinkTitle = 'Enlace externo';
  static const String externalLinkMessage =
      'GGSS.cl no se hace responsable de los enlaces externos '
      'ni de lo que pueda ocurrir fuera de la app.';
  static const String externalLinkContinue = 'Continuar';
  static const String externalLinkDontShowAgain = 'No volver a mostrar';

  // ----------------------------------------------------------
  // Acciones generales
  // ----------------------------------------------------------
  static const String actionCreate = 'Crear';
  static const String actionEdit = 'Editar';
  static const String actionDelete = 'Eliminar';
  static const String actionSave = 'Guardar';
  static const String actionCancel = 'Cancelar';
  static const String actionConfirm = 'Confirmar';
  static const String actionBack = 'Volver';
  static const String actionClose = 'Cerrar';
  static const String actionSend = 'Enviar';
  static const String actionShare = 'Compartir';
  static const String actionReport = 'Reportar';

  // ----------------------------------------------------------
  // Estados de carga y error
  // ----------------------------------------------------------
  static const String loadingGeneral = 'Cargando...';
  static const String errorGeneral = 'Ocurrió un error. Intenta nuevamente.';
  static const String errorNetwork =
      'Sin conexión. Verifica tu red e intenta nuevamente.';
  static const String errorNotFound = 'No encontrado.';
  static const String emptyStateGeneral = 'No hay contenido aún.';

  // ----------------------------------------------------------
  // Configuración
  // ----------------------------------------------------------
  static const String settingsTheme = 'Tema de la aplicación';
  static const String settingsAppearance = 'Apariencia';
  static const String settingsThemeLight = 'Modo claro';
  static const String settingsThemeDark = 'Modo oscuro';
  static const String settingsDefaultSection = 'Sección de inicio';
  static const String settingsSaved = 'Configuración guardada.';
  static const String settingsAbout = 'Acerca de';
  static const String settingsVersion = 'GGSS.cl v1.0.0';
  static const String settingsDescription =
      'Plataforma digital para guardias de seguridad privada en Chile';

  // ----------------------------------------------------------
  // Ofertas laborales
  // ----------------------------------------------------------
  static const String jobsCreateNew = 'Nueva oferta laboral';
  static const String jobsNoOffers = 'No hay ofertas laborales disponibles.';
  static const String jobsContactWhatsApp = 'Contactar por WhatsApp';
  static const String jobsViewMap = 'Ver en mapa';

  // ----------------------------------------------------------
  // Ofertas académicas
  // ----------------------------------------------------------
  static const String academicCreateNew = 'Nueva oferta académica';
  static const String academicNoOffers = 'No hay cursos disponibles.';

  // ----------------------------------------------------------
  // Simulador OS10
  // ----------------------------------------------------------
  static const String os10Start = 'Iniciar simulacro';
  static const String os10Question = 'Pregunta';
  static const String os10Of = 'de';
  static const String os10Results = 'Resultados del simulacro';
  static const String os10Correct = 'Respuestas correctas';
  static const String os10Incorrect = 'Respuestas incorrectas';
  static const String os10Retry = 'Volver a intentar';
  static const String os10NoQuestions =
      'No hay preguntas disponibles en este momento.';

  // ----------------------------------------------------------
  // Noticias
  // ----------------------------------------------------------
  static const String newsNoResults = 'No se encontraron noticias.';
  static const String newsReadMore = 'Leer más';
  static const String newsReadFullArticle = 'Leer artículo completo';
  static const String newsSource = 'Fuente';

  // ----------------------------------------------------------
  // Perfil de usuario
  // ----------------------------------------------------------
  static const String profileEdit = 'Editar perfil';
  static const String profileLogout = 'Cerrar sesión';
  static const String profileLogoutConfirmTitle = 'Cerrar sesión';
  static const String profileLogoutConfirmBody =
      '¿Estás seguro de que deseas cerrar sesión?';
  static const String profileFullName = 'Nombre completo';
  static const String profileRut = 'RUT';
  static const String profileEmail = 'Correo electrónico';
  static const String profileStats = 'Mis publicaciones';
  static const String profileJobsPosted = 'Ofertas\nlaborales';
  static const String profileAcademicPosted = 'Ofertas\nacadémicas';
  static const String profileForumPosts = 'Posts\nen el foro';
  static const String profileUpdateSuccess =
      'Perfil actualizado correctamente.';
  static const String profileUpdateError =
      'No se pudo actualizar el perfil. Intenta nuevamente.';
  static const String profileFullNameHint = 'Ej: Juan Pérez González';
  static const String profileFullNameRequired = 'El nombre es requerido.';

  // ----------------------------------------------------------
  // Foro
  // ----------------------------------------------------------
  static const String forumCreatePost = 'Nueva publicación';
  static const String forumNoPosts = 'Aún no hay publicaciones en el foro.';
  static const String forumComment = 'Comentar';
  static const String forumComments = 'Comentarios';
  static const String forumNoComments = 'Sé el primero en comentar.';
  static const String forumReply = 'Responder';
  static const String forumAnonymous = 'Usuario';
  static const String forumTitleLabel = 'Título';
  static const String forumTitleHint = 'Título de la publicación';
  static const String forumContentLabel = 'Contenido';
  static const String forumContentHint = 'Escribe tu publicación aquí...';
  static const String forumCategoryLabel = 'Categoría (opcional)';
  static const String forumCategoryHint = 'Ej: Laboral, Consulta, Experiencia...';
  static const String forumPublish = 'Publicar';
  static const String forumCommentHint = 'Escribe un comentario...';
  static const String forumDeletePost = 'Eliminar publicación';
  static const String forumDeletePostConfirm =
      '¿Estás seguro de que deseas eliminar esta publicación? '
      'Esta acción no se puede deshacer.';
  static const String forumDeleteComment = 'Eliminar comentario';
  static const String forumDeleteCommentConfirm =
      '¿Estás seguro de que deseas eliminar este comentario? '
      'Esta acción no se puede deshacer.';
}
