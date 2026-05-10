// ============================================================
// app_exceptions.dart
// Excepciones personalizadas de la capa de datos de GGSS.cl.
// ============================================================

/// El RUT ingresado ya existe en la tabla profiles.
class RutAlreadyExistsException implements Exception {
  const RutAlreadyExistsException();
}
