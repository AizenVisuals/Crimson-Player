# Crimson Player privacy (Android preview)

**Draft, reviewed 2026-11-22.** This describes the current source code, not a completed independent dependency or network audit.

- **Local music:** The app requests Android audio access to find music and metadata on the user's device. It does not intentionally upload local songs to a Crimson server.
- **Favorites and appearance:** Saved in application preferences on-device.
- **Online audio:** When a user explicitly opens an HTTPS stream, the remote server receives a connection and its normal network metadata (such as IP address).
- **Accounts and tracking:** The current repository contains no Crimson-owned online account, advertising SDK or analytics service. Third-party dependencies can have their own network behavior.
- **Fonts:** `google_fonts` currently provides Inter and may download font files at runtime. Bundling font assets and auditing the related network requests is a prerequisite for public-store distribution.
- **Spotify and YouTube Music:** Optional catalog connections use the Spotify and Google authorization flows. Catalog queries and cover requests go to the selected provider or its image hosts. The Spotify refresh token is stored on the device using secure storage and is removed on disconnect. Google manages the YouTube session through Android sign-in. Opening an online result transfers the user to the provider.

Uninstalling normally removes app preferences; it does not delete the user's audio files.

For privacy questions, use [Issues](https://github.com/AizenVisuals/Crimson-Player/issues) without attaching private URLs, account identifiers or credentials. See [SECURITY.md](SECURITY.md) for sensitive reports.
