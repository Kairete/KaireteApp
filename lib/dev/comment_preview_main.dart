import 'package:flutter/material.dart';
import 'package:kairete/config/app_branding.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';

/// Anteprima commenti nidificati: `flutter run -d chrome -t lib/dev/comment_preview_main.dart`
void main() {
  AppTheme.applyBranding(AppBrandingProfile.hub());
  runApp(const CommentPreviewApp());
}

class CommentPreviewApp extends StatelessWidget {
  const CommentPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anteprima commenti',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const CommentPreviewPage(),
    );
  }
}

class CommentPreviewPage extends StatelessWidget {
  const CommentPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(title: const Text('Anteprima date commenti')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          FeedCardShell(
            header: FeedCardHeaderBar(
              child: Row(
                children: [
                  const FeedCardAvatar(name: 'Marco', size: 36),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marco',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.authorName,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '2 ore fa',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const FeedCardMenuButton(),
                ],
              ),
            ),
            body: const Padding(
              padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Text(
                'Grande partita ieri! Difesa solida e centrocampo che ha dominato.',
                style: TextStyle(fontSize: 15, height: 1.3),
              ),
            ),
            footer: const FeedCardActionBar(
              commentCount: 5,
              likeCount: 24,
            ),
            comments: [
              FeedNestedCommentThread(
                comments: const [
                  FeedNestedCommentData(
                    id: 1,
                    parentId: 0,
                    authorName: 'Marco',
                    dateLabel: '2 ore fa',
                    message:
                        'Grande partita ieri! Difesa solida e centrocampo che ha dominato.',
                    likeCount: 12,
                  ),
                  FeedNestedCommentData(
                    id: 2,
                    parentId: 1,
                    authorName: 'Luca77',
                    dateLabel: '1 ora fa',
                    message:
                        'Sono d\'accordo Marco! La squadra sembra più matura quest\'anno.',
                    likeCount: 8,
                  ),
                  FeedNestedCommentData(
                    id: 3,
                    parentId: 0,
                    authorName: 'Paolo',
                    dateLabel: '1 g',
                    message: 'Ieri sera ero allo stadio, atmosfera incredibile.',
                    likeCount: 5,
                  ),
                  FeedNestedCommentData(
                    id: 4,
                    parentId: 0,
                    authorName: 'Sara',
                    dateLabel: '2 g',
                    message: 'Champions in vista, dobbiamo restare concentrati.',
                    likeCount: 3,
                  ),
                  FeedNestedCommentData(
                    id: 5,
                    parentId: 0,
                    authorName: 'Admin',
                    dateLabel: '10 mar 2026',
                    message: 'Commento più vecchio con data assoluta.',
                    likeCount: 1,
                  ),
                ],
                onReplyTap: null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
