class ApiPaths {
  ApiPaths._();

  static const auth = 'api/auth';
  static const authLoginToken = 'api/auth/login-token';
  static const users = 'api/users';
  static const me = 'api/me';
  static const alerts = 'api/alerts/';

  // Multisite mobile
  static const msTenants = 'api/ms-tenants';
  static String msTenantBootstrap(int tenantId) =>
      'api/ms-tenants/$tenantId/bootstrap';
  static String msTenantMappedUserFeed(int tenantId, int userId) =>
      'api/ms-tenants/$tenantId/users/$userId/mapped-feed';
  static String msTenantMappedForums(int tenantId) =>
      'api/ms-tenants/$tenantId/forums';
  static String msTenantMappedBlogEntries(int tenantId) =>
      'api/ms-tenants/$tenantId/blog-entries';
  static String msTenantCommunityFeed(int tenantId) =>
      'api/ms-tenants/$tenantId/community-feed';
  static const mobileDeviceSessions = 'api/ms-device-sessions';
  static const mobileDeviceSessionsRestore =
      'api/ms-device-sessions/restore-by-device';
  static const mobileDevicePresence = 'api/ms-device-sessions/presence';

  // Mobile account (Multisite) — one unique prefix per endpoint
  static const mobileAccountFollowing = 'api/ms-account-following';
  static const mobileAccountIgnored = 'api/ms-account-ignored';
  static const mobileAccountReactions = 'api/ms-account-reactions';
  static const mobileAccountBookmarks = 'api/ms-account-bookmarks';
  static const mobileAccountWallet = 'api/ms-account-wallet';
  static const mobileAccountUpgrades = 'api/ms-account-upgrades';
  static const mobileAccountConnected = 'api/ms-account-connected';
  static const mobileAccountApplications = 'api/ms-account-applications';

  // App Widgets — via OmniFeed (route affidabile); ACP resta Kairete/AppWidgets
  static const appWidgets = 'api/newsfeed/app-widgets';

  // Suggestions — via OmniFeed (route affidabile); add-on Kairete/Suggestions
  static const suggestions = 'api/newsfeed/suggestions';
  static const suggestionsDismiss = 'api/newsfeed/suggestions-dismiss';
  static const suggestionsRestore = 'api/newsfeed/suggestions-restore';

  // OmniFeed / newsfeed (XenForo add-on API)
  static const newsfeed = 'api/newsfeed';
  static const newsfeedTabs = 'api/newsfeed/tabs';
  static const newsfeedTenantScope = 'api/newsfeed/tenant-scope';
  static const newsfeedPost = 'api/newsfeed/post';
  static const newsfeedBlogPost = 'api/newsfeed/blog-post';
  static const newsfeedUserFeed = 'api/newsfeed/user-feed';
  static const newsfeedUserProfilePosts = 'api/newsfeed/user-profile-posts';
  static const newsfeedForumWatch = 'api/newsfeed/forum-watch';
  static const newsfeedAlbumWatch = 'api/newsfeed/album-watch';
  static const newsfeedMediaUpload = 'api/newsfeed/media-upload/';
  static const newsfeedComposeAttachments = 'api/newsfeed/compose-attachments';
  static const newsfeedLinkPreview = 'api/newsfeed/link-preview';
  static const newsfeedHighlights = 'api/newsfeed/highlights';
  static const newsfeedItems = 'api/newsfeed-items/';
  static const newsfeedComments = 'api/newsfeed-items/';
  static const newsfeedCommentReplies = 'api/newsfeed-comments/';
  static const searchSuggest = 'api/search-suggest';
  static const search = 'api/search';
  static const userProfile = 'api/user-profile';
  static const userFollowing = 'api/user-following';
  static const userFollowers = 'api/user-followers';
  static const userProfileBanner = 'api/user-profile-banner';
  static const userReport = 'api/user-report';
  static const userFollow = 'api/user-follow';
  static const profilePosts = 'api/profile-posts';
  static const profilePostComments = 'api/profile-post-comments/';
  static const groupPosts = 'api/group-posts/';
  static const attachments = 'api/attachments/';

  // Kairete Blog (XenForo REST)
  static const blogEntries = 'api/blog-entries';
  static const blogCategories = 'api/blog-categories';
  static const blogs = 'api/blogs/';
  static const blogsForumLink = 'api/blogs/forum-link/';

  // Kairete Social News (via OmniFeed REST)
  static const socialNewsHomepage = 'api/newsfeed/social-news-homepage/';
  static const socialNewsHomepageLegacy = 'api/social-news/homepage/';
  static String socialNewsArticle(int articleId) =>
      'api/newsfeed/social-news-articles/$articleId/';
  static String socialNewsArticleLegacy(int articleId) =>
      'api/social-news/articles/$articleId/';
  static String socialNewsArticleComments(int articleId) =>
      'api/social-news/articles/$articleId/comments/';
  static String newsfeedItem(int itemId) => '${newsfeedItems}$itemId/';

  // XenForo forum
  static const nodes = 'api/nodes';
  static const forums = 'api/forums/';
  static const threads = 'api/threads';
  static const posts = 'api/posts/';
  static const reactions = 'api/reactions/';

  // Tag feed (XenForo Kairete/TagFeed add-on)
  static const tagFeed = 'api/tag-feed';
  static const tags = 'api/tags/';

  // Kairete Social Groups
  static const socialGroups = 'api/social-groups/';
  static const blogEntryComments = 'api/blog-entry-comments/';
  static const groupComments = 'api/group-comments/';

  // XenForo Media Gallery (XFMG)
  static const media = 'api/media/';
  static const kaireteMedia = 'api/kairete-media/';
  static const mediaAlbums = 'api/media-albums/';
  static const mediaCategories = 'api/media-categories/';
  static const mediaComments = 'api/media-comments';
}
