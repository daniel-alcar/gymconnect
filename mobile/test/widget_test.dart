import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymconnect/widgets/app_logo.dart';

void main() {
  testWidgets('AppLogo renderiza o ícone e o nome do app', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppLogo())),
    );

    // Logo presente com o ícone de halter.
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);

    // O nome "GymConnect" é renderizado via Text.rich (RichText).
    final textos = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((rt) => rt.text.toPlainText())
        .toList();
    expect(textos.any((t) => t.contains('GymConnect')), isTrue);
  });
}
