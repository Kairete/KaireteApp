import 'package:flutter/material.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/core/widgets/reaction_face.dart';

/// Reaction summary, shared across posts, blogs, threads and group posts.
/// Only real reaction usernames from the API are displayed.
class GroupReactionBar extends StatefulWidget {
  const GroupReactionBar({
    super.key,
    required this.total,
    this.reactionIds = const [],
    this.reactionUsernames = const [],
    this.visitorReactionId,
    this.contentType,
    this.contentId,
  });

  final int total;
  final List<int> reactionIds;
  final List<String> reactionUsernames;
  final int? visitorReactionId;
  final String? contentType;
  final int? contentId;

  @override
  State<GroupReactionBar> createState() => _GroupReactionBarState();
}

class _GroupReactionBarState extends State<GroupReactionBar> {
  int? _realTotal;
  List<String> _realNames = const [];
  List<int> _realReactionIds = const [];

  @override
  void initState() {
    super.initState();
    ReactionCatalog.instance.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
    _loadRealSummary();
  }

  @override
  void didUpdateWidget(covariant GroupReactionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contentId != widget.contentId ||
        oldWidget.contentType != widget.contentType ||
        oldWidget.total != widget.total ||
        oldWidget.visitorReactionId != widget.visitorReactionId) {
      _realTotal = null;
      _realNames = const [];
      _realReactionIds = const [];
      _loadRealSummary();
    }
  }

  Future<void> _loadRealSummary() async {
    final type = widget.contentType;
    final id = widget.contentId;
    if (type == null || type.isEmpty || id == null || id <= 0) return;
    try {
      await AppApi.instance.applySession();
      final json = await AppApi.instance.xenforo.get(
        ApiPaths.reactions,
        query: {'content_type': type, 'content_id': id, 'page': 1},
      );
      if (!mounted || widget.contentType != type || widget.contentId != id) return;
      final raw = json['reaction_users'];
      if (raw is! List) return;
      final names = <String>[];
      final ids = <int>[];
      for (final user in raw) {
        if (user is! Map) continue;
        final name = user['username']?.toString().trim() ?? '';
        if (name.isNotEmpty && !names.contains(name) && names.length < 2) names.add(name);
        final reactionId = int.tryParse(user['reaction_id']?.toString() ?? '') ?? 0;
        if (reactionId > 0 && !ids.contains(reactionId)) ids.add(reactionId);
      }
      setState(() {
        _realTotal = int.tryParse(json['reaction_count']?.toString() ?? '');
        _realNames = names;
        _realReactionIds = ids;
      });
    } catch (_) {
      // The originating card remains usable if this optional endpoint fails.
    }
  }

  void _showReactions() {
    final contentType = widget.contentType;
    final contentId = widget.contentId;
    if (contentType == null || contentType.isEmpty ||
        contentId == null || contentId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elenco reazioni non disponibile per questo contenuto.')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0xB3000000),
      builder: (_) => _ReactionUsersSheet(
        contentType: contentType,
        contentId: contentId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _realTotal ?? widget.total;
    if (total <= 0 && widget.reactionIds.isEmpty && _realReactionIds.isEmpty) {
      return const SizedBox.shrink();
    }
    final ids = <int>{
      ..._realReactionIds.where((id) => id > 0),
      ...widget.reactionIds.where((id) => id > 0),
      if ((widget.visitorReactionId ?? 0) > 0) widget.visitorReactionId!,
    }.take(4).toList();

    final names = (_realNames.isNotEmpty ? _realNames : widget.reactionUsernames)
        .where((name) => name.trim().isNotEmpty)
        .take(2).toList();
    final remaining = (total - names.length).clamp(0, 1 << 30);
    String label;
    if (names.length == 2) {
      label = remaining > 0
          ? '${names[0]}, ${names[1]} e $remaining ${remaining == 1 ? 'persona' : 'persone'} hanno reagito'
          : '${names[0]} e ${names[1]} hanno reagito';
    } else if (names.length == 1) {
      label = remaining > 0
          ? '${names[0]} e $remaining ${remaining == 1 ? 'persona' : 'persone'} hanno reagito'
          : '${names[0]} ha reagito';
    } else {
      label = '$total ${total == 1 ? 'persona ha' : 'persone hanno'} reagito';
    }

    return Material(
      color: const Color(0xFFF5F5F5),
      child: InkWell(
        onTap: _showReactions,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              if (ids.isEmpty)
                const Icon(Icons.thumb_up, size: 17, color: Color(0xFFBE8F22))
              else
                ...ids.map((id) {
                  final reaction = ReactionCatalog.instance.iconFor(id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: reaction == null
                        ? const Icon(Icons.thumb_up, size: 17,
                            color: Color(0xFFBE8F22))
                        : ReactionFace(icon: reaction, size: 19),
                  );
                }),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12, height: 1.2, color: Color(0xFF176493)),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF176493), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fetches the real reaction records in pages. No dummy names or locally
/// manufactured reaction types are used.
class _ReactionUsersSheet extends StatefulWidget {
  const _ReactionUsersSheet({required this.contentType, required this.contentId});
  final String contentType;
  final int contentId;

  @override
  State<_ReactionUsersSheet> createState() => _ReactionUsersSheetState();
}

class _ReactionUsersSheetState extends State<_ReactionUsersSheet> {
  int? _selectedReactionId;
  static const _xfBlue = Color(0xFF1479B9);
  static const _xfDivider = Color(0xFFE1E1E1);

  final List<Map<String, dynamic>> _users = [];
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  int _page = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() { _loading = true; _error = null; });
    try {
      await AppApi.instance.applySession();
      await ReactionCatalog.instance.ensureLoaded();
      final json = await AppApi.instance.xenforo.get(
        ApiPaths.reactions,
        query: {
          'content_type': widget.contentType,
          'content_id': widget.contentId,
          'page': _page + 1,
        },
      );
      final error = XenforoApi.firstErrorMessage(json);
      if (error != null) throw Exception(error);
      final raw = json['reaction_users'];
      if (raw is! List) throw const FormatException('API elenco reazioni non disponibile');
      if (!mounted) return;
      setState(() {
        _users.addAll(raw.whereType<Map>().map((entry) =>
          Map<String, dynamic>.from(entry)));
        _total = int.tryParse(json['reaction_count']?.toString() ?? '') ?? _users.length;
        _page++;
        _hasMore = json['has_more'] == true;
        _loading = false;
      });
      if (_hasMore && mounted) {
        await _loadMore();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossibile caricare le reazioni. Verifica che l’API sia aggiornata.';
        _loading = false;
      });
    }
  }

  int _reactionId(Map<String, dynamic> user) =>
      int.tryParse(user['reaction_id']?.toString() ?? '') ?? 0;

  String _reactionDate(Map<String, dynamic> user) {
    final seconds = int.tryParse(user['reaction_date']?.toString() ?? '') ?? 0;
    if (seconds <= 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true).toLocal();
    const months = ['gen','feb','mar','apr','mag','giu','lug','ago','set','ott','nov','dic'];
    return date.day.toString() + ' ' + months[date.month - 1] + ' ' + date.year.toString();
  }

  Widget _reactionIcon(int id, double size) {
    final reaction = ReactionCatalog.instance.iconFor(id);
    return reaction == null
        ? Icon(Icons.thumb_up, color: const Color(0xFFD89A18), size: size)
        : ReactionFace(icon: reaction, size: size);
  }

  /// XenForo can send absolute, protocol-relative or website-relative URLs.
  /// An empty avatar_url must not hide a populated avatar_urls field.
  String? _avatarUrl(Map<String, dynamic> user) {
    final variants = user['avatar_urls'];
    final nested = user['User'];
    final candidates = <dynamic>[
      user['avatar_url'],
      if (variants is Map) ...[
        variants['m'], variants['s'], variants['l'],
      ],
      if (nested is Map) ...[
        nested['avatar_url'],
        if (nested['avatar_urls'] is Map) ...[
          (nested['avatar_urls'] as Map)['m'],
          (nested['avatar_urls'] as Map)['s'],
        ],
      ],
    ];
    for (final candidate in candidates) {
      final raw = candidate?.toString().trim() ?? '';
      if (raw.isEmpty) continue;
      final base = Uri.parse(AppConfig.apiBaseUrl);
      final uri = Uri.tryParse(raw);
      if (uri == null) continue;
      final resolved = uri.hasScheme ? uri : base.resolveUri(uri);
      if ((resolved.scheme == 'https' || resolved.scheme == 'http') &&
          resolved.host.isNotEmpty) {
        return resolved.toString();
      }
    }
    return null;
  }

  Widget _avatar(Map<String, dynamic> user) {
    final name = user['username']?.toString().trim() ?? '';
    final url = _avatarUrl(user);
    return CircleAvatar(
      radius: 23,
      backgroundColor: const Color(0xFF32A5BC),
      foregroundColor: Colors.white,
      child: url == null
          ? Text(name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 21))
          : ClipOval(
              child: Image.network(
                url,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Center(child: Text(
                      name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 21),
                    )),
              ),
            ),
    );
  }

  Widget _tab(int? id, int total, String label) {
    final active = _selectedReactionId == id;
    return InkWell(
      onTap: () => setState(() => _selectedReactionId = id),
      child: Container(
        decoration: BoxDecoration(border: Border(
          bottom: BorderSide(width: 2, color: active ? _xfBlue : Colors.transparent))),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (id != null) ...[_reactionIcon(id, 17), const SizedBox(width: 5)],
          Text(label + ' (' + total.toString() + ')',
            style: TextStyle(
              fontSize: 13, color: active ? _xfBlue : const Color(0xFF555555),
              fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
        ]),
      ),
    );
  }

  Widget _userRow(Map<String, dynamic> user) {
    final name = user['username']?.toString().trim() ?? '';
    final title = user['user_title']?.toString().trim() ?? '';
    final messageCount = int.tryParse(user['message_count']?.toString() ?? '');
    final reactionScore = int.tryParse(user['reaction_score']?.toString() ?? '');
    final trophyPoints = int.tryParse(user['trophy_points']?.toString() ?? '');
    final stats = <String>[
      if (messageCount != null) 'Messaggi: $messageCount',
      if (reactionScore != null) 'Punteggio reazioni: $reactionScore',
      if (trophyPoints != null) 'Punti: $trophyPoints',
    ].join(' · ');
    final date = _reactionDate(user);
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _xfDivider))),
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
      child: Row(children: [
        _avatar(user),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name.isEmpty ? 'Utente non disponibile' : name,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _xfBlue, fontSize: 15, fontWeight: FontWeight.w700)),
          if (title.isNotEmpty)
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF333333))),
          if (stats.isNotEmpty) Text(stats, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _reactionIcon(_reactionId(user), 27),
          if (date.isNotEmpty) Text(date, style: const TextStyle(fontSize: 10, color: Color(0xFF555555))),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = <int, int>{};
    for (final user in _users) {
      final id = _reactionId(user);
      if (id > 0) sizes[id] = (sizes[id] ?? 0) + 1;
    }
    final ids = sizes.keys.toList()..sort();
    final visible = _selectedReactionId == null
        ? _users
        : _users.where((user) => _reactionId(user) == _selectedReactionId).toList();
    final mediaSize = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800, maxHeight: mediaSize.height * .88),
        child: SizedBox(
          height: mediaSize.height * .80,
          child: Column(children: [
            Container(
              color: const Color(0xFFE9F3FA),
              padding: const EdgeInsets.fromLTRB(12, 8, 5, 8),
              child: Row(children: [
                const Expanded(child: Text('Utenti che hanno reagito',
                  style: TextStyle(fontSize: 18, color: _xfBlue))),
                IconButton(
                  tooltip: 'Chiudi',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, color: Color(0xFF8AB6D7)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]),
            ),
            SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, children: [
              _tab(null, _total, 'Tutti'),
              for (final id in ids)
                _tab(id, sizes[id]!, ReactionCatalog.instance.iconFor(id)?.title ?? 'Reazione'),
            ])),
            const Divider(height: 1, thickness: 1, color: _xfDivider),
            Expanded(child: ListView(children: [
              for (final user in visible) _userRow(user),
              if (_loading) const Padding(
                padding: EdgeInsets.all(18),
                child: Center(child: CircularProgressIndicator())),
              if (_error != null) Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(onPressed: () { _hasMore = true; _loadMore(); },
                    child: const Text('Riprova')),
                ])),
              if (!_loading && _users.isEmpty && _error == null)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Nessuna reazione'))),
            ])),
          ]),
        ),
      ),
    );
  }
}
