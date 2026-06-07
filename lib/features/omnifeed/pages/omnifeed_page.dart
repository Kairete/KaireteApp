import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_card.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_content_filters.dart';

class OmnifeedPage extends StatelessWidget {
  const OmnifeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OmnifeedController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => OmnifeedContentFilters(
            selectedModeIndex: c.feedModeIndex.value,
            sortByLastComment: c.sortByLastComment.value,
            onModeSelected: c.setFeedModeIndex,
            onSortChanged: c.setSortByLastComment,
          ),
        ),
        Expanded(
          child: Obx(() {
            if (c.isLoading.value && c.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (c.errorMessage.value.isNotEmpty && c.items.isEmpty) {
              return _ErrorState(
                message: c.errorMessage.value,
                onRetry: c.loadFeed,
              );
            }
            return RefreshIndicator(
              onRefresh: c.loadFeed,
              child: c.items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('Nessun contenuto nel feed.')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: c.items.length,
                      itemBuilder: (_, i) {
                        final item = c.items[i];
                        return OmnifeedCard(
                          item: item,
                          onOpen: () => c.openDetail(item),
                          onComment: () => c.openDetail(item),
                          onReact: (reactionId) =>
                              c.react(item, reactionId: reactionId),
                        );
                      },
                    ),
            );
          }),
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
