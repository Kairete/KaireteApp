import 'package:flutter/material.dart';
import 'package:kairete/config/app_branding.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/dev/social_news_layout_widgets.dart';
import 'package:kairete/dev/social_news_preview_data.dart';

/// Anteprima layout Social News:
/// `flutter run -d chrome -t lib/dev/social_news_preview_main.dart`
void main() {
  AppTheme.applyBranding(AppBrandingProfile.hub());
  runApp(const SocialNewsPreviewApp());
}

class SocialNewsPreviewApp extends StatelessWidget {
  const SocialNewsPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anteprima Social News',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const SocialNewsPreviewPage(),
    );
  }
}

class SocialNewsPreviewPage extends StatelessWidget {
  const SocialNewsPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Social News — Layout preview'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Web'),
              Tab(text: 'Mobile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _WebTab(),
            _MobileTab(),
          ],
        ),
      ),
    );
  }
}

class _WebTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            SocialNewsPreviewData.publicationTitle,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
        ),
        SocialNewsLayoutPreview(
          title: 'Web — Copertina full-width (full_cover)',
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            clipBehavior: Clip.antiAlias,
            child: SocialNewsFullCover(category: SocialNewsPreviewData.breaking),
          ),
        ),
        SocialNewsLayoutPreview(
          title: 'Web — Hero + lista laterale (hero_sidebar)',
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            clipBehavior: Clip.antiAlias,
            child: SocialNewsHeroSidebar(category: SocialNewsPreviewData.sitrep),
          ),
        ),
        SocialNewsLayoutPreview(
          title: 'Web — Griglia 4 colonne (grid_4col)',
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            clipBehavior: Clip.antiAlias,
            child: SocialNewsGrid4Col(category: SocialNewsPreviewData.economia),
          ),
        ),
      ],
    );
  }
}

class _MobileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            SocialNewsLayoutPreview(
              title: 'Mobile — In evidenza + lista (featured_list)',
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                clipBehavior: Clip.antiAlias,
                child: SocialNewsMobileFeaturedList(
                  category: SocialNewsPreviewData.sitrep,
                ),
              ),
            ),
            SocialNewsLayoutPreview(
              title: 'Mobile — Sezioni per categoria (category_sections)',
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                clipBehavior: Clip.antiAlias,
                child: SocialNewsMobileCategorySections(
                  category: SocialNewsPreviewData.italia,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
