import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crimson_player/ui/widgets/album_art.dart';

void main() {
  testWidgets('A capa alternativa é renderizada sem arquivos de áudio', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 180, height: 180, child: AlbumArt()),
        ),
      ),
    ));
    expect(find.byType(AlbumArt), findsOneWidget);
  });
}
