// ============================================================
// route_observer.dart
// RouteObserver global para detectar navegación entre pantallas.
//
// Registrado en MaterialApp.navigatorObservers para que cualquier
// pantalla pueda suscribirse y reaccionar cuando el usuario regresa
// a ella desde otra pantalla (didPopNext).
// ============================================================

import 'package:flutter/material.dart';

/// Observer global de rutas. Registrado en MaterialApp.navigatorObservers.
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
