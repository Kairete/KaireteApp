import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/forum/controllers/forum_list_controller.dart';
import 'package:kairete/features/forum/models/forum_node.dart';
import 'package:kairete/features/forum/widgets/forum_category_header.dart';
import 'package:kairete/features/forum/widgets/forum_node_row.dart';

class ForumListPage extends StatelessWidget {
  ForumListPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ForumListController>()) {
      Get.put(ForumListController());
    }
    final controller = Get.find<ForumListController>();

    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Forum'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.groups.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.groups.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.loadForums,
          );
        }
        if (controller.groups.isEmpty) {
          return const Center(child: Text('Nessun forum disponibile.'));
        }

        return RefreshIndicator(
          onRefresh: controller.loadForums,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const _ForumPageHeader(),
              for (var gi = 0; gi < controller.groups.length; gi++) ...[
                if (gi > 0) const SizedBox(height: 8),
                _ForumCategorySection(
                  group: controller.groups[gi],
                  onForumTap: controller.openForum,
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }
}

class _ForumPageHeader extends StatelessWidget {
  const _ForumPageHeader();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Text(
          'Forum',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary.withOpacity(0.95),
          ),
        ),
      ),
    );
  }
}

class _ForumCategorySection extends StatelessWidget {
  const _ForumCategorySection({
    required this.group,
    required this.onForumTap,
  });

  final ForumNodeGroup group;
  final void Function(ForumNode forum) onForumTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ForumCategoryHeader(title: group.title),
        for (var i = 0; i < group.forums.length; i++)
          ForumNodeRow(
            forum: group.forums[i],
            onTap: () => onForumTap(group.forums[i]),
            onSubForumTap: onForumTap,
            showDivider: i < group.forums.length - 1,
          ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Riprova')),
          ],
        ),
      ),
    );
  }
}
