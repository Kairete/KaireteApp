import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/blog/pages/blog_list_page.dart';
import 'package:kairete/features/forum/pages/forum_thread_list_page.dart';
import 'package:kairete/features/groups/pages/group_detail_page.dart';
import 'package:kairete/features/media/pages/media_list_page.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/suggestions/models/suggestion_models.dart';
import 'package:kairete/features/suggestions/services/suggestion_actions.dart';
import 'package:kairete/features/suggestions/services/suggestions_service.dart';
import 'package:kairete/features/suggestions/widgets/suggestion_facebook_card.dart';
import 'package:get/get.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final _service = SuggestionsService.instance;
  final _actions = SuggestionActions();

  List<SuggestionItem> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  String _contentType = '';
  String _method = 'smart';
  int _page = 1;
  bool _hasMore = false;
  final Set<String> _busy = {};

  static const _filters = <(String, String)>[
    ('', 'Tutti'),
    ('user', 'Utenti'),
    ('blog', 'Blog'),
    ('forum', 'Forum'),
    ('album', 'Album'),
    ('group', 'Gruppi'),
  ];

  static const _methods = <(String, String)>[
    ('smart', 'Intelligenti'),
    ('recent_activity', 'Attività recenti'),
    ('new_members', 'Nuovi'),
    ('most_messages', 'Più messaggi'),
    ('highest_reaction_score', 'Reazioni'),
    ('most_trophy_points', 'Trofei'),
    ('followed_by_following', 'Dai tuoi follow'),
  ];

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  String _key(SuggestionItem item) =>
      '${item.contentType}:${item.contentId}';

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      final payload = await _service.fetch(
        context: 'page',
        contentType: _contentType.isEmpty ? null : _contentType,
        method: _method,
        page: reset ? 1 : _page + 1,
      );
      if (!mounted) return;
      setState(() {
        if (reset) {
          _items = List.of(payload.suggestions);
          _page = 1;
        } else {
          _items = [..._items, ...payload.suggestions];
          _page += 1;
        }
        _hasMore = payload.hasMore;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppToast.mapApiError(e.toString());
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _onAction(SuggestionItem item) async {
    final key = _key(item);
    setState(() => _busy.add(key));
    try {
      await _actions.perform(item);
      if (!mounted) return;
      setState(() => _items.removeWhere((e) => _key(e) == key));
      AppToast.success('${item.actionLabel}: ${item.title}');
      // Aggiornamento automatico dopo follow/join/watch
      await _load(reset: true);
    } catch (e) {
      AppToast.error(AppToast.mapApiError(e.toString()));
    } finally {
      if (mounted) setState(() => _busy.remove(key));
    }
  }

  Future<void> _onDismiss(SuggestionItem item) async {
    final key = _key(item);
    setState(() => _items.removeWhere((e) => _key(e) == key));
    try {
      await _service.dismiss(
        contentType: item.contentType,
        contentId: item.contentId,
      );
      if (!mounted) return;
      await _load(reset: true);
    } catch (e) {
      AppToast.error(AppToast.mapApiError(e.toString()));
      await _load(reset: true);
    }
  }

  Future<void> _restore() async {
    try {
      final count = await _service.restore();
      AppToast.success(
        count > 0
            ? '$count suggerimenti ripristinati.'
            : 'Nessun suggerimento da ripristinare.',
      );
      await _load(reset: true);
    } catch (e) {
      AppToast.error(AppToast.mapApiError(e.toString()));
    }
  }

  void _open(SuggestionItem item) {
    switch (item.contentType) {
      case 'user':
        OmnifeedNavigation.openUserProfile(item.contentId);
        break;
      case 'blog':
        Get.to(
          () => BlogListPage(
            filterBlogId: item.contentId,
            pageTitle: item.title,
          ),
        );
        break;
      case 'forum':
        Get.to(
          () => ForumThreadListPage(
            forumId: item.contentId,
            forumTitle: item.title,
          ),
        );
        break;
      case 'album':
        Get.to(
          () => MediaListPage(
            filterAlbumId: item.contentId,
            pageTitle: item.title,
          ),
        );
        break;
      case 'group':
        Get.to(() => GroupDetailPage(groupId: item.contentId));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Suggerimenti'),
        actions: [
          IconButton(
            tooltip: 'Ripristina nascosti',
            onPressed: _restore,
            icon: const Icon(Icons.restore_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                for (final (value, label) in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _contentType == value,
                      onSelected: (_) {
                        setState(() => _contentType = value);
                        _load(reset: true);
                      },
                    ),
                  ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                for (final (value, label) in _methods)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: _method == value,
                      onSelected: (_) {
                        setState(() => _method = value);
                        _load(reset: true);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _load(reset: true),
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(
        child: Text(
          'Nessun suggerimento al momento.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (!_loadingMore &&
            _hasMore &&
            n.metrics.pixels > n.metrics.maxScrollExtent - 200) {
          _load(reset: false);
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final item = _items[index];
          return InkWell(
            onTap: () => _open(item),
            borderRadius: BorderRadius.circular(10),
            child: SuggestionFacebookCard(
              item: item,
              busy: _busy.contains(_key(item)),
              onAction: () => _onAction(item),
              onDismiss: () => _onDismiss(item),
            ),
          );
        },
      ),
    );
  }
}
