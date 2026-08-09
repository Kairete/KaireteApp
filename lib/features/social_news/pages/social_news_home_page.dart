import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/social_news/controllers/social_news_home_controller.dart';
import 'package:kairete/features/social_news/widgets/social_news_home_widgets.dart';

class SocialNewsHomePage extends StatelessWidget {
  const SocialNewsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SocialNewsHomeController>();

    return Obx(() {
      if (controller.isLoading.value && controller.homepage.value == null) {
        return Center(
          child: CircularProgressIndicator(color: AppTheme.brandPrimary),
        );
      }
      if (controller.errorMessage.value.isNotEmpty &&
          controller.homepage.value == null) {
        return _ErrorState(
          message: controller.errorMessage.value,
          onRetry: controller.loadHomepage,
        );
      }

      final homepage = controller.homepage.value;
      if (homepage == null || homepage.blocks.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.loadHomepage,
          child: ListView(
            children: const [
              SizedBox(height: 120),
              Center(child: Text('Nessun articolo disponibile.')),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadHomepage,
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          children: [
            if (controller.publicationTitle.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  controller.publicationTitle.value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
            for (final block in homepage.blocks)
              SocialNewsHomeBlockWidget(block: block),
          ],
        ),
      );
    });
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Riprova')),
          ],
        ),
      ),
    );
  }
}
