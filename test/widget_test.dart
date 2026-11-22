import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crimson_player/ui/widgets/album_art.dart';

void main() {
  testWidgets('Sem capa de música não inventa arte de álbum', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 180, height: 180, child: AlbumArt()),
        ),
      ),
    ));
    expect(find.byType(AlbumArt), findsOneWidget);
    expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
    expect(find.byType(AlbumArt), findsOneWidget);
  });
}
