import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crimson_player/ui/widgets/curved_nav.dart';

void main() {
  testWidgets('A barra oferece quatro destinos reais', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(builder: (context, update) {
          return Scaffold(
            body: SizedBox(
              width: 400,
              child: CurvedNav(
                index: selected,
                onChanged: (value) => update(() => selected = value),
              ),
            ),
          );
        }),
      ),
    );

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);
    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.text('Hotlist'), findsOneWidget);
    expect(find.text('Ajustes'), findsNothing);

    final before = tester.widget<Positioned>(find.byType(Positioned)).left!;
    await tester.tap(find.text('Biblioteca'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final during = tester.widget<Positioned>(find.byType(Positioned)).left!;
    await tester.pumpAndSettle();
    final after = tester.widget<Positioned>(find.byType(Positioned)).left!;

    expect(selected, 2);
    expect(during, greaterThan(before));
    expect(after, greaterThan(during));
  });
}
