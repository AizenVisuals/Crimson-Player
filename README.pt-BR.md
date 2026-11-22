<div align="center">

# Crimson Player

**Sua música. Seu dispositivo. Sua escolha.**

Um player de música minimalista em Flutter, focado na biblioteca local e preparado para futuras fontes online licenciadas.

[![Build Android](https://github.com/AizenVisuals/Crimson-Player/actions/workflows/android.yml/badge.svg)](https://github.com/AizenVisuals/Crimson-Player/actions/workflows/android.yml)
[![Última versão](https://img.shields.io/github/v/release/AizenVisuals/Crimson-Player?include_prereleases&label=pr%C3%A9via)](https://github.com/AizenVisuals/Crimson-Player/releases)
[![GPL-3.0](https://img.shields.io/badge/licen%C3%A7a-GPL--3.0--only-171C26)](LICENSE)

[**Baixar APK**](https://github.com/AizenVisuals/Crimson-Player/releases) · [Código](https://github.com/AizenVisuals/Crimson-Player) · [English](README.md)

</div>

> [!IMPORTANT]
> **Prévia Android em desenvolvimento.** O nome ainda é provisório. O projeto **não está pronto para publicação no F-Droid ou Play Store**; antes disso faltam testes em aparelhos reais, auditoria de dependências, assinatura definitiva e documentação da distribuição.

## Experiência

Design fiel às referências aprovadas: **tema claro e escuro**, tipografia Inter, tela de reprodução com capas verdadeiras, mini-player, organização compacta e barra inferior com animação de verdade.

Capas ausentes usam um ícone neutro. Não criamos imagens artificiais ou falsas formas de onda para simular mídia real.

## Funcionalidades

| Funcionalidade | Situação |
| --- | --- |
| Biblioteca local e solicitação de permissão no Android | Implementada; requer teste em aparelho real |
| Reprodução de arquivos pelo Media Kit | Implementada; requer teste em aparelho real |
| Busca local, álbuns, fila e favoritos | Implementados |
| Controles de reprodução, repetição, aleatório e posição | Implementados |
| Temas claro, escuro e automático | Implementados |
| Navegação inferior animada e mini-player | Implementados; ainda em refinamento |
| Streams HTTPS diretos e autorizados | Experimental |
| Busca de catálogo musical online | Ainda não |
| Reprodução Spotify/YouTube Music dentro do app | Ainda não |
| Playlists editáveis e controle na notificação | Planejados |
| Desktop Linux/Windows | Planejado depois do Android |

## Instalar

Entre na página de [**Releases**](https://github.com/AizenVisuals/Crimson-Player/releases) para baixar a versão de testes. Para um celular Android ARM64, escolha `app-arm64-v8a-release.apk`. Os outros APKs destinam-se a outras arquiteturas.

## Desenvolver

É necessário ter Flutter e Android SDK instalados.

```sh
git clone https://github.com/AizenVisuals/Crimson-Player.git
cd Crimson-Player
flutter create --platforms=android --org com.aizenvisuals .
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter run
```

Confira [DESIGN.md](DESIGN.md) para o padrão visual e [STORE_READINESS.md](docs/STORE_READINESS.md) para o planejamento de publicação no F-Droid e Play Store.

## Fontes online

A versão atual reproduz somente links HTTPS diretos de áudio quando o usuário tem direito de acesso. **Não incluímos fontes piratas, quebra de DRM ou acesso não autorizado a serviços.**

[Orpheon](https://github.com/kota-zo/Orpheon) e [Metrolist](https://github.com/MetrolistGroup/Metrolist) foram estudados como referências técnicas; **nenhum código deles foi copiado**. Spotify e YouTube Music não estão integrados à reprodução do app. A pesquisa está documentada em [ONLINE_SOURCES.md](docs/ONLINE_SOURCES.md).

## Privacidade e código aberto

Leia [PRIVACY.md](PRIVACY.md), [SECURITY.md](SECURITY.md) e [CONTRIBUTING.md](CONTRIBUTING.md). O projeto está licenciado sob [GPL-3.0](LICENSE).

Crimson Player é independente e não tem vínculo oficial com provedores de música. Os nomes e marcas de terceiros pertencem aos seus titulares.

---

<div align="center"><sub>Crimson Player · Prévia Android · Identidade e funcionalidades em evolução</sub></div>
