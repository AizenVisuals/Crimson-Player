# Crimson Player

Player de música multiplataforma **em desenvolvimento**. O nome é provisório.

## Objetivo atual: Android primeiro

- Interface minimalista clara baseada nas referências aprovadas, com navegação flutuante grafite e animação carmesim.
- Início, Busca, Biblioteca, Favoritos/Fila e Ajustes.
- Tela **Now Playing** com capa, barra de progresso em forma de onda, controles, fila e mini-player persistente.
- Pesquisa de músicas locais com permissão de áudio no Android.
- Reprodução local via Media Kit.
- Reprodução HTTPS de áudio/streams diretos autorizados, informando a URL.
- Favoritos salvos no dispositivo.

**Ainda não implementados:** catálogo online por artista (Audius/Jamendo etc.), login, playlists editáveis/sincronizadas, downloads, notificações/controles lockscreen, exibição real do waveform extraído do áudio, interface de desktop.

## Tecnologias

- Flutter / Dart
- media_kit e media_kit_libs_audio
- on_audio_query (MediaStore Android)
- shared_preferences (favoritos)

## Executar

Requer Flutter e Android SDK instalados.

```bash
git clone https://github.com/AizenVisuals/Crimson-Player.git
cd Crimson-Player
flutter create --platforms=android --org com.aizenvisuals .
flutter pub get
flutter run
```

O AndroidManifest já define INTERNET, READ_MEDIA_AUDIO e READ_EXTERNAL_STORAGE até API 32. A permissão é solicitada durante a leitura da biblioteca.

Para gerar APKs:

```bash
flutter build apk --split-per-abi
```

O workflow **Android Build** do GitHub Actions prepara automaticamente os arquivos Android gerados pelo Flutter durante o build e publica o APK como artefato quando a compilação passa.

## Nota sobre as fontes online

O player não integra Spotify nem burla acesso a conteúdo protegido. No MVP, apenas links diretos HTTPS autorizados são reproduzidos. Catálogos que oferecem API/licenças compatíveis serão avaliados posteriormente.

## Arquitetura

```
lib/
  main.dart                  # bootstrap e tema
  models/music_track.dart    # modelo unificado
  services/local_library.dart # MediaStore / permissões
  services/music_player.dart  # engine, fila, favoritos
  ui/
    crimson_shell.dart       # navegação e mini-player
    library_pages.dart       # início, busca, biblioteca, álbum...
    now_playing_page.dart
    widgets/                 # assets de UI em Flutter
```

Design: fundo branco e tipografia escura, capa grande, contornos arredondados e detalhes carmesim. A versão desktop fica para a próxima fase.
