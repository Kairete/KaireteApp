class NavigationCounters {
  int? threads;
  int? amsArticles;
  int? ubsBlogEntries;
  int? alerts;
  int? conversations;

  NavigationCounters({
    this.threads,
    this.amsArticles,
    this.ubsBlogEntries,
    this.alerts,
    this.conversations,
  });

  factory NavigationCounters.fromJson(Map<String, dynamic> json) {
    return NavigationCounters(
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
}
