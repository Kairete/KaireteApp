import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/groups/models/social_group.dart';
import 'package:kairete/features/groups/pages/group_detail_page.dart';
import 'package:kairete/features/groups/services/groups_service.dart';
import 'package:kairete/features/groups/widgets/group_cover_header.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

class GroupsListPage extends StatefulWidget {
  const GroupsListPage({super.key});

  @override
  State<GroupsListPage> createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  final GroupsService _service = GroupsService();
  List<SocialGroup> _groups = const [];
  bool _loading = true;
  String? _error;
  int? _joinLoadingGroupId;

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
      final page = await _service.fetchGroups();
      if (!mounted) return;
      setState(() {
        _groups = page.groups;
        _loading = false;
      });
    } on GroupsException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Impossibile caricare i gruppi.';
        _loading = false;
      });
    }
  }

  Future<void> _toggleMembership(SocialGroup group) async {
    if (_joinLoadingGroupId != null) return;
    setState(() => _joinLoadingGroupId = group.groupId);
    try {
      if (group.canJoin) {
        await _service.joinGroup(group.groupId);
        AppToast.success('Sei entrato nel gruppo.');
      } else if (group.canLeave) {
        await _service.leaveGroup(group.groupId);
        AppToast.success('Hai lasciato il gruppo.');
      }
      await _load();
    } on GroupsException catch (e) {
      AppToast.error(e.message);
    } finally {
      if (mounted) setState(() => _joinLoadingGroupId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Gruppi'),
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
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _groups.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Nessun gruppo disponibile.')),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _groups.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final group = _groups[index];
                            return _GroupCard(
                              group: group,
                              isJoinLoading:
                                  _joinLoadingGroupId == group.groupId,
                              onTap: () => Get.to(
                                () => GroupDetailPage(groupId: group.groupId),
                              ),
                              onJoinTap: () => _toggleMembership(group),
                            );
                          },
                        ),
                ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.onTap,
    required this.onJoinTap,
    required this.isJoinLoading,
  });

  final SocialGroup group;
  final VoidCallback onTap;
  final VoidCallback onJoinTap;
  final bool isJoinLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GroupCoverHeader(
              group: group,
              height: 120,
              onJoinTap: onJoinTap,
              isJoinLoading: isJoinLoading,
            ),
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (group.isMember)
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                      ],
                    ),
                    if (group.categoryTitle?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        group.categoryTitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${group.memberCount} membri · ${group.postCount} post',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (group.lastPostDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        formatOmnifeedCardDate(group.lastPostDate),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
