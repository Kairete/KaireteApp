class NavigationCounter {
  int? threads;
  int? amsArticles;
  int? ubsBlogEntries;
  int? alerts;
  int? conversations;

  NavigationCounter({
    this.threads,
    this.amsArticles,
    this.ubsBlogEntries,
    this.alerts,
    this.conversations,
  });

  factory NavigationCounter.fromJson(Map<String, dynamic> json) {
    return NavigationCounter(
      threads: json['threads'] as int?,
      amsArticles: json['ams_articles'] as int?,
      ubsBlogEntries: json['ubs_blog_entries'] as int?,
      alerts: json['alerts'] as int?,
      conversations: json['conversations'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'threads': threads,
        'ams_articles': amsArticles,
        'ubs_blog_entries': ubsBlogEntries,
        'alerts': alerts,
        'conversations': conversations,
      };

  String formatNumber(int number) {
    if (number >= 1000000000) {
      return (number / 1000000000).toStringAsFixed(1) + 'B';
    } else if (number >= 1000000) {
      return (number / 1000000).toStringAsFixed(1) + 'M';
    } else if (number >= 1000) {
      return (number / 1000).toStringAsFixed(1) + 'K';
    } else {
      return number.toString();
    }
  }
}
