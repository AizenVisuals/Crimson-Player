import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

enum CatalogSource {
  spotify('Spotify'),
  youtube('YouTube');

  const CatalogSource(this.label);
  final String label;
}

typedef CatalogItem = ({
  String title,
  String subtitle,
  Uri? link,
  String? artwork,
  String? playlist
});
typedef _Json = Map<String, dynamic>;

List<_Json> _items(Object? value) =>
    (value as List?)?.whereType<_Json>().toList() ?? [];

class OnlineCatalog {
  static const _spotifyId = String.fromEnvironment('SPOTIFY_CLIENT_ID');
  static const _googleId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
  static const _spotifyPublicTokenUrl =
      String.fromEnvironment('SPOTIFY_PUBLIC_TOKEN_URL');
  static const _youtubeKey = String.fromEnvironment('YOUTUBE_API_KEY');
  static const _googleScopes = [
    'https://www.googleapis.com/auth/youtube.readonly'
  ];
  static const _spotifyKey = 'spotify_refresh_token';
  static const _storage = FlutterSecureStorage();
  static Future<void>? _googleInit;
  static GoogleSignInAccount? _googleAccount;

  OnlineCatalog(this.source);
  final CatalogSource source;

  bool get canConnect => source == CatalogSource.spotify
      ? _spotifyId.isNotEmpty
      : Platform.isAndroid && _googleId.isNotEmpty;

  bool canSearch(bool connected) =>
      connected ||
      switch (source) {
        CatalogSource.spotify => _publicSpotifyEndpoint != null,
        CatalogSource.youtube => _youtubeKey.isNotEmpty,
      };

  static Uri? get _publicSpotifyEndpoint {
    final url = Uri.tryParse(_spotifyPublicTokenUrl);
    return url != null &&
            url.scheme == 'https' &&
            url.host.isNotEmpty &&
            url.userInfo.isEmpty
        ? url
        : null;
  }

  Future<bool> isConnected() async {
    if (!canConnect) return false;
    if (source == CatalogSource.spotify) {
      return await _storage.read(key: _spotifyKey) != null;
    }
    await _initializeGoogle();
    _googleAccount ??=
        await GoogleSignIn.instance.attemptLightweightAuthentication();
    final authorization = await _googleAccount?.authorizationClient
        .authorizationForScopes(_googleScopes);
    return authorization != null;
  }

  Future<void> connect() async {
    if (source == CatalogSource.spotify) {
      await _connectSpotify();
      return;
    }
    await _initializeGoogle();
    final account = await GoogleSignIn.instance.authenticate();
    await account.authorizationClient.authorizeScopes(_googleScopes);
    _googleAccount = account;
  }

  Future<void> disconnect() async {
    if (source == CatalogSource.spotify) {
      await _storage.delete(key: _spotifyKey);
      return;
    }
    await GoogleSignIn.instance.signOut();
    _googleAccount = null;
  }

  Future<List<CatalogItem>> search(String query, bool connected) async {
    if (source == CatalogSource.spotify) {
      final token = connected
          ? await _spotifyAccessToken()
          : (await _get(_publicSpotifyEndpoint!, null))['access_token']
              as String;
      final response = await _get(
        Uri.https(
            'api.spotify.com', '/v1/search', {'q': query, 'type': 'track'}),
        token,
      );
      return _items((response['tracks'] as _Json?)?['items'])
          .map(_spotifyTrack)
          .toList();
    }

    final response = await _youtube(
      'search',
      {
        'part': 'snippet',
        'q': query,
        'type': 'video',
        'videoCategoryId': '10',
        'maxResults': '25'
      },
      authenticated: connected,
    );
    return _items(response['items']).map((item) {
      final snippet = item['snippet'] as _Json;
      return _video(snippet, (item['id'] as _Json)['videoId'] as String?);
    }).toList();
  }

  Future<List<CatalogItem>> library([String? playlist]) async {
    final results = <CatalogItem>[];
    if (source == CatalogSource.spotify) {
      var path = '/v1/me/tracks';
      Map<String, String> parameters = {'limit': '50'};
      final token = await _spotifyAccessToken();
      while (true) {
        final page =
            await _get(Uri.https('api.spotify.com', path, parameters), token);
        results.addAll(_items(page['items'])
            .map((item) => item['track'])
            .whereType<_Json>()
            .where((track) => track['is_local'] != true)
            .map(_spotifyTrack));
        final next = page['next'] as String?;
        if (next == null) return results;
        final uri = Uri.parse(next);
        path = uri.path;
        parameters = uri.queryParameters;
      }
    }

    String? cursor;
    do {
      final response = await _youtube(
        playlist == null ? 'playlists' : 'playlistItems',
        {
          'part': 'snippet',
          if (playlist == null) 'mine': 'true' else 'playlistId': playlist,
          if (cursor != null) 'pageToken': cursor,
          'maxResults': '50',
        },
        authenticated: true,
      );
      for (final item in _items(response['items'])) {
        final snippet = item['snippet'] as _Json;
        if (playlist != null) {
          results.add(_video(
              snippet, (snippet['resourceId'] as _Json?)?['videoId'] as String?,
              music: false));
        } else {
          results.add((
            title: snippet['title'] as String,
            subtitle: snippet['channelTitle'] as String? ?? '',
            link: null,
            artwork: _youtubeArtwork(snippet),
            playlist: item['id'] as String,
          ));
        }
      }
      cursor = response['nextPageToken'] as String?;
    } while (cursor != null);
    return results;
  }

  static Future<void> _initializeGoogle() => _googleInit ??=
      GoogleSignIn.instance.initialize(serverClientId: _googleId);

  static Future<_Json> _youtube(String path, Map<String, String> params,
      {required bool authenticated}) async {
    String? token;
    if (authenticated) {
      final authorization = await _googleAccount?.authorizationClient
          .authorizationForScopes(_googleScopes);
      token = authorization?.accessToken;
      if (token == null) {
        throw const FormatException('Reconecte sua conta do YouTube.');
      }
    }
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/$path', {
      ...params,
      if (token == null) 'key': _youtubeKey,
    });
    return _get(uri, token);
  }

  static String? _youtubeArtwork(_Json snippet) =>
      ((snippet['thumbnails'] as _Json?)?['default'] as _Json?)?['url']
          as String?;

  static CatalogItem _video(_Json snippet, String? id, {bool music = true}) => (
        title: snippet['title'] as String? ?? 'Vídeo',
        subtitle: (snippet['videoOwnerChannelTitle'] ?? snippet['channelTitle'])
                as String? ??
            '',
        link: id == null
            ? null
            : Uri.https(music ? 'music.youtube.com' : 'www.youtube.com',
                '/watch', {'v': id}),
        artwork: _youtubeArtwork(snippet),
        playlist: null,
      );

  static CatalogItem _spotifyTrack(_Json track) {
    final album = track['album'] as _Json?;
    final covers = _items(album?['images']);
    final artists =
        _items(track['artists']).map((item) => item['name']).join(', ');
    return (
      title: track['name'] as String? ?? 'Faixa',
      subtitle: [artists, album?['name'] as String? ?? '']
          .where((name) => name.isNotEmpty)
          .join(' · '),
      link: track['id'] is String
          ? Uri.https('open.spotify.com', '/track/${track['id']}')
          : null,
      artwork: covers.isEmpty ? null : covers.last['url'] as String?,
      playlist: null,
    );
  }

  static Future<_Json> _get(Uri url, String? token) async {
    final response = await http.get(url, headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    }).timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  static _Json _decode(http.Response response) {
    if (response.statusCode == 401)
      throw const FormatException('A sessão expirou. Reconecte sua conta.');
    if (response.statusCode == 429)
      throw const FormatException(
          'Limite de consultas atingido. Tente mais tarde.');
    if (response.statusCode != 200)
      throw FormatException(
          'O serviço recusou a consulta (${response.statusCode}).');
    return jsonDecode(utf8.decode(response.bodyBytes)) as _Json;
  }

  static String _random() {
    final random = Random.secure();
    return base64UrlEncode(List.generate(32, (_) => random.nextInt(256)))
        .replaceAll('=', '');
  }

  static Future<void> _connectSpotify() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final redirect = 'http://127.0.0.1:${server.port}/callback';
    final state = _random();
    final verifier = _random();
    final challenge =
        base64UrlEncode(sha256.convert(ascii.encode(verifier)).bytes)
            .replaceAll('=', '');
    final accepted = Completer<String?>();
    final listener = server.listen((request) async {
      final valid = request.method == 'GET' &&
          request.uri.path == '/callback' &&
          request.uri.queryParameters['state'] == state;
      request.response.statusCode = valid ? 200 : 404;
      request.response.headers.contentType = ContentType.text;
      request.response.write(valid
          ? 'Volte ao Crimson Player para continuar.'
          : 'Página indisponível.');
      await request.response.close();
      if (valid && !accepted.isCompleted) {
        accepted.complete(request.uri.queryParameters['code']);
      }
    });
    try {
      final url = Uri.https('accounts.spotify.com', '/authorize', {
        'client_id': _spotifyId,
        'response_type': 'code',
        'redirect_uri': redirect,
        'state': state,
        'scope': 'user-library-read',
        'code_challenge_method': 'S256',
        'code_challenge': challenge,
      });
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw const FormatException('Não foi possível abrir o navegador.');
      }
      final code = await accepted.future.timeout(const Duration(minutes: 2));
      if (code == null) throw const FormatException('Conexão cancelada.');
      final token = await _spotifyToken({
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirect,
        'code_verifier': verifier,
      });
      await _storage.write(
          key: _spotifyKey, value: token['refresh_token'] as String);
    } finally {
      await listener.cancel();
      await server.close(force: true);
    }
  }

  static Future<String> _spotifyAccessToken() async {
    final refresh = await _storage.read(key: _spotifyKey);
    if (refresh == null)
      throw const FormatException('Conecte sua conta do Spotify.');
    final token = await _spotifyToken(
        {'grant_type': 'refresh_token', 'refresh_token': refresh});
    final replacement = token['refresh_token'] as String?;
    if (replacement != null)
      await _storage.write(key: _spotifyKey, value: replacement);
    return token['access_token'] as String;
  }

  static Future<_Json> _spotifyToken(Map<String, String> params) async =>
      _decode(
        await http.post(
          Uri.https('accounts.spotify.com', '/api/token'),
          body: {'client_id': _spotifyId, ...params},
        ).timeout(const Duration(seconds: 20)),
      );
}
