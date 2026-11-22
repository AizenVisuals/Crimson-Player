# Online music: technical feasibility

Research date: **2026-11-22**. This documents research, **not shipped integrations**.

## Architecture

UI -> catalog metadata -> provider adapter -> authorized playback resolver -> Media Kit.

Metadata search results do **not** prove audio playback rights. Adapters must explicitly declare `search`, `play`, `account`, `offline`, `artwork` and restrictions. Unsupported capabilities must not be displayed as if working.

## Spotify / Orpheon

[Orpheon](https://github.com/kota-zo/Orpheon) is an extension-based Android player. It uses public catalogs to find metadata and separately installed audio-source extensions; it does **not** offer a generic official Spotify audio API. Its Kotlin/Compose modules are not drop-in Flutter packages. Orpheon is GPL-3.0; copied code requires credits, retention of notices, GPL-3.0 distribution and corresponding source. **No Orpheon code has been imported.**

Spotify's official Platform does not generally grant an independent mixed-service player access to extract its music. Streaming may require Premium and compliance with restrictions on mixing streaming sources.

Sources: https://developer.spotify.com/policy and https://developer.spotify.com/compliance-tips

**Status: not integrated.**

## YouTube Music / Metrolist

[Metrolist](https://github.com/MetrolistGroup/Metrolist) uses **InnerTubeX**, an unofficial YouTube Music client mechanism. Its own README warns that using it may conflict with YouTube terms. It is principally Kotlin/Compose, GPL-3.0, and not a ready Flutter plugin. No code has been imported.

YouTube Developer Policy: https://developers.google.com/youtube/terms/developer-policies

**Status: not integrated.**

## Providers to evaluate for lawful online audio

- [Radio Browser](https://docs.radio-browser.info/) catalogs station-provided radio streams. It does not provide on-demand music licensing.
- Independent catalogs such as Audius and Jamendo: examine official streaming APIs, terms, rate limits, artist permissions and caching rules before implementing.
- User-provided **direct HTTPS audio streams** are the only online method in the current MVP; users must be authorized to access them.

## Minimum provider acceptance tests

- Authorized audio access documented, not inferred from catalog availability.
- Remote metadata, artwork and audio are appropriately attributed.
- No DRM bypass, credential capture or unauthorized download.
- Handles regional restrictions, HTTP errors, cancellation and expired access cleanly.
- F-Droid free-software dependency audit and Google Play intellectual-property policy review before publishing.
- Avoid promising Spotify or YouTube Music playback before an approved integration is implemented.

Google Play policy: https://support.google.com/googleplay/android-developer/answer/18265346?hl=en
