// ============================================================
// widget_test.dart
// Test básico de humo para verificar que la app carga sin errores.
// Se ampliarán los tests por módulo en iteraciones posteriores.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:ggss_cl/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('La app carga sin errores de compilación', (WidgetTester tester) async {
    // Verifica que el widget raíz GgssApp se construye sin excepciones
    await tester.pumpWidget(
      const ProviderScope(child: GgssApp()),
    );

    // La app debe mostrar algún contenido
    expect(find.byType(GgssApp), findsOneWidget);
  });
}
