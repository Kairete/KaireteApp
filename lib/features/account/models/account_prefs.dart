class AccountPrefs {
  AccountPrefs({
    required this.userId,
    required this.username,
    this.email = '',
    this.location = '',
    this.website = '',
    this.about = '',
    this.signature = '',
    this.customTitle = '',
    this.timezone = 'Europe/Rome',
    this.visible = true,
    this.activityVisible = true,
    this.contentShowSignature = true,
    this.emailOnConversation = true,
    this.pushOnConversation = true,
    this.receiveAdminEmail = false,
    this.creationWatchState = 'watch_email',
    this.interactionWatchState = 'watch_email',
    this.allowViewProfile = 'everyone',
    this.allowPostProfile = 'members',
    this.allowReceiveNewsFeed = 'everyone',
    this.allowSendPersonalConversation = 'members',
    this.allowViewIdentities = 'everyone',
    this.showDobDate = true,
    this.showDobYear = false,
    this.useTfa = false,
  });

  final int userId;
  final String username;
  final String email;
  final String location;
  final String website;
  final String about;
  final String signature;
  final String customTitle;
  final String timezone;
  final bool visible;
  final bool activityVisible;
  final bool contentShowSignature;
  final bool emailOnConversation;
  final bool pushOnConversation;
  final bool receiveAdminEmail;
  final String creationWatchState;
  final String interactionWatchState;
  final String allowViewProfile;
  final String allowPostProfile;
  final String allowReceiveNewsFeed;
  final String allowSendPersonalConversation;
  final String allowViewIdentities;
  final bool showDobDate;
  final bool showDobYear;
  final bool useTfa;

  factory AccountPrefs.fromApi(Map<String, dynamic> json) {
    final me = json['me'] as Map<String, dynamic>? ??
        json['user'] as Map<String, dynamic>? ??
        json;
    return AccountPrefs(
      userId: _int(me['user_id']),
      username: me['username']?.toString() ?? '',
      email: me['email']?.toString() ?? '',
      location: me['location']?.toString() ?? '',
      website: me['website']?.toString() ?? '',
      about: me['about']?.toString() ?? '',
      signature: me['signature']?.toString() ?? '',
      customTitle: me['custom_title']?.toString() ?? '',
      timezone: me['timezone']?.toString() ?? 'Europe/Rome',
      visible: me['visible'] == true,
      activityVisible: me['activity_visible'] == true,
      contentShowSignature: me['content_show_signature'] == true,
      emailOnConversation: me['email_on_conversation'] == true,
      pushOnConversation: me['push_on_conversation'] == true,
      receiveAdminEmail: me['receive_admin_email'] == true,
      creationWatchState: me['creation_watch_state']?.toString() ?? 'watch_email',
      interactionWatchState:
          me['interaction_watch_state']?.toString() ?? 'watch_email',
      allowViewProfile: me['allow_view_profile']?.toString() ?? 'everyone',
      allowPostProfile: me['allow_post_profile']?.toString() ?? 'members',
      allowReceiveNewsFeed:
          me['allow_receive_news_feed']?.toString() ?? 'everyone',
      allowSendPersonalConversation:
          me['allow_send_personal_conversation']?.toString() ?? 'members',
      allowViewIdentities:
          me['allow_view_identities']?.toString() ?? 'everyone',
      showDobDate: me['show_dob_date'] == true,
      showDobYear: me['show_dob_year'] == true,
      useTfa: me['use_tfa'] == true,
    );
  }

  static int _int(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }

  static const privacyChoices = <(String, String)>[
    ('everyone', 'Tutti'),
    ('members', 'Solo membri'),
    ('followed', 'Solo chi seguo'),
    ('none', 'Nessuno'),
  ];

  static const watchChoices = <(String, String)>[
    ('', 'Nessun watch'),
    ('watch_no_email', 'Watch senza email'),
    ('watch_email', 'Watch con email'),
  ];

  static const timezones = <String>[
    'Europe/Rome',
    'Europe/London',
    'Europe/Paris',
    'Europe/Berlin',
    'Europe/Madrid',
    'Europe/Zurich',
    'UTC',
    'America/New_York',
    'America/Los_Angeles',
    'America/Sao_Paulo',
    'Asia/Dubai',
    'Asia/Tokyo',
    'Australia/Sydney',
  ];
}
