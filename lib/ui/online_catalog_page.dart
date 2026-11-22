import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/online_catalog.dart';

class OnlineCatalogLinks extends StatelessWidget {
  const OnlineCatalogLinks({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (final source in CatalogSource.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(source == CatalogSource.spotify
                  ? Icons.music_note_rounded
                  : Icons.video_library_outlined),
              title: Text(source.label),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => OnlineCatalogPage(source: source),
              )),
            ),
        ],
      );
}

class OnlineCatalogPage extends StatefulWidget {
  const OnlineCatalogPage({super.key, required this.source});

  final CatalogSource source;

  @override
  State<OnlineCatalogPage> createState() => _OnlineCatalogPageState();
}

class _OnlineCatalogPageState extends State<OnlineCatalogPage> {
  late final _catalog = OnlineCatalog(widget.source);
  final _query = TextEditingController();
  List<CatalogItem>? _results;
  bool _connected = false;
  bool _busy = false;
  String? _error;
  String? _section;

  @override
  void initState() {
    super.initState();
    _run(() async => _connected = await _catalog.isConnected());
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await operation();
    } on FormatException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Não foi possível concluir a operação. Tente novamente.';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _load(
          String section, Future<List<CatalogItem>> Function() load) =>
      _run(() async {
        _results = null;
        _section = section;
        _results = await load();
      });

  void _search() {
    final value = _query.text.trim();
    if (value.isEmpty || !_catalog.canSearch(_connected)) return;
    _load('Resultados', () => _catalog.search(value, _connected));
  }

  Future<void> _open(Uri link) async {
    try {
      if (await launchUrl(link, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Report platform failures without exposing request details.
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o serviço.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final spotify = widget.source == CatalogSource.spotify;
    final canSearch = _catalog.canSearch(_connected);
    final libraryLabel = spotify ? 'Faixas salvas' : 'Minhas playlists';
    return Scaffold(
      appBar: AppBar(title: Text(widget.source.label)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            itemCount: 1 + (_results?.length ?? 0),
            itemBuilder: (context, index) {
              if (index > 0) {
                final item = _results![index - 1];
                final artwork = Uri.tryParse(item.artwork ?? '');
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: artwork?.scheme == 'https'
                      ? Image.network(
                          artwork.toString(),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const SizedBox.square(dimension: 48),
                        )
                      : null,
                  title: Text(item.title),
                  subtitle: item.subtitle.isEmpty ? null : Text(item.subtitle),
                  trailing: Icon(item.playlist != null
                      ? Icons.chevron_right_rounded
                      : Icons.open_in_new_rounded),
                  onTap: _busy
                      ? null
                      : item.playlist != null
                          ? () => _load(
                              item.title, () => _catalog.library(item.playlist))
                          : item.link == null
                              ? null
                              : () => _open(item.link!),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_catalog.canConnect && !canSearch)
                    const Text(
                        'Este serviço precisa ser configurado nesta versão do app.'),
                  if (_catalog.canConnect)
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _run(() async {
                                if (_connected) {
                                  await _catalog.disconnect();
                                  _connected = false;
                                  _section = null;
                                  _results = null;
                                } else {
                                  await _catalog.connect();
                                  _connected = true;
                                }
                              }),
                      icon: Icon(_connected ? Icons.logout : Icons.login),
                      label: Text(
                          _connected ? 'Desconectar conta' : 'Conectar conta'),
                    ),
                  if (canSearch) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _query,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      decoration: InputDecoration(
                        labelText: spotify
                            ? 'Buscar faixas'
                            : 'Buscar vídeos de música',
                        suffixIcon: IconButton(
                          tooltip: 'Buscar',
                          onPressed: _busy ? null : _search,
                          icon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                  ],
                  if (_connected)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => _load(libraryLabel, () => _catalog.library()),
                      child: Text(libraryLabel),
                    ),
                  if (_busy) const LinearProgressIndicator(),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),
                  if (_section != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(_section!,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  if (_results?.isEmpty == true)
                    const Text('Nenhum resultado encontrado.'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
