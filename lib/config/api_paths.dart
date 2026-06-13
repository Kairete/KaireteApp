class ApiPaths {
  ApiPaths._();

  static const auth = 'api/auth';
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
  static const mobileDeviceSessions = 'api/mobile/device-sessions';
  static const mobileDeviceSessionsRestore =
      'api/mobile/device-sessions/restore-by-device';

  // OmniFeed / newsfeed (XenForo add-on API)
  static const newsfeed = 'api/newsfeed';
  static const newsfeedPost = 'api/newsfeed/post';
  static const newsfeedBlogPost = 'api/newsfeed/blog-post';
  static const newsfeedUserFeed = 'api/newsfeed/user-feed';
  static const newsfeedForumWatch = 'api/newsfeed/forum-watch';
  static const newsfeedAlbumWatch = 'api/newsfeed/album-watch';
  static const newsfeedMediaUpload = 'api/newsfeed/media-upload/';
  static const newsfeedComposeAttachments = 'api/newsfeed/compose-attachments';
  static const newsfeedItems = 'api/newsfeed-items/';
  static const newsfeedComments = 'api/newsfeed-items/';
  static const newsfeedCommentReplies = 'api/newsfeed-comments/';
  static const profilePosts = 'api/profile-posts';
  static const groupPosts = 'api/group-posts/';
  static const attachments = 'api/attachments/';

  // Kairete Blog (XenForo REST)
  static const blogEntries = 'api/blog-entries';
  static const blogCategories = 'api/blog-categories';
  static const blogs = 'api/blogs/';

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
  static const mediaAlbums = 'api/media-albums/';
  static const mediaCategories = 'api/media-categories/';
  static const mediaComments = 'api/media-comments';
}
