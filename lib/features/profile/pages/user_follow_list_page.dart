import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/account/services/account_list_service.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/profile/services/profile_service.dart';

enum UserFollowListMode { following, followers }

class UserFollowListPage extends StatefulWidget {
  const UserFollowListPage({
    super.key,
    required this.userId,
    required this.username,
    required this.mode,
  });

  final int userId;
  final String username;
  final UserFollowListMode mode;

  @override
  State<UserFollowListPage> createState() => _UserFollowListPageState();
}

class _UserFollowListPageState extends State<UserFollowListPage> {
  final _service = ProfileService();
  List<AccountUserRef> _users = [];
  bool _loading = true;
  String? _error;

  bool get _isFollowing => widget.mode == UserFollowListMode.following;

  String get _title {
    final name = widget.username.trim();
    if (_isFollowing) {
      return name.isEmpty ? 'Seguiti' : 'Seguiti da $name';
    }
    return name.isEmpty ? 'Follower' : 'Follower di $name';
  }

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
      final users = _isFollowing
          ? await _service.fetchFollowingUsers(widget.userId)
          : await _service.fetchFollowerUsers(widget.userId);
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

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: Text(_title),
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
                          onPressed: _load,
                          child: const Text('Riprova'),
                        ),
                      ],
                    ),
                  ),
                )
              : _users.isEmpty
                  ? Center(
                      child: Text(
                        _isFollowing
                            ? 'Nessun utente seguito.'
                            : 'Nessun follower.',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _users.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final user = _users[i];
                          return _FollowUserTile(
                            user: user,
                            dateFormat: dateFmt,
                          );
                        },
                      ),
                    ),
    );
  }
}

class _FollowUserTile extends StatelessWidget {
  const _FollowUserTile({
    required this.user,
    required this.dateFormat,
  });

  final AccountUserRef user;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final numberFmt = NumberFormat.decimalPattern('it');
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => OmnifeedNavigation.openUserProfile(user.userId),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(url: user.avatarUrl, name: user.username),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        color: AppTheme.authorName,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.15,
                      ),
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
                    if (user.website.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Sito: ${user.website}',
                          style: const TextStyle(
                            color: AppTheme.linkBlue,
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
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11.5,
          height: 1.2,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: CachedNetworkImageProvider(url!),
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppTheme.primary.withOpacity(0.12),
      child: Text(initial, style: const TextStyle(color: AppTheme.primary)),
    );
  }
}
