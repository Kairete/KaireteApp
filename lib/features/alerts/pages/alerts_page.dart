import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/alerts/controllers/alerts_controller.dart';
import 'package:kairete/features/alerts/models/user_alert.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  @override
  void initState() {
    super.initState();
    Get.put(AlertsController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<AlertsController>()) {
      Get.delete<AlertsController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AlertsController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Notifiche'),
        actions: [
          Obx(() {
            if (controller.alerts.isEmpty) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.isMarkingAll.value
                  ? null
                  : controller.markAllRead,
              child: controller.isMarkingAll.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    )
                  : const Text(
                      'Segna tutte',
                      style: TextStyle(color: Colors.white),
                    ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.alerts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.alerts.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.loadAlerts,
          );
        }
        if (controller.alerts.isEmpty) {
          return const Center(
            child: Text(
              'Nessuna notifica.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadAlerts,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.alerts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final alert = controller.alerts[index];
              return _AlertTile(
                alert: alert,
                onTap: () => controller.openAlert(alert),
              );
            },
          ),
        );
      }),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.onTap});

  final UserAlert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = alert.isUnread || alert.isUnviewed;
    final text = alert.alertText?.trim() ?? '';

    return Material(
      color: unread ? const Color(0xFFE8F0FE) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FeedCardAvatar(url: alert.avatarUrl, name: alert.username),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (text.isNotEmpty)
                      Html(
                        data: text,
                        style: {
                          'body': Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontSize: FontSize(14),
                            lineHeight: const LineHeight(1.35),
                            color: AppTheme.textPrimary,
                          ),
                          'a': Style(
                            color: AppTheme.linkBlue,
                            textDecoration: TextDecoration.none,
                          ),
                        },
                        onLinkTap: (_, __, ___) => onTap(),
                      )
                    else
                      const Text(
                        'Nuova notifica',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    if (alert.eventDate != null && alert.eventDate! > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        formatOmnifeedDate(alert.eventDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (unread)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4, left: 6),
                  decoration: const BoxDecoration(
                    color: AppTheme.linkBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Riprova')),
          ],
        ),
      ),
    );
  }
}
