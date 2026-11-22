# Online music: technical feasibility

Research date: **2026-11-22**. This documents research, **not shipped integrations**.

## Architecture

UI -> catalog metadata -> provider adapter -> authorized playback resolver -> Media Kit.

Metadata search results do **not** prove audio playback rights. Adapters must explicitly declare `search`, `play`, `account`, `offline`, `artwork` and restrictions. Unsupported capabilities must not be displayed as if working.

## Accounts and browsing

Keep sign-in optional and independent per service. In Settings, each service
can connect and disconnect its own account. On disconnect, remove that
service's tokens and cached private results. Local playback and public search
can work before either account is connected where the chosen catalog supports
anonymous browsing.

Add a catalog result model for provider ID, track ID, title, artist, album,
artwork and provider link. Search displays the provider and opens its link.
Keep these results out of the Media Kit queue until a supported playback
integration is available.

## Spotify / Orpheon

The current [Orpheon v1.0.0](https://github.com/kota-zo/Orpheon/releases/tag/v1.0.0)
gets metadata from public catalogs such as Deezer, iTunes and MusicBrainz.
Earlier Myspoti/Orpheon releases described Spotify login and playback in the
[changelog](https://github.com/kota-zo/Orpheon/blob/main/CHANGELOG.md). The current
public catalogs can help discover songs without signing in. They cannot supply
the user's Spotify library.

For Spotify results, use the [Spotify Web API search](https://developer.spotify.com/documentation/web-api/reference/search).
Search requires a Spotify access token. To offer search without user sign-in,
use a server-side Client Credentials integration if the app's Spotify access
allows it. Keep the client secret on the server. On Android, sign in through
the system browser using [Authorization Code with PKCE](https://developer.spotify.com/documentation/web-api/tutorials/code-pkce-flow),
then request `user-library-read` for [saved tracks](https://developer.spotify.com/documentation/web-api/reference/get-users-saved-tracks).
Register the client and redirect URI, validate OAuth state, store refresh tokens
with OS-backed storage and paginate results. Verify
[development-mode limits](https://developer.spotify.com/documentation/web-api/tutorials/february-2026-migration-guide)
before distributing the feature. Link catalog results to Spotify and follow
its [developer policy](https://developer.spotify.com/policy).

## YouTube Music / Metrolist

Metrolist searches YouTube Music with the unofficial InnerTube web client,
then maps the response to catalog items. Its Android Google sign-in uses a
WebView and a YouTube Music session cookie for authenticated requests. Its
InnerTubeX playback engine is a separate component.
[Search implementation](https://github.com/MetrolistGroup/Metrolist/blob/9448bb85d6842bb8da5359bd46f14d858acf833e/shared/src/commonMain/kotlin/com/metrolist/shared/api/YouTubeSearchOperations.kt) ·
[Android sign-in](https://github.com/MetrolistGroup/Metrolist/blob/9448bb85d6842bb8da5359bd46f14d858acf833e/androidApp/src/main/kotlin/com/metrolist/android/ui/screens/LoginScreen.kt)

For an official integration, use the YouTube Data API for public video search
and Google OAuth with `youtube.readonly` for
[the user's YouTube playlists and their items](https://developers.google.com/youtube/data/guides/implementation/playlists).
This API lists YouTube videos and playlists. To match Metrolist's YouTube
Music search and library, the Crimson Player would need a separate InnerTube
integration, with exposure to undocumented response changes and the terms
concerns described by [Metrolist](https://github.com/MetrolistGroup/Metrolist).
Review the [YouTube developer policies](https://developers.google.com/youtube/terms/developer-policies)
before shipping.

**Status:** Catalog and login research only. Both upstream projects are
GPL-3.0 and no code from either project has been imported.

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
