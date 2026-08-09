import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kairete/core/push/push_navigation.dart';
import 'package:kairete/core/services/reaction_catalog.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/api_url.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/core/widgets/feed_reaction_icon.dart';
import 'package:kairete/features/account/services/account_list_service.dart';
import 'package:kairete/features/blog/pages/blog_detail_page.dart';
import 'package:kairete/features/forum/pages/thread_detail_page.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/profile/services/profile_service.dart';

class AccountFollowingPage extends StatefulWidget {
  const AccountFollowingPage({super.key});

  @override
  State<AccountFollowingPage> createState() => _AccountFollowingPageState();
}

class _AccountFollowingPageState extends State<AccountFollowingPage> {
  final _service = AccountListService();
  final _profile = ProfileService();
  List<AccountUserRef> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await _service.fetchFollowing();
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppToast.mapApiError(e.toString());
        _loading = false;
      });
    }
  }

  Future<void> _unfollow(AccountUserRef user) async {
    try {
      await _profile.followUser(user.userId, stop: true);
      setState(() => _users.removeWhere((u) => u.userId == user.userId));
      AppToast.success('Non segui più ${user.username}.');
    } catch (e) {
      AppToast.error(AppToast.mapApiError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    return _AccountListScaffold(
      title: 'Utenti che segui',
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyLabel: 'Non segui ancora nessuno.',
      isEmpty: _users.isEmpty,
      child: ListView.separated(
        itemCount: _users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final user = _users[i];
          return _FollowingUserTile(
            user: user,
            dateFormat: dateFmt,
            onUnfollow: () => _unfollow(user),
          );
        },
      ),
    );
  }
}

class _FollowingUserTile extends StatelessWidget {
  const _FollowingUserTile({
    required this.user,
    required this.dateFormat,
    required this.onUnfollow,
  });

  final AccountUserRef user;
  final DateFormat dateFormat;
  final VoidCallback onUnfollow;

  @override
  Widget build(BuildContext context) {
    final numberFmt = NumberFormat.decimalPattern('it');
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => OmnifeedNavigation.openUserProfile(user.userId),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(url: user.avatarUrl, name: user.username),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            user.username,
                            style: const TextStyle(
                              color: AppTheme.authorName,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          onPressed: onUnfollow,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.brandPrimary,
                            side: const BorderSide(color: AppTheme.cardBorder),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            minimumSize: const Size(0, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text(
                            'Smetti',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    if (user.userTitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          user.userTitle,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12.5,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      runSpacing: 2,
                      children: [
                        _MemberStat(
                          label: 'Messaggi',
                          value: numberFmt.format(user.messageCount),
                        ),
                        _MemberStat(
                          label: 'Reazioni',
                          value: numberFmt.format(user.reactionScore),
                        ),
                        _MemberStat(
                          label: 'Trophy',
                          value: numberFmt.format(user.trophyPoints),
                        ),
                        if (user.questionSolutionCount > 0)
                          _MemberStat(
                            label: 'Soluzioni',
                            value: numberFmt.format(user.questionSolutionCount),
                          ),
                      ],
                    ),
                    if (user.registerDate > 0 || user.lastActivity > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          [
                            if (user.registerDate > 0)
                              'Iscritto: ${_formatTs(user.registerDate)}',
                            if (user.lastActivity > 0)
                              'Ultima attività: ${_formatTs(user.lastActivity)}',
                          ].join(' · '),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11.5,
                            height: 1.25,
                          ),
                        ),
                      ),
                    if (user.location.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Località: ${user.location}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11.5,
                            height: 1.25,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTs(int unix) {
    return dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(unix * 1000),
    );
  }
}

class _MemberStat extends StatelessWidget {
  const _MemberStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

class AccountIgnoredPage extends StatefulWidget {
  const AccountIgnoredPage({super.key});

  @override
  State<AccountIgnoredPage> createState() => _AccountIgnoredPageState();
}

class _AccountIgnoredPageState extends State<AccountIgnoredPage> {
  final _service = AccountListService();
  List<AccountUserRef> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await _service.fetchIgnored();
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppToast.mapApiError(e.toString());
        _loading = false;
      });
    }
  }

  Future<void> _unignore(AccountUserRef user) async {
    try {
      await _service.setIgnored(user.userId, stop: true);
      setState(() => _users.removeWhere((u) => u.userId == user.userId));
      AppToast.success('${user.username} non è più ignorato.');
    } catch (e) {
      AppToast.error(AppToast.mapApiError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AccountListScaffold(
      title: 'Utenti che ignori',
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyLabel: 'Non ignori nessuno.',
      isEmpty: _users.isEmpty,
      child: ListView.separated(
        itemCount: _users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final user = _users[i];
          return _UserTile(
            user: user,
            trailing: TextButton(
              onPressed: () => _unignore(user),
              child: const Text('Ripristina'),
            ),
          );
        },
      ),
    );
  }
}

class AccountReactionsPage extends StatefulWidget {
  const AccountReactionsPage({super.key});

  @override
  State<AccountReactionsPage> createState() => _AccountReactionsPageState();
}

class _AccountReactionsPageState extends State<AccountReactionsPage> {
  final _service = AccountListService();
  final _scroll = ScrollController();
  List<Map<String, dynamic>> _items = [];
  List<AccountReactionTab> _tabs = [];
  int _selectedReactionId = 0;
  int _page = 1;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    ReactionCatalog.instance.ensureLoaded();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || _loading) return;
    if (_items.length >= _total) return;
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels < _scroll.position.maxScrollExtent - 240) {
      return;
    }
    _loadMore();
  }

  Future<void> _load({int? reactionId}) async {
    final selected = reactionId ?? _selectedReactionId;
    setState(() {
      _loading = true;
      _error = null;
      _selectedReactionId = selected;
      _page = 1;
    });
    try {
      final data = await _service.fetchReactions(
        page: 1,
        reactionId: selected,
      );
      if (!mounted) return;
      setState(() {
        _items = data.reactions;
        _tabs = data.tabs.isNotEmpty
            ? data.tabs
            : [
                AccountReactionTab(
                  reactionId: 0,
                  title: 'Tutte',
                  total: data.total,
                ),
              ];
        _total = data.total;
        _page = data.page;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppToast.mapApiError(e.toString());
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _items.length >= _total) return;
    setState(() => _loadingMore = true);
    try {
      final next = _page + 1;
      final data = await _service.fetchReactions(
        page: next,
        reactionId: _selectedReactionId,
      );
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...data.reactions];
        _page = data.page;
        _total = data.total;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _openContent(Map<String, dynamic> item) async {
    final type = item['content_type']?.toString() ?? '';
    final contentId = item['content_id'] as int? ?? 0;
    final threadId = item['thread_id'] as int? ?? 0;
    final url = item['content_url']?.toString();

    if (type == 'post' && threadId > 0) {
      Get.to(() => ThreadDetailPage(threadId: threadId));
      return;
    }

    final opened = await PushNavigation.openFromData({
      'content_type': type,
      'content_id': contentId,
    });
    if (opened) return;

    if (url != null && url.trim().isNotEmpty) {
      final threadMatch = RegExp(r'/threads/[^/]+\.(\d+)').firstMatch(url);
      if (threadMatch != null) {
        final id = int.tryParse(threadMatch.group(1)!);
        if (id != null && id > 0) {
          Get.to(() => ThreadDetailPage(threadId: id));
          return;
        }
      }
      final blogMatch = RegExp(r'/blog-entries/[^/]+\.(\d+)').firstMatch(url);
      if (blogMatch != null) {
        final id = int.tryParse(blogMatch.group(1)!);
        if (id != null && id > 0) {
          Get.to(() => BlogDetailPage(entryId: id));
          return;
        }
      }
    }

    AppToast.error('Contenuto non disponibile nell\'app.');
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.brandPrimary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Reazioni ricevute'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => _load(),
                          child: const Text('Riprova'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    if (_tabs.isNotEmpty) _ReactionTabsBar(
                      tabs: _tabs,
                      selectedId: _selectedReactionId,
                      onSelect: (id) => _load(reactionId: id),
                    ),
                    Expanded(
                      child: _items.isEmpty
                          ? const Center(
                              child: Text('Nessuna reazione in questa categoria.'),
                            )
                          : ListView.separated(
                              controller: _scroll,
                              itemCount: _items.length + (_loadingMore ? 1 : 0),
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, i) {
                                if (i >= _items.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return _ReceivedReactionTile(
                                  item: _items[i],
                                  dateFormat: fmt,
                                  onUserTap: (userId) =>
                                      OmnifeedNavigation.openUserProfile(
                                    userId,
                                  ),
                                  onContentTap: () => _openContent(_items[i]),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _ReactionTabsBar extends StatelessWidget {
  const _ReactionTabsBar({
    required this.tabs,
    required this.selectedId,
    required this.onSelect,
  });

  final List<AccountReactionTab> tabs;
  final int selectedId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SizedBox(
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final tab = tabs[i];
            final selected = tab.reactionId == selectedId;
            return InkWell(
              onTap: () => onSelect(tab.reactionId),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.brandPrimary.withValues(alpha: 0.12)
                      : AppTheme.feedItemChromeBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected
                        ? AppTheme.brandPrimary
                        : AppTheme.cardBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab.reactionId == 0)
                      Icon(
                        Icons.apps,
                        size: 16,
                        color: selected
                            ? AppTheme.brandPrimary
                            : AppTheme.textSecondary,
                      )
                    else if (tab.imageUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: tab.imageUrl,
                        width: 16,
                        height: 16,
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.thumb_up,
                          size: 16,
                        ),
                      )
                    else
                      FeedReactionIcon(
                        visitorReactionId: tab.reactionId,
                        size: 16,
                        fallbackColor: AppTheme.textSecondary,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      '${tab.title} (${tab.total})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected
                            ? AppTheme.brandPrimary
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReceivedReactionTile extends StatelessWidget {
  const _ReceivedReactionTile({
    required this.item,
    required this.dateFormat,
    required this.onUserTap,
    required this.onContentTap,
  });

  final Map<String, dynamic> item;
  final DateFormat dateFormat;
  final ValueChanged<int> onUserTap;
  final VoidCallback onContentTap;

  @override
  Widget build(BuildContext context) {
    final userRaw = item['reaction_user'];
    final user = userRaw is Map
        ? AccountUserRef.fromJson(Map<String, dynamic>.from(userRaw))
        : null;
    final date = item['reaction_date'] as int? ?? 0;
    final reactionId = item['reaction_id'] as int? ?? 0;
    final reactionTitle = item['reaction_title']?.toString() ?? 'reazione';
    final contentTitle = item['content_title']?.toString().trim().isNotEmpty == true
        ? item['content_title'].toString()
        : _fallbackContentLabel(item);
    final reactionImage = item['reaction_image_url']?.toString() ?? '';

    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: user == null || user.userId <= 0
                  ? null
                  : () => onUserTap(user.userId),
              child: _Avatar(url: user?.avatarUrl, name: user?.username ?? '?'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: user == null || user.userId <= 0
                            ? null
                            : () => onUserTap(user.userId),
                        child: Text(
                          user?.username.isNotEmpty == true
                              ? user!.username
                              : 'Utente',
                          style: const TextStyle(
                            color: AppTheme.authorName,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const Text(
                        ' ha reagito con ',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      if (reactionImage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: CachedNetworkImage(
                            imageUrl: ApiUrl.resolve(reactionImage),
                            width: 16,
                            height: 16,
                            errorWidget: (_, __, ___) => FeedReactionIcon(
                              visitorReactionId: reactionId,
                              size: 16,
                              fallbackColor: AppTheme.brandPrimary,
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: FeedReactionIcon(
                            visitorReactionId: reactionId,
                            size: 16,
                            fallbackColor: AppTheme.brandPrimary,
                          ),
                        ),
                      Text(
                        ' $reactionTitle',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'al tuo contenuto',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: onContentTap,
                    child: Text(
                      contentTitle,
                      style: const TextStyle(
                        color: AppTheme.linkBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (date > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      dateFormat.format(
                        DateTime.fromMillisecondsSinceEpoch(date * 1000),
                      ),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fallbackContentLabel(Map<String, dynamic> item) {
    final type = item['content_type']?.toString() ?? 'contenuto';
    final id = item['content_id'] ?? '';
    return '$type #$id';
  }
}

class AccountBookmarksPage extends StatefulWidget {
  const AccountBookmarksPage({super.key});

  @override
  State<AccountBookmarksPage> createState() => _AccountBookmarksPageState();
}

class _AccountBookmarksPageState extends State<AccountBookmarksPage> {
  final _service = AccountListService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.fetchBookmarks();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppToast.mapApiError(e.toString());
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return _AccountListScaffold(
      title: 'Segnalibri',
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyLabel: 'Nessun elemento salvato.',
      isEmpty: _items.isEmpty,
      child: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final item = _items[i];
          final date = item['bookmark_date'] as int? ?? 0;
          return ListTile(
            leading: const Icon(Icons.bookmark, color: AppTheme.primary),
            title: Text(item['title']?.toString() ?? 'Elemento salvato'),
            subtitle: Text(
              [
                item['content_type']?.toString() ?? '',
                if (date > 0)
                  fmt.format(DateTime.fromMillisecondsSinceEpoch(date * 1000)),
              ].where((e) => e.isNotEmpty).join(' · '),
            ),
          );
        },
      ),
    );
  }
}

class AccountWalletPage extends StatefulWidget {
  const AccountWalletPage({super.key});

  @override
  State<AccountWalletPage> createState() => _AccountWalletPageState();
}

class _AccountWalletPageState extends State<AccountWalletPage> {
  final _service = AccountListService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchWallet();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppToast.mapApiError(e.toString());
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _data?['enabled'] == true;
    final balances = (_data?['balances'] is List)
        ? (_data!['balances'] as List).whereType<Map>().toList()
        : <Map>[];
    final txns = (_data?['recent_transactions'] is List)
        ? (_data!['recent_transactions'] as List).whereType<Map>().toList()
        : <Map>[];

    return _AccountListScaffold(
      title: 'Wallet',
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyLabel: enabled ? 'Nessun saldo.' : 'Wallet non disponibile.',
      isEmpty: !enabled || (balances.isEmpty && txns.isEmpty),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Saldi',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          for (final b in balances)
            Card(
              child: ListTile(
                title: Text(b['title']?.toString() ?? b['currency_id']?.toString() ?? ''),
                trailing: Text(
                  '${b['symbol'] ?? ''} ${b['balance'] ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          if (txns.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Movimenti recenti',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            for (final t in txns)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${t['type']} · ${t['currency_id']} ${t['amount']}'),
                subtitle: Text(t['note']?.toString() ?? ''),
              ),
          ],
        ],
      ),
    );
  }
}

class AccountUpgradesPage extends StatefulWidget {
  const AccountUpgradesPage({super.key});

  @override
  State<AccountUpgradesPage> createState() => _AccountUpgradesPageState();
}

class _AccountUpgradesPageState extends State<AccountUpgradesPage> {
  final _service = AccountListService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchUpgrades();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppToast.mapApiError(e.toString());
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = (_data?['active'] is List)
        ? (_data!['active'] as List).whereType<Map>().toList()
        : <Map>[];
    final available = (_data?['available'] is List)
        ? (_data!['available'] as List).whereType<Map>().toList()
        : <Map>[];

    return _AccountListScaffold(
      title: 'Upgrade account',
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyLabel: 'Nessun upgrade disponibile.',
      isEmpty: active.isEmpty && available.isEmpty,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (active.isNotEmpty) ...[
            const Text('Attivi', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final u in active)
              Card(
                child: ListTile(
                  title: Text(u['title']?.toString() ?? 'Upgrade'),
                  subtitle: Text(
                    (u['end_date'] as int? ?? 0) > 0
                        ? 'Scade: ${DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch((u['end_date'] as int) * 1000))}'
                        : 'Illimitato',
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
          if (available.isNotEmpty) ...[
            const Text('Disponibili', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final u in available)
              Card(
                child: ListTile(
                  title: Text(u['title']?.toString() ?? 'Upgrade'),
                  subtitle: Text(
                    [
                      if ((u['description']?.toString() ?? '').isNotEmpty)
                        u['description'].toString(),
                      '${u['cost_amount']} ${u['cost_currency']}',
                    ].join('\n'),
                  ),
                  isThreeLine: true,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class AccountConnectedPage extends StatefulWidget {
  const AccountConnectedPage({super.key});

  @override
  State<AccountConnectedPage> createState() => _AccountConnectedPageState();
}

class _AccountConnectedPageState extends State<AccountConnectedPage> {
  final _service = AccountListService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.fetchConnectedAccounts();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppToast.mapApiError(e.toString());
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AccountListScaffold(
      title: 'Account connessi',
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyLabel: 'Nessun provider configurato.',
      isEmpty: _items.isEmpty,
      child: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final item = _items[i];
          final linked = item['is_associated'] == true;
          return ListTile(
            leading: Icon(
              linked ? Icons.link : Icons.link_off,
              color: linked ? AppTheme.primary : AppTheme.textSecondary,
            ),
            title: Text(item['title']?.toString() ?? item['provider_id']?.toString() ?? ''),
            subtitle: Text(linked ? 'Collegato' : 'Non collegato'),
          );
        },
      ),
    );
  }
}

class AccountApplicationsPage extends StatefulWidget {
  const AccountApplicationsPage({super.key});

  @override
  State<AccountApplicationsPage> createState() =>
      _AccountApplicationsPageState();
}

class _AccountApplicationsPageState extends State<AccountApplicationsPage> {
  final _service = AccountListService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.fetchApplications();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppToast.mapApiError(e.toString());
        _loading = false;
      });
    }
  }

  Future<void> _revoke(Map<String, dynamic> item) async {
    final id = item['token_id'] as int? ?? 0;
    if (id <= 0) return;
    try {
      await _service.revokeApplication(id);
      setState(() => _items.removeWhere((e) => e['token_id'] == id));
      AppToast.success('Autorizzazione revocata.');
    } catch (e) {
      AppToast.error(AppToast.mapApiError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AccountListScaffold(
      title: 'Applicazioni',
      loading: _loading,
      error: _error,
      onRetry: _load,
      emptyLabel: 'Nessuna applicazione autorizzata.',
      isEmpty: _items.isEmpty,
      child: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final item = _items[i];
          return ListTile(
            leading: const Icon(Icons.apps_outlined),
            title: Text(item['title']?.toString() ?? 'App'),
            subtitle: Text(item['client_id']?.toString() ?? ''),
            trailing: TextButton(
              onPressed: () => _revoke(item),
              child: const Text('Revoca'),
            ),
          );
        },
      ),
    );
  }
}

class _AccountListScaffold extends StatelessWidget {
  const _AccountListScaffold({
    required this.title,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.emptyLabel,
    required this.isEmpty,
    required this.child,
  });

  final String title;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final String emptyLabel;
  final bool isEmpty;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.brandPrimary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(title),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: onRetry,
                          child: const Text('Riprova'),
                        ),
                      ],
                    ),
                  ),
                )
              : isEmpty
                  ? Center(child: Text(emptyLabel))
                  : child,
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, this.trailing});

  final AccountUserRef user;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _Avatar(url: user.avatarUrl, name: user.username),
      title: Text(user.username),
      subtitle: user.userTitle.isNotEmpty ? Text(user.userTitle) : null,
      trailing: trailing,
      onTap: () => OmnifeedNavigation.openUserProfile(user.userId),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(backgroundImage: CachedNetworkImageProvider(url!));
    }
    return CircleAvatar(
      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
    );
  }
}
