import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/local_library.dart';
import 'services/music_player.dart';
import 'ui/app_theme.dart';
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
  ThemeMode _mode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    library = LocalLibrary();
    player = MusicPlayer();
    unawaited(_loadTheme());
    unawaited(library.refresh());
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final saved = prefs.getString('appearance') ?? 'light';
    setState(() => _mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    });
  }

  Future<void> _changeTheme(ThemeMode mode) async {
    setState(() => _mode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appearance', mode.name);
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
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _mode,
      home: CrimsonShell(
        library: library,
        player: player,
        appearance: _mode,
        onAppearanceChanged: _changeTheme,
      ),
    );
  }
}
