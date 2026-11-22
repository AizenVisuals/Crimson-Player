<div align="center">

# Crimson Player

**Your music. Your device. Your choice.**

A minimalist music player built with Flutter, focused on local libraries, clear navigation and an extensible architecture for properly licensed online sources.

[![Android CI](https://github.com/AizenVisuals/Crimson-Player/actions/workflows/android.yml/badge.svg)](https://github.com/AizenVisuals/Crimson-Player/actions/workflows/android.yml)
[![Latest version](https://img.shields.io/github/v/release/AizenVisuals/Crimson-Player?include_prereleases&label=preview)](https://github.com/AizenVisuals/Crimson-Player/releases)
[![License GPL-3.0](https://img.shields.io/badge/license-GPL--3.0--only-171C26)](LICENSE)
[![Flutter](https://img.shields.io/badge/built%20with-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)

[**Download APK**](https://github.com/AizenVisuals/Crimson-Player/releases) · [Features](#features) · [Development](#development) · [Roadmap](#roadmap) · [Português](README.pt-BR.md)

</div>

> [!IMPORTANT]
> **Early preview — not yet ready for public-store distribution.** Android builds are available for testing. On-device testing, accessibility checks, application signing, privacy verification and independent builds still need work. The name "Crimson Player" is provisional.

## Overview

Crimson Player is designed around the music player itself—not advertisements, giant promotional banners or fake album art. Its visual language is deliberately restrained: **Inter typography**, a light and dark palette, compact album views, a persistent mini-player and **animated bottom navigation**.

Actual album art is read from audio files. Missing artwork uses a neutral placeholder. Playback position uses a real seek control rather than a generated waveform pretending to come from the audio.

## Features

| Capability | Status |
| --- | --- |
| Local audio library and Android audio permissions | ✅ Implemented; needs on-device validation |
| MP3, FLAC and other formats supported by Media Kit | ✅ Engine integrated; format support depends on device |
| Local search, albums, playback queue | ✅ Implemented |
| Play / pause / skip / repeat / shuffle / seek | ✅ Implemented |
| Favorites saved on device | ✅ Implemented |
| Light / dark / system themes | ✅ Implemented |
| Animated navigation and mini-player | ✅ Implemented; motion tuning ongoing |
| HTTPS direct-stream playback | 🧪 Experimental; use authorized streams only |
| Online artist/song catalog | 🛠️ Not implemented |
| Spotify or YouTube Music playback within the app | ❌ Not implemented |
| Editable playlists, background/lock-screen controls | 🛠️ Planned |
| Linux / Windows desktop app | 🛠️ Planned after Android |

## Screenshots

Screenshots will be added after the current Android UI is verified on a real device. **No promotional renders or fabricated screenshots** are used to represent the app.

## Download and installation

Download the current Android preview from [**GitHub Releases**](https://github.com/AizenVisuals/Crimson-Player/releases). The downloadable files are attached to the release, not hidden inside a commit or workflow log.

| APK | Device |
| --- | --- |
| `app-arm64-v8a-release.apk` | Most modern Android phones (64-bit ARM) |
| `app-armeabi-v7a-release.apk` | Older 32-bit ARM devices |
| `app-x86_64-release.apk` | x86-64 devices and emulators |

> These previews are test packages, not Play Store-signed releases. Android may require you to confirm installation from your browser or file manager.

## Design

| Token | Light | Dark |
| --- | --- | --- |
| Background | `#FFFFFF` | `#171C26` |
| Foreground | `#171C26` | `#FFFFFF` |
| Secondary text | `#6C7689` | `#9BA6BA` |
| Raised surface | `#EDEFF3` | `#272F3E` |

Full design decisions and constraints are in [DESIGN.md](DESIGN.md).

## Development

**Requirements:** Flutter SDK, Android SDK and a supported Java toolchain.

```sh
git clone https://github.com/AizenVisuals/Crimson-Player.git
cd Crimson-Player
flutter create --platforms=android --org com.aizenvisuals .
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter run
```

Create a test APK:

```sh
flutter build apk --release --split-per-abi
```

The Android host project is currently bootstrapped by `flutter create`; checking the generated Gradle project into version control is tracked as a **store-readiness prerequisite**, rather than claiming the repository is ready for F-Droid as-is.

### Architecture

```text
lib/
├── main.dart                   App startup and theme preference
├── models/music_track.dart     Shared track model
├── services/
│   ├── local_library.dart      Android MediaStore access
│   └── music_player.dart       Playback engine and queue
└── ui/
    ├── app_theme.dart          Theme and typography tokens
    ├── crimson_shell.dart      Screen navigation
    ├── library_pages.dart      Home, search, library and albums
    ├── now_playing_page.dart   Full-screen player
    └── widgets/               Navigation, artwork and controls
```

The Android application is the current priority. Desktop compatibility is an architectural goal, **not an existing supported release**.

## Online music sources

Crimson Player does **not** distribute music, bypass DRM, or ship music-download providers. It currently supports user-provided, direct HTTPS audio streams where the user is authorized to access the content.

[Orpheon](https://github.com/kota-zo/Orpheon) and [Metrolist](https://github.com/MetrolistGroup/Metrolist) were reviewed as *architectural references*. Neither provides an official, drop-in Flutter Spotify/YouTube Music playback SDK. Copying their GPL code would require complying with their source and attribution terms; use of unofficial streaming services can also conflict with provider conditions. No code from those apps has been imported.

See [Online source feasibility](docs/ONLINE_SOURCES.md) for the research, technical constraints and future provider contract.

## Roadmap

- [ ] Verify local-audio permissions and playback on Android 13–16 devices.
- [ ] Finish layout polish and motion accessibility testing.
- [ ] Add background playback, notification / media session and headphone controls.
- [ ] Implement editable playlists and import/export.
- [ ] Add licensed online providers behind independently testable adapters.
- [ ] Add genuine screenshots, app icon assets and branding.
- [ ] Sign releases with a secure production key and prepare a Play Store AAB.
- [ ] Audit Flutter dependencies and complete F-Droid submission requirements.
- [ ] Extend the shared core to Linux and Windows.

Track current publishing requirements in [Store readiness](docs/STORE_READINESS.md).

## Privacy and security

The current app has no project-owned analytics service or account system. Local-library access requires Android audio permission; online streams contact the chosen source. Third-party libraries and font fetching require a privacy and dependency audit before store submission.

Read [PRIVACY.md](PRIVACY.md) and [SECURITY.md](SECURITY.md). Security reports should not contain passwords, session tokens, private files or personal listening histories.

## Contributing

Bug reports and improvements are welcome through [Issues](https://github.com/AizenVisuals/Crimson-Player/issues) and pull requests. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License and attribution

Released under [**GNU GPL version 3**](LICENSE). This is an independent project; Spotify, YouTube, Google and other service names belong to their respective owners. Referencing other open-source players **does not imply affiliation or endorsement**. Their code is not included in this repository.

---

<div align="center"><sub>Crimson Player · Independent open-source music player · Android-first preview</sub></div>
