# Crimson Player

Reprodutor de músicas Android e desktop (desktop planejado). **Crimson Player é nome provisório.**

## Android Preview v0.2.0

O app é construído em Flutter e segue as referências visuais aprovadas: interface minimalista com **temas claro e escuro**, tipografia Inter, telas de álbum/Now Playing e navegação inferior com **animação efetiva**.

Funcionalidades presentes:
- Biblioteca local Android via MediaStore, solicitando permissão de áudio conforme a versão do sistema.
- Exibição de capas reais extraídas dos arquivos; ausência de capa tem apenas um marcador neutro.
- Reprodução local MP3/FLAC e formatos suportados pelo Media Kit.
- Busca em músicas locais, lista de álbuns, fila, favoritas persistentes.
- Play/pause, próxima, anterior, aleatório, repetição, progresso real e seek.
- Mini-player integrado ao dock de navegação.
- Temas claro, escuro e automático, com preferência salva.
- Reprodução por link HTTPS direto e autorizado (experimental).

Limitações: catálogo online pesquisável ainda não integrado; sem Spotify; playlists editáveis e controles de notificação/tela bloqueada ainda pendentes. Não há waveform extraída do áudio — o controle atual é uma barra precisa, sem dados visuais inventados.

## Instalação

Baixe a versão Android pela seção [Releases](https://github.com/AizenVisuals/Crimson-Player/releases), não pelos commits.

Para Android ARM64, use `app-arm64-v8a-release.apk`.

## Desenvolvimento

Requer Flutter SDK e Android SDK.

```bash
git clone https://github.com/AizenVisuals/Crimson-Player.git
cd Crimson-Player
flutter create --platforms=android --org com.aizenvisuals .
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release --split-per-abi
```

A compilação automática usa GitHub Actions. Quando análise, testes e build passam, publica a prévia na seção Releases.

## Documentação visual

Consulte [DESIGN.md](DESIGN.md). Não criar capas, imagens ou formas de onda inventadas por código; use fontes reais ou marcadores honestos.
