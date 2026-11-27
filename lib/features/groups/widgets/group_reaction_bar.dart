import 'package:flutter/material.dart';
import 'package:kairete/config/api_paths.dart';
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossibile caricare le reazioni. Verifica che l’API sia aggiornata.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .72,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Reazioni ($_total)', style: theme.textTheme.titleLarge),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final user in _users)
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                      title: Text(
                        (user['username']?.toString().isNotEmpty == true)
                            ? user['username'].toString() : 'Utente non disponibile',
                      ),
                      trailing: () {
                        final id = int.tryParse(user['reaction_id']?.toString() ?? '') ?? 0;
                        final reaction = ReactionCatalog.instance.iconFor(id);
                        return reaction != null
                            ? ReactionFace(icon: reaction, size: 25)
                            : const Icon(Icons.thumb_up, size: 22);
                      }(),
                    ),
                  if (_loading) const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  if (_error != null) Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                  if (_hasMore && !_loading)
                    Center(
                      child: TextButton(
                        onPressed: _loadMore,
                        child: Text(_error == null ? 'Carica altre reazioni' : 'Riprova'),
                      ),
                    ),
                  if (!_hasMore && _users.isEmpty && _error == null)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Nessuna reazione'),
                    )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
