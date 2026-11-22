import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'services/local_library.dart';
import 'services/music_player.dart';
import 'ui/crimson_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const CrimsonApp());
}

class CrimsonApp extends StatefulWidget {
  const CrimsonApp({super.key});

  @override
  State<CrimsonApp> createState() => _CrimsonAppState();
}

class _CrimsonAppState extends State<CrimsonApp> {
  late final LocalLibrary library;
  late final MusicPlayer player;

  @override
  void initState() {
    super.initState();
    library = LocalLibrary();
    player = MusicPlayer();
    library.refresh();
  }

  @override
  void dispose() {
    library.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crimson Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDFDFD),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD51A32),
          surface: const Color(0xFFFDFDFD),
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFDFDFD),
          elevation: 0,
        ),
      ),
      home: CrimsonShell(library: library, player: player),
    );
  }
}
