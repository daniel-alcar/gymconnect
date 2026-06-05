import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymconnect/widgets/app_logo.dart';

void main() {
  testWidgets('AppLogo e AppLogoMark renderizam as imagens da marca',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(children: [AppLogo(), AppLogoMark()]),
        ),
      ),
    );

    // Ambos exibem a logo oficial via Image.asset.
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.byType(AppLogoMark), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(2));
  });
}
