import 'package:flutter/material.dart';

class SocialNewsPreviewArticle {
  const SocialNewsPreviewArticle({
    required this.title,
    required this.dateLabel,
    this.lead,
    this.commentCount = 0,
  });

  final String title;
  final String dateLabel;
  final String? lead;
  final int commentCount;
}

class SocialNewsPreviewCategory {
  const SocialNewsPreviewCategory({
    required this.title,
    required this.color,
    required this.articles,
  });

  final String title;
  final Color color;
  final List<SocialNewsPreviewArticle> articles;
}

/// Dati finti per anteprima layout (stile Saker Italia).
class SocialNewsPreviewData {
  static const publicationTitle = 'Test Giornale';

  static final sitrep = SocialNewsPreviewCategory(
    title: 'SITREP',
    color: const Color(0xFFCC0000),
    articles: const [
      SocialNewsPreviewArticle(
        title: 'Aggiornamento operativo: linea del fronte',
        dateLabel: '6 agosto 2026',
        lead:
            'Sintesi dell\'articolo in evidenza con testo introduttivo che occupa due o tre righe.',
        commentCount: 11,
      ),
      SocialNewsPreviewArticle(
        title: 'Secondo articolo sidebar',
        dateLabel: '5 agosto 2026',
      ),
      SocialNewsPreviewArticle(
        title: 'Terzo articolo sidebar',
        dateLabel: '4 agosto 2026',
      ),
    ],
  );

  static final economia = SocialNewsPreviewCategory(
    title: 'ECONOMIA',
    color: const Color(0xFF666666),
    articles: const [
      SocialNewsPreviewArticle(
        title: 'La responsabilità fiscale in Italia ed in Olanda',
        dateLabel: '15 aprile 2020',
      ),
      SocialNewsPreviewArticle(
        title: 'La politica monetaria della BCE',
        dateLabel: '12 aprile 2020',
      ),
      SocialNewsPreviewArticle(
        title: 'Crescita e inflazione nel Q2',
        dateLabel: '10 aprile 2020',
      ),
      SocialNewsPreviewArticle(
        title: 'Mercati: outlook settimanale',
        dateLabel: '8 aprile 2020',
      ),
    ],
  );

  static final breaking = SocialNewsPreviewCategory(
    title: 'Breaking',
    color: const Color(0xFF222222),
    articles: const [
      SocialNewsPreviewArticle(
        title: 'Aggiornamento sul giorno 116 della SMO liberatrice',
        dateLabel: '22 giugno 2022',
        commentCount: 11,
      ),
    ],
  );

  static final italia = SocialNewsPreviewCategory(
    title: 'ITALIA',
    color: const Color(0xFF2E7D32),
    articles: const [
      SocialNewsPreviewArticle(
        title: 'La politica estera italiana e le alleanze',
        dateLabel: '15 aprile 2020',
      ),
      SocialNewsPreviewArticle(
        title: 'Dibattito parlamentare sulla difesa',
        dateLabel: '14 aprile 2020',
      ),
    ],
  );
}
