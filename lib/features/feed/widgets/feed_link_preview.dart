import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Preview link stile Facebook (immagine + dominio + titolo).
class FeedLinkPreviewData {
  const FeedLinkPreviewData({
    required this.url,
    required this.title,
    this.description = '',
    this.imageUrl,
    this.faviconUrl,
    this.domain = '',
  });

  final String url;
  final String title;
  final String description;
  final String? imageUrl;
  final String? faviconUrl;
  final String domain;

  factory FeedLinkPreviewData.fromJson(Map<String, dynamic> json) {
    final url = json['url']?.toString().trim() ?? '';
    final title = json['title']?.toString().trim() ?? '';
    var domain = json['domain']?.toString().trim() ?? '';
    if (domain.isEmpty && url.isNotEmpty) {
      domain = Uri.tryParse(url)?.host ?? '';
      if (domain.startsWith('www.')) {
        domain = domain.substring(4);
      }
    }
    final image = json['image_url']?.toString().trim();
    final favicon = json['favicon_url']?.toString().trim();
    return FeedLinkPreviewData(
      url: url,
      title: title,
      description: json['description']?.toString().trim() ?? '',
      imageUrl: (image != null && image.isNotEmpty) ? image : null,
      faviconUrl: (favicon != null && favicon.isNotEmpty) ? favicon : null,
      domain: domain,
    );
  }

  static List<FeedLinkPreviewData> listFromJson(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => FeedLinkPreviewData.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.url.isNotEmpty && e.title.isNotEmpty)
        .toList(growable: false);
  }
}

class FeedLinkPreview extends StatelessWidget {
  const FeedLinkPreview({super.key, required this.previews});

  final List<FeedLinkPreviewData> previews;

  @override
  Widget build(BuildContext context) {
    if (previews.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (var i = 0; i < previews.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _FeedLinkPreviewCard(preview: previews[i]),
        ],
      ],
    );
  }
}

class _FeedLinkPreviewCard extends StatelessWidget {
  const _FeedLinkPreviewCard({required this.preview});

  final FeedLinkPreviewData preview;

  Future<void> _open() async {
    final uri = Uri.tryParse(preview.url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final domain = preview.domain.toUpperCase();
    return Material(
      color: const Color(0xFFF0F2F5),
      child: InkWell(
        onTap: _open,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (preview.imageUrl != null)
              CachedNetworkImage(
                imageUrl: preview.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (domain.isNotEmpty)
                    Text(
                      domain,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF65676B),
                        letterSpacing: 0.2,
                        height: 1.2,
                      ),
                    ),
                  if (domain.isNotEmpty) const SizedBox(height: 4),
                  Text(
                    preview.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF050505),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
