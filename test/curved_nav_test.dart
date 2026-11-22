import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crimson_player/ui/widgets/curved_nav.dart';

void main() {
  testWidgets('A navegação apresenta cinco destinos e responde ao toque', (tester) async {
    int selected = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CurvedNav(index: selected, onChanged: (value) => selected = value),
      ),
    ));
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Buscar'), findsOneWidget);
    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.text('Playlists'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);

    await tester.tap(find.text('Buscar'));
    expect(selected, 1);
  });
}
