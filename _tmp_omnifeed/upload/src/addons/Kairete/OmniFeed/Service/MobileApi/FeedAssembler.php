<?php

namespace Kairete\OmniFeed\Service\MobileApi;

use Kairete\OmniFeed\BlogFeed;
use XF\Mvc\Entity\AbstractCollection;
use XF\Service\AbstractService;

/**
 * Costruisce il feed JSON per l'app mobile (stessa logica base del web OmniFeed).
 */
class FeedAssembler extends AbstractService
{
	public function buildUserFeed(int $targetUserId, int $page = 1, int $limit = 10, string $sort = 'post_date'): array
	{
		$visitor = \XF::visitor();
		if ($targetUserId <= 0) {
			return [
				'newsfeedItems' => [],
				'pagination' => $this->pagination(0, $page, $limit),
			];
		}

		/** @var \XF\Entity\User|null $profileUser */
		$profileUser = $this->em()->find('XF:User', $targetUserId);
		if (!$profileUser || !$profileUser->canView()) {
			return [
				'newsfeedItems' => [],
				'pagination' => $this->pagination(0, $page, $limit),
			];
		}

		$sort = $this->normalizeFeedSort($sort);
		$previewLimit = $this->getThreadPreviewCharLimit();
		$rawItems = $this->collectUserFeedRows($targetUserId, $previewLimit);
		\usort($rawItems, static function (array $a, array $b) use ($sort): int {
			$key = $sort === 'last_activity' ? 'activity_date' : 'sort_date';

			return ($b[$key] ?? 0) <=> ($a[$key] ?? 0);
		});

		$payloads = \array_map(static fn (array $row) => $row['payload'], $rawItems);
		$total = \count($payloads);
		$offset = \max(0, ($page - 1) * $limit);
		$pageItems = \array_slice($payloads, $offset, $limit);

		return [
			'newsfeedItems' => $pageItems,
			'pagination' => $this->pagination($total, $page, $limit, \count($pageItems)),
			'user_id' => $targetUserId,
			'sort' => $sort,
		];
	}

	public function buildFeed(string $mode = 'network', int $page = 1, int $limit = 10, string $sort = 'post_date'): array
	{
		$visitor = \XF::visitor();
		if (!$visitor->user_id) {
			return [
				'newsfeedItems' => [],
				'pagination' => $this->pagination(0, $page, $limit),
			];
		}

		$mode = $this->normalizeFeedMode($mode);
		if ($mode === 'tenant_group') {
			return $this->buildTenantGroupFeed($page, $limit, $sort);
		}

		$userId = (int) $visitor->user_id;
		$sort = $this->normalizeFeedSort($sort);
		$previewLimit = $this->getThreadPreviewCharLimit();

		$rawItems = $this->buildRawItems($userId, $mode, $previewLimit, $sort);
		$total = \count($rawItems);
		$offset = \max(0, ($page - 1) * $limit);
		$pageItems = \array_slice($rawItems, $offset, $limit);

		return [
			'newsfeedItems' => $pageItems,
			'pagination' => $this->pagination($total, $page, $limit, \count($pageItems)),
			'mode' => $mode,
			'sort' => $sort,
		];
	}

	protected function normalizeFeedMode(string $mode): string
	{
		$allowed = ['network', 'interests', 'following', 'all', 'followers', 'tenant_group'];
		$mode = \strtolower(\trim($mode));
		if ($mode === 'curated') {
			return 'network';
		}

		return \in_array($mode, $allowed, true) ? $mode : 'network';
	}

	public function buildTenantGroupFeed(int $page = 1, int $limit = 10, string $sort = 'post_date'): array
	{
		if (\class_exists(\Kairete\Multisite\Service\MobileApi\TenantScopedFeed::class)
			&& \class_exists(\Kairete\Multisite\Service\MobileApi\TenantContext::class))
		{
			$tenantId = \Kairete\Multisite\Service\MobileApi\TenantScopedFeed::resolveTenantIdFromApp($this->app());
			$tenant = \Kairete\Multisite\Service\MobileApi\TenantContext::resolveActiveTenant($this->app(), $tenantId);
			if ($tenant)
			{
				return (new \Kairete\Multisite\Service\MobileApi\TenantScopedFeed($this->app()))
					->buildCommunityFeed($tenant, $page, $limit, $sort);
			}
		}

		$sort = $this->normalizeFeedSort($sort);
		$groupId = $this->resolveTenantNewsfeedGroupId();
		if ($groupId <= 0 || !$this->socialGroupsAvailable()) {
			return [
				'newsfeedItems' => [],
				'pagination' => $this->pagination(0, $page, $limit),
				'mode' => 'tenant_group',
				'sort' => $sort,
			];
		}

		$previewLimit = $this->getThreadPreviewCharLimit();
		$rawItems = [];
		try {
			$posts = $this->finder('Kairete\SocialGroups:GroupPost')
				->where('group_id', $groupId)
				->where('post_state', 'visible')
				->with(['User', 'Group'])
				->order('post_date', 'DESC')
				->fetch();
			foreach ($posts as $post) {
				if (!$post->canView()) {
					continue;
				}
				$postDate = (int) $post->post_date;
				$rawItems[] = [
					'sort_date' => $postDate,
					'activity_date' => $this->resolveGroupPostActivityDate($post),
					'payload' => ApiSerializer::groupPost($post),
				];
			}
		} catch (\Throwable $e) {
			\XF::logException($e, false, 'OmniFeed API tenant_group: ');
		}

		if ($sort === 'last_activity') {
			\usort($rawItems, static fn (array $a, array $b): int => ($b['activity_date'] ?? 0) <=> ($a['activity_date'] ?? 0));
		} else {
			\usort($rawItems, static fn (array $a, array $b): int => ($b['sort_date'] ?? 0) <=> ($a['sort_date'] ?? 0));
		}

		$total = \count($rawItems);
		$offset = \max(0, ($page - 1) * $limit);
		$pageItems = \array_slice($rawItems, $offset, $limit);
		$payloads = \array_map(static fn (array $row) => $row['payload'], $pageItems);

		return [
			'newsfeedItems' => $payloads,
			'pagination' => $this->pagination($total, $page, $limit, \count($payloads)),
			'mode' => 'tenant_group',
			'sort' => $sort,
			'group_id' => $groupId,
		];
	}

	protected function resolveTenantNewsfeedGroupId(): int
	{
		if (!\class_exists(\Kairete\Multisite\Service\MobileApi\TenantContext::class)) {
			return 0;
		}

		$request = $this->app->request();
		$tenantId = (int) $request->getServer('HTTP_X_MS_TENANT_ID');
		if ($tenantId <= 0) {
			$tenantId = (int) $request->filter('tenant_id', 'uint');
		}
		if ($tenantId <= 0) {
			return 0;
		}

		/** @var \Kairete\Multisite\Entity\Tenant|null $tenant */
		$tenant = $this->em()->find('Kairete\Multisite:Tenant', $tenantId, ['Mappings']);
		if (!$tenant || !$tenant->active) {
			return 0;
		}

		if (\XF::visitor()->user_id) {
			try {
				(new \Kairete\Multisite\Service\Registration\TenantGroupJoiner($this->app()))
					->joinUserToTenantGroup(\XF::visitor(), $tenant);
			} catch (\Throwable $e) {
			}
		}

		return (new \Kairete\Multisite\Service\Homepage\Redirector($this->app()))
			->resolveSocialGroupId($tenant);
	}

	protected function normalizeFeedSort(string $sort): string
	{
		$sort = \strtolower(\trim($sort));

		return \in_array($sort, ['post_date', 'last_activity'], true) ? $sort : 'post_date';
	}

	public function getItemById(int $itemId): ?array
	{
		[$type, $nativeId] = ItemIdCodec::decode($itemId);
		if ($nativeId <= 0) {
			return null;
		}

		switch ($type) {
			case ItemIdCodec::TYPE_PROFILE_POST:
				/** @var \XF\Entity\ProfilePost|null $post */
				$post = $this->em()->find('XF:ProfilePost', $nativeId, ['User', 'ProfileUser']);
				if (!$post || !$post->canView()) {
					return null;
				}
				$this->hydrateProfilePostAttachments([$post]);

				return ApiSerializer::profilePost($post);

			case ItemIdCodec::TYPE_THREAD:
				/** @var \XF\Entity\Thread|null $thread */
				$thread = $this->em()->find('XF:Thread', $nativeId, ['User', 'Forum', 'FirstPost']);
				if (!$thread || !$thread->canView()) {
					return null;
				}
				$this->hydrateThreadAttachments([$thread]);

				return ApiSerializer::thread($thread);

			case ItemIdCodec::TYPE_GROUP_POST:
				if (!\class_exists(\Kairete\SocialGroups\Entity\GroupPost::class)) {
					return null;
				}
				/** @var \Kairete\SocialGroups\Entity\GroupPost|null $post */
				$post = $this->em()->find('Kairete\SocialGroups:GroupPost', $nativeId, ['User', 'Group']);
				if (!$post || !$post->canView()) {
					return null;
				}

				return ApiSerializer::groupPost($post);

			case ItemIdCodec::TYPE_MEDIA:
				if (!$this->mediaGalleryAvailable()) {
					return null;
				}
				/** @var \XF\MediaGallery\Entity\MediaItem|null $media */
				$media = $this->findMediaItem($nativeId, ['User', 'Album', 'Category']);
				if (!$media || !$media->canView()) {
					return null;
				}

				return ApiSerializer::media($media);

			default:
				return null;
		}
	}

	/**
	 * @return list<array<string, mixed>>
	 */
	public function getCommentsForItem(int $itemId): array
	{
		[$type, $nativeId] = ItemIdCodec::decode($itemId);
		if ($type !== ItemIdCodec::TYPE_PROFILE_POST || $nativeId <= 0) {
			return [];
		}

		/** @var \XF\Entity\ProfilePost|null $post */
		$post = $this->em()->find('XF:ProfilePost', $nativeId);
		if (!$post || !$post->canView()) {
			return [];
		}

		$comments = $this->finder('XF:ProfilePostComment')
			->where('profile_post_id', $nativeId)
			->where('message_state', 'visible')
			->with('User')
			->order('comment_date', 'ASC')
			->fetch();

		$out = [];
		foreach ($comments as $comment) {
			if (!$comment->canView()) {
				continue;
			}
			$out[] = ApiSerializer::profilePostComment($comment);
		}

		return $out;
	}

	/**
	 * @return list<array<string, mixed>>
	 */
	protected function buildRawItems(int $visitorUserId, string $mode, int $previewLimit, string $sort): array
	{
		if ($mode === 'interests') {
			$tags = $this->getInterestTagsForVisitor($visitorUserId);
			if ($tags === []) {
				return \array_map(
					static fn (array $row) => $row['payload'],
					\array_slice($this->mergeVisitorOwnFeedRows([], $visitorUserId, $previewLimit), 0, 100)
				);
			}

			$items = $this->collectFeedItemRows($visitorUserId, 'all', $previewLimit);
			$items = \array_values(\array_filter(
				$items,
				fn (array $row) => $this->feedRowMatchesInterestTags($row, $tags)
			));
			$items = $this->mergeVisitorOwnFeedRows($items, $visitorUserId, $previewLimit);
		} else {
			$items = $this->collectFeedItemRows($visitorUserId, $mode, $previewLimit);
			$items = $this->mergeVisitorOwnFeedRows($items, $visitorUserId, $previewLimit);
		}

		$sortKey = $sort === 'last_activity' ? 'activity_date' : 'sort_date';
		\usort($items, static function (array $a, array $b) use ($sortKey): int {
			return ((int) ($b[$sortKey] ?? 0)) <=> ((int) ($a[$sortKey] ?? 0));
		});

		return \array_map(static fn (array $row) => $row['payload'], \array_slice($items, 0, 100));
	}

	/**
	 * @return list<array{sort_date: int, activity_date: int, payload: array<string, mixed>}>
	 */
	protected function collectFeedItemRows(int $visitorUserId, string $mode, int $previewLimit): array
	{
		$items = [];
		$seen = [];

		$addRow = static function (array $row) use (&$items, &$seen): void {
			$payload = $row['payload'] ?? null;
			if (!\is_array($payload)) {
				return;
			}
			$itemId = (int) ($payload['item_id'] ?? 0);
			if ($itemId <= 0 || isset($seen[$itemId])) {
				return;
			}
			$seen[$itemId] = true;
			$items[] = $row;
		};

		try {
			$profilePosts = $this->getProfilePostsForMode($visitorUserId, $mode);
			$this->hydrateProfilePostAttachments($profilePosts);
			foreach ($profilePosts as $post) {
				if (!$post->canView()) {
					continue;
				}
				$postDate = (int) $post->post_date;
				$addRow([
					'sort_date' => $postDate,
					'activity_date' => $this->resolveProfilePostActivityDate($post),
					'payload' => ApiSerializer::profilePost($post),
				]);
			}
		} catch (\Throwable $e) {
			\XF::logException($e, false, 'OmniFeed API profile posts: ');
		}

		try {
			$threads = $this->getThreadsForMode($visitorUserId, $mode);
			$this->hydrateThreadAttachments($threads);
			foreach ($threads as $thread) {
				if (!$thread->canView()) {
					continue;
				}
				$preview = '';
				if ($thread->FirstPost) {
					$preview = ApiSerializer::messageToPlain((string) $thread->FirstPost->message, $previewLimit);
				}
				$postDate = (int) $thread->post_date;
				$addRow([
					'sort_date' => $postDate,
					'activity_date' => (int) ($thread->last_post_date ?: $postDate),
					'payload' => ApiSerializer::thread($thread, $preview),
				]);
			}
		} catch (\Throwable $e) {
			\XF::logException($e, false, 'OmniFeed API threads: ');
		}

		if ($this->socialGroupsAvailable()) {
			try {
				foreach ($this->getGroupPostsForMode($visitorUserId, $mode) as $post) {
					if (!$post->canView()) {
						continue;
					}
					$postDate = (int) $post->post_date;
					$addRow([
						'sort_date' => $postDate,
						'activity_date' => $this->resolveGroupPostActivityDate($post),
						'payload' => ApiSerializer::groupPost($post),
					]);
				}
			} catch (\Throwable $e) {
				\XF::logException($e, false, 'OmniFeed API groups: ');
			}
		}

		if (BlogFeed::isAvailable()) {
			try {
				foreach (BlogFeed::buildFeedItems($visitorUserId, $mode, $previewLimit) as $blogItem) {
					$blogPost = $blogItem['blogPost'] ?? null;
					if (!$blogPost) {
						continue;
					}
					$postDate = (int) ($blogItem['sort_date'] ?? $blogPost->post_date ?? 0);
					$addRow([
						'sort_date' => $postDate,
						'activity_date' => (int) ($blogItem['activity_date'] ?? $postDate),
						'payload' => $this->serializeBlogItem($blogItem, $blogPost),
					]);
				}
			} catch (\Throwable $e) {
				\XF::logException($e, false, 'OmniFeed API blog: ');
			}
		}

		if ($this->mediaGalleryAvailable()) {
			try {
				foreach ($this->getMediaItemsForMode($visitorUserId, $mode, $previewLimit) as $media) {
					if (!$media->canView()) {
						continue;
					}
					$postDate = (int) $media->media_date;
					$addRow([
						'sort_date' => $postDate,
						'activity_date' => (int) ($media->last_comment_date ?: $postDate),
						'payload' => ApiSerializer::media(
							$media,
							ApiSerializer::messageToPlain((string) ($media->description ?? ''), $previewLimit)
						),
					]);
				}
			} catch (\Throwable $e) {
				\XF::logException($e, false, 'OmniFeed API media: ');
			}
		}

		return $items;
	}

	protected function mediaGalleryAvailable(): bool
	{
		return \class_exists(\XF\MediaGallery\Entity\MediaItem::class);
	}

	protected function mediaItemFinder()
	{
		foreach (['XF:MediaItem', 'XFMG:MediaItem'] as $shortName) {
			try {
				return $this->finder($shortName);
			} catch (\Throwable $e) {
			}
		}

		return $this->finder('XF:MediaItem');
	}

	protected function findMediaItem(int $mediaId, array $with = [])
	{
		foreach (['XF:MediaItem', 'XFMG:MediaItem'] as $shortName) {
			try {
				$media = $this->em()->find($shortName, $mediaId, $with);
				if ($media) {
					return $media;
				}
			} catch (\Throwable $e) {
			}
		}

		return null;
	}

	/**
	 * @return iterable<\XF\MediaGallery\Entity\MediaItem>
	 */
	protected function getMediaItemsForMode(int $visitorUserId, string $mode, int $previewLimit)
	{
		$finder = $this->mediaItemFinder()
			->where('media_state', 'visible')
			->with(['User', 'Album', 'Category'])
			->order('media_date', 'DESC')
			->limit(40);

		switch ($mode) {
			case 'all':
				break;
			case 'following':
			case 'followers':
				$related = $this->getRelatedUserIdsByMode($visitorUserId, $mode);
				$finder->where('user_id', $related ?: -1);
				break;
			case 'network':
				$followed = $this->getFollowingUserIds($visitorUserId);
				$followed[] = $visitorUserId;
				$followed = \array_values(\array_unique(\array_map('intval', $followed)));
				$finder->where('user_id', $followed);
				break;
			default:
				return [];
		}

		return $finder->fetch();
	}

	protected function serializeBlogItem(array $blogItem, $blogPost): array
	{
		$plain = ApiSerializer::messageToPlain((string) ($blogItem['previewText'] ?? $blogPost->message ?? ''), 280);
		$blog = $blogPost->Blog ?? null;
		$category = $blogPost->BlogCategory ?? null;

		return [
			'item_id' => ItemIdCodec::encode(ItemIdCodec::TYPE_BLOG_POST, (int) $blogPost->post_id),
			'content_type' => 'ubs_blog_entry',
			'content_id' => (int) $blogPost->post_id,
			'ContentTitle' => (string) ($blogPost->title ?? ''),
			'message_plain_text' => $plain,
			'message_parsed' => $plain,
			'item_date' => (int) ($blogPost->post_date ?? 0),
			'comment_count' => (int) ($blogPost->comment_count ?? 0),
			'reaction_score' => (int) ($blogPost->reaction_score ?? 0),
			'visitor_reaction_id' => ApiSerializer::visitorReactionId($blogPost),
			'User' => ApiSerializer::user($blogPost->User ?? null),
			'Blog' => $blog
				? [
					'blog_id' => (int) $blog->blog_id,
					'title' => (string) ($blog->title ?? ''),
				]
				: null,
			'Category' => $category
				? [
					'category_id' => (int) $category->category_id,
					'title' => (string) ($category->title ?? ''),
				]
				: null,
			'Content' => [
				'Blog' => $blog
					? [
						'blog_id' => (int) $blog->blog_id,
						'title' => (string) ($blog->title ?? ''),
					]
					: null,
				'Category' => $category
					? [
						'category_id' => (int) $category->category_id,
						'title' => (string) ($category->title ?? ''),
					]
					: null,
			],
			'view_url' => (string) ($blogItem['openUrl'] ?? ''),
			'Attachments' => ApiSerializer::serializeAttachments($blogPost),
		];
	}

	protected function getProfilePostsForMode(int $visitorUserId, string $mode): AbstractCollection
	{
		$finder = $this->finder('XF:ProfilePost')
			->where('message_state', 'visible')
			->with('User')
			->order('post_date', 'DESC')
			->limit(40);

		switch ($mode) {
			case 'all':
				break;
			case 'following':
			case 'followers':
				$related = $this->getRelatedUserIdsByMode($visitorUserId, $mode);
				$finder->where('user_id', $related ?: -1);
				break;
			case 'network':
				$related = $this->getFollowingUserIds($visitorUserId);
				if ($related === []) {
					$finder->where('profile_post_id', -1);
				} else {
					$finder->whereOr([
						['profile_user_id', $related],
						['user_id', $related],
					]);
				}
				break;
			default:
				$finder->where('profile_post_id', -1);
		}

		return $finder->fetch();
	}

	protected function getThreadsForMode(int $visitorUserId, string $mode): AbstractCollection
	{
		$finder = $this->finder('XF:Thread')
			->where('discussion_state', 'visible')
			->with('User', 'Forum', 'FirstPost')
			->order('post_date', 'DESC')
			->limit(40);

		switch ($mode) {
			case 'all':
				break;
			case 'following':
			case 'followers':
				$related = $this->getRelatedUserIdsByMode($visitorUserId, $mode);
				$finder->where('user_id', $related ?: -1);
				break;
			case 'network':
				$followed = $this->getFollowingUserIds($visitorUserId);
				$watchedForums = $this->getWatchedForumNodeIds($visitorUserId);
				$watchedThreads = $this->getWatchedThreadIds($visitorUserId);
				if ($followed === [] && $watchedForums === [] && $watchedThreads === []) {
					$finder->where('thread_id', -1);
				} else {
					$finder->whereOr(\array_values(\array_filter([
						$followed !== [] ? ['user_id', $followed] : null,
						$watchedForums !== [] ? ['node_id', $watchedForums] : null,
						$watchedThreads !== [] ? ['thread_id', $watchedThreads] : null,
					])));
				}
				break;
			default:
				$finder->where('thread_id', -1);
		}

		return $finder->fetch();
	}

	protected function getGroupPostsForMode(int $visitorUserId, string $mode): AbstractCollection
	{
		$memberGroupIds = $this->getMemberGroupIds($visitorUserId);
		$viewableGroupIds = $this->getViewableGroupIds($visitorUserId);

		if ($mode === 'network') {
			if ($memberGroupIds === []) {
				return $this->finder('Kairete\SocialGroups:GroupPost')->where('group_post_id', -1)->fetch();
			}
			$finder = $this->finder('Kairete\SocialGroups:GroupPost')
				->where('post_state', 'visible')
				->with('User', 'Group')
				->where('group_id', $memberGroupIds)
				->order('post_date', 'DESC')
				->limit(40);

			return $finder->fetch();
		}

		if ($viewableGroupIds === []) {
			return $this->finder('Kairete\SocialGroups:GroupPost')->where('group_post_id', -1)->fetch();
		}

		$finder = $this->finder('Kairete\SocialGroups:GroupPost')
			->where('post_state', 'visible')
			->with('User', 'Group')
			->where('group_id', $viewableGroupIds)
			->order('post_date', 'DESC')
			->limit(40);

		if ($mode === 'following' || $mode === 'followers') {
			$related = $this->getRelatedUserIdsByMode($visitorUserId, $mode);
			$finder->where('user_id', $related ?: -1);
		}

		return $finder->fetch();
	}

	/**
	 * @return list<int>
	 */
	protected function getViewableGroupIds(int $visitorUserId): array
	{
		if (!$this->socialGroupsAvailable()) {
			return [];
		}

		$db = $this->db();
		$prefix = $this->app->config('db')['tables']['prefix'] ?? 'xf_';
		$t = $prefix . 'ksg_group';
		$ids = [];

		try {
			$pub = $db->fetchAllColumn(
				"SELECT `group_id` FROM `{$t}` WHERE `group_state` = 'visible' AND `privacy_state` = 'public'"
			);
			$ids = \array_merge($ids, \array_map('intval', $pub));
		} catch (\Throwable $e) {
			return [];
		}

		if ($visitorUserId > 0) {
			try {
				$m = $prefix . 'ksg_group_member';
				$mem = $db->fetchAllColumn(
					"SELECT m.`group_id` FROM `{$m}` AS m
					INNER JOIN `{$t}` AS g ON (g.`group_id` = m.`group_id`)
					WHERE m.`user_id` = ? AND m.`member_state` = 'active' AND g.`group_state` = 'visible'",
					[$visitorUserId]
				);
				$ids = \array_merge($ids, \array_map('intval', $mem));
			} catch (\Throwable $e) {
			}
		}

		return \array_values(\array_unique(\array_filter(\array_map('intval', $ids))));
	}

	/**
	 * @return list<int>
	 */
	protected function getRelatedUserIdsByMode(int $visitorUserId, string $mode): array
	{
		if ($mode === 'following') {
			return $this->getFollowingUserIds($visitorUserId);
		}
		if ($mode === 'followers') {
			return $this->getFollowerUserIds($visitorUserId);
		}

		return [];
	}

	/**
	 * @return list<int>
	 */
	protected function getFollowingUserIds(int $visitorUserId): array
	{
		if ($visitorUserId <= 0) {
			return [];
		}

		$db = $this->db();
		$prefix = $this->app->config('db')['tables']['prefix'] ?? 'xf_';
		$table = $prefix . 'user_follow';
		$userIds = $db->fetchAllColumn(
			"SELECT follow_user_id FROM {$table} WHERE user_id = ?",
			[$visitorUserId]
		);

		return \array_values(\array_unique(\array_map('intval', $userIds)));
	}

	/**
	 * @return list<int>
	 */
	protected function getFollowerUserIds(int $visitorUserId): array
	{
		if ($visitorUserId <= 0) {
			return [];
		}

		$db = $this->db();
		$prefix = $this->app->config('db')['tables']['prefix'] ?? 'xf_';
		$table = $prefix . 'user_follow';
		$userIds = $db->fetchAllColumn(
			"SELECT user_id FROM {$table} WHERE follow_user_id = ?",
			[$visitorUserId]
		);

		return \array_values(\array_unique(\array_map('intval', $userIds)));
	}

	/**
	 * Gruppi sociali a cui l'utente è iscritto attivamente.
	 *
	 * @return list<int>
	 */
	protected function getMemberGroupIds(int $visitorUserId): array
	{
		if ($visitorUserId <= 0 || !$this->socialGroupsAvailable()) {
			return [];
		}

		$db = $this->db();
		$prefix = $this->app->config('db')['tables']['prefix'] ?? 'xf_';
		$t = $prefix . 'ksg_group';
		$m = $prefix . 'ksg_group_member';

		try {
			$ids = $db->fetchAllColumn(
				"SELECT m.`group_id` FROM `{$m}` AS m
				INNER JOIN `{$t}` AS g ON (g.`group_id` = m.`group_id`)
				WHERE m.`user_id` = ? AND m.`member_state` = 'active' AND g.`group_state` = 'visible'",
				[$visitorUserId]
			);

			return \array_values(\array_unique(\array_map('intval', $ids)));
		} catch (\Throwable $e) {
			return [];
		}
	}

	/**
	 * @return list<int>
	 */
	protected function getWatchedForumNodeIds(int $visitorUserId): array
	{
		if ($visitorUserId <= 0) {
			return [];
		}

		$db = $this->db();
		$prefix = $this->app->config('db')['tables']['prefix'] ?? 'xf_';
		$table = $prefix . 'forum_watch';

		try {
			$ids = $db->fetchAllColumn(
				"SELECT node_id FROM {$table} WHERE user_id = ?",
				[$visitorUserId]
			);

			return \array_values(\array_unique(\array_map('intval', $ids)));
		} catch (\Throwable $e) {
			return [];
		}
	}

	/**
	 * @return list<int>
	 */
	protected function getWatchedThreadIds(int $visitorUserId): array
	{
		if ($visitorUserId <= 0) {
			return [];
		}

		$db = $this->db();
		$prefix = $this->app->config('db')['tables']['prefix'] ?? 'xf_';
		$table = $prefix . 'thread_watch';

		try {
			$ids = $db->fetchAllColumn(
				"SELECT thread_id FROM {$table} WHERE user_id = ?",
				[$visitorUserId]
			);

			return \array_values(\array_unique(\array_map('intval', $ids)));
		} catch (\Throwable $e) {
			return [];
		}
	}

	/**
	 * @return list<int>
	 */
	protected function getWatchedBlogIds(int $visitorUserId): array
	{
		if ($visitorUserId <= 0 || !BlogFeed::isAvailable()) {
			return [];
		}

		$db = $this->db();
		$prefix = $this->app->config('db')['tables']['prefix'] ?? 'xf_';
		$table = $prefix . 'kairete_blog_watch';

		try {
			if (!$db->getSchemaManager()->tableExists($table)) {
				return [];
			}
			$ids = $db->fetchAllColumn(
				"SELECT blog_id FROM {$table} WHERE user_id = ?",
				[$visitorUserId]
			);

			return \array_values(\array_unique(\array_map('intval', $ids)));
		} catch (\Throwable $e) {
			return [];
		}
	}

	/**
	 * Tag dei gruppi sociali a cui l'utente è iscritto.
	 *
	 * @return list<string>
	 */
	protected function getInterestTagsForVisitor(int $visitorUserId): array
	{
		$groupIds = $this->getMemberGroupIds($visitorUserId);
		if ($groupIds === [] || !$this->socialGroupsAvailable()) {
			return [];
		}

		$db = $this->db();
		$prefix = $this->app->config('db')['tables']['prefix'] ?? 'xf_';
		$tagTable = $prefix . 'ksg_group_tag';
		$mapTable = $prefix . 'ksg_group_tag_map';

		try {
			$placeholders = \implode(',', \array_fill(0, \count($groupIds), '?'));
			$tags = $db->fetchAllColumn(
				"SELECT DISTINCT t.`tag`
				FROM `{$tagTable}` AS t
				INNER JOIN `{$mapTable}` AS m ON (m.`group_tag_id` = t.`group_tag_id`)
				WHERE m.`group_id` IN ({$placeholders})",
				$groupIds
			);
			$out = [];
			foreach ($tags as $tag) {
				$tag = \trim((string) $tag);
				if ($tag !== '') {
					$out[] = $tag;
				}
			}

			return \array_values(\array_unique($out));
		} catch (\Throwable $e) {
			return [];
		}
	}

	/**
	 * @param array{payload?: array<string, mixed>} $row
	 * @param list<string> $tags
	 */
	protected function feedRowMatchesInterestTags(array $row, array $tags): bool
	{
		$payload = $row['payload'] ?? [];
		if (!\is_array($payload)) {
			return false;
		}

		$haystack = \strtolower(
			\trim((string) ($payload['ContentTitle'] ?? '')) . ' ' .
			\trim((string) ($payload['message_plain_text'] ?? ''))
		);
		if ($haystack === '') {
			return false;
		}

		foreach ($tags as $tag) {
			$needle = \strtolower(\trim($tag));
			if ($needle !== '' && \str_contains($haystack, $needle)) {
				return true;
			}
		}

		return false;
	}

	protected function resolveProfilePostActivityDate(\XF\Entity\ProfilePost $post): int
	{
		$postDate = (int) $post->post_date;
		if ((int) $post->comment_count <= 0) {
			return $postDate;
		}

		try {
			$prefix = $this->app->config('db')['tables']['prefix'] ?? 'xf_';
			$table = $prefix . 'profile_post_comment';
			$latest = (int) $this->db()->fetchOne(
				"SELECT MAX(comment_date) FROM {$table}
				 WHERE profile_post_id = ? AND message_state = ?",
				[$post->profile_post_id, 'visible']
			);

			return $latest > $postDate ? $latest : $postDate;
		} catch (\Throwable $e) {
			return $postDate;
		}
	}

	protected function resolveGroupPostActivityDate($post): int
	{
		$postDate = (int) $post->post_date;
		if ((int) $post->comment_count <= 0) {
			return $postDate;
		}

		try {
			$prefix = $this->app->config('db')['tables']['prefix'] ?? 'xf_';
			$table = $prefix . 'ksg_group_post_comment';
			$latest = (int) $this->db()->fetchOne(
				"SELECT MAX(comment_date) FROM {$table}
				 WHERE group_post_id = ? AND comment_state = ?",
				[$post->group_post_id, 'visible']
			);

			return $latest > $postDate ? $latest : $postDate;
		} catch (\Throwable $e) {
			return $postDate;
		}
	}

	protected function socialGroupsAvailable(): bool
	{
		return \class_exists(\Kairete\SocialGroups\Entity\GroupPost::class);
	}

	/**
	 * Aggiunge i contenuti pubblicati dal visitatore (evita che spariscano dal feed filtrato).
	 *
	 * @param list<array{sort_date: int, activity_date: int, payload: array<string, mixed>}> $items
	 * @return list<array{sort_date: int, activity_date: int, payload: array<string, mixed>}>
	 */
	protected function mergeVisitorOwnFeedRows(array $items, int $visitorUserId, int $previewLimit): array
	{
		if ($visitorUserId <= 0) {
			return $items;
		}

		$seen = [];
		foreach ($items as $row) {
			$payload = $row['payload'] ?? null;
			if (!\is_array($payload)) {
				continue;
			}
			$itemId = (int) ($payload['item_id'] ?? 0);
			if ($itemId > 0) {
				$seen[$itemId] = true;
			}
		}

		foreach ($this->collectVisitorOwnFeedRows($visitorUserId, $previewLimit) as $row) {
			$payload = $row['payload'] ?? null;
			if (!\is_array($payload)) {
				continue;
			}
			$itemId = (int) ($payload['item_id'] ?? 0);
			if ($itemId <= 0 || isset($seen[$itemId])) {
				continue;
			}
			$seen[$itemId] = true;
			$items[] = $row;
		}

		return $items;
	}

	/**
	 * @return list<array{sort_date: int, activity_date: int, payload: array<string, mixed>}>
	 */
	protected function collectVisitorOwnFeedRows(int $visitorUserId, int $previewLimit): array
	{
		return $this->collectUserFeedRows($visitorUserId, $previewLimit);
	}

	/**
	 * Attività di un utente: post sul suo profilo + contenuti creati da lui.
	 *
	 * @return list<array{sort_date: int, activity_date: int, payload: array<string, mixed>}>
	 */
	protected function collectUserFeedRows(int $targetUserId, int $previewLimit): array
	{
		$rows = [];

		try {
			$posts = $this->finder('XF:ProfilePost')
				->where('message_state', 'visible')
				->where('user_id', $targetUserId)
				->with('User')
				->order('post_date', 'DESC')
				->limit(30)
				->fetch();
			$this->hydrateProfilePostAttachments($posts);
			foreach ($posts as $post) {
				if (!$post->canView()) {
					continue;
				}
				$postDate = (int) $post->post_date;
				$rows[] = [
					'sort_date' => $postDate,
					'activity_date' => $this->resolveProfilePostActivityDate($post),
					'payload' => ApiSerializer::profilePost($post),
				];
			}
		} catch (\Throwable $e) {
		}

		try {
			$threads = $this->finder('XF:Thread')
				->where('discussion_state', 'visible')
				->where('user_id', $targetUserId)
				->with('User', 'Forum', 'FirstPost')
				->order('post_date', 'DESC')
				->limit(20)
				->fetch();
			$this->hydrateThreadAttachments($threads);
			foreach ($threads as $thread) {
				if (!$thread->canView()) {
					continue;
				}
				$preview = '';
				if ($thread->FirstPost) {
					$preview = ApiSerializer::messageToPlain((string) $thread->FirstPost->message, $previewLimit);
				}
				$postDate = (int) $thread->post_date;
				$rows[] = [
					'sort_date' => $postDate,
					'activity_date' => (int) ($thread->last_post_date ?: $postDate),
					'payload' => ApiSerializer::thread($thread, $preview),
				];
			}
		} catch (\Throwable $e) {
		}

		if ($this->socialGroupsAvailable()) {
			try {
				$groupPosts = $this->finder('Kairete\SocialGroups:GroupPost')
					->where('post_state', 'visible')
					->where('user_id', $targetUserId)
					->with('User', 'Group')
					->order('post_date', 'DESC')
					->limit(20)
					->fetch();
				foreach ($groupPosts as $post) {
					if (!$post->canView()) {
						continue;
					}
					$postDate = (int) $post->post_date;
					$rows[] = [
						'sort_date' => $postDate,
						'activity_date' => $this->resolveGroupPostActivityDate($post),
						'payload' => ApiSerializer::groupPost($post),
					];
				}
			} catch (\Throwable $e) {
			}
		}

		if (BlogFeed::isAvailable()) {
			try {
				$blogPosts = $this->finder('Kairete\Blog:BlogPost')
					->where('user_id', $targetUserId)
					->with(['User', 'Blog', 'BlogCategory'])
					->order('post_date', 'DESC')
					->limit(20)
					->fetch();
				$this->hydrateBlogPostAttachments($blogPosts);
				foreach ($blogPosts as $blogPost) {
					if (!$blogPost->canView()) {
						continue;
					}
					$postDate = (int) $blogPost->post_date;
					$rows[] = [
						'sort_date' => $postDate,
						'activity_date' => $postDate,
						'payload' => $this->serializeBlogItem(
							['openUrl' => '', 'previewText' => ApiSerializer::messageToPlain((string) $blogPost->message, $previewLimit)],
							$blogPost
						),
					];
				}
			} catch (\Throwable $e) {
			}
		}

		if ($this->mediaGalleryAvailable()) {
			try {
				$mediaItems = $this->mediaItemFinder()
					->where('media_state', 'visible')
					->where('user_id', $targetUserId)
					->with(['User', 'Album', 'Category'])
					->order('media_date', 'DESC')
					->limit(20)
					->fetch();
				foreach ($mediaItems as $media) {
					if (!$media->canView()) {
						continue;
					}
					$postDate = (int) $media->media_date;
					$rows[] = [
						'sort_date' => $postDate,
						'activity_date' => (int) ($media->last_comment_date ?: $postDate),
						'payload' => ApiSerializer::media(
							$media,
							ApiSerializer::messageToPlain((string) ($media->description ?? ''), $previewLimit)
						),
					];
				}
			} catch (\Throwable $e) {
			}
		}

		$seen = [];
		$unique = [];
		foreach ($rows as $row) {
			$itemId = (int) ($row['payload']['item_id'] ?? 0);
			if ($itemId > 0 && isset($seen[$itemId])) {
				continue;
			}
			if ($itemId > 0) {
				$seen[$itemId] = true;
			}
			$unique[] = $row;
		}

		return $unique;
	}

	/**
	 * @param iterable<\XF\Entity\ProfilePost> $posts
	 */
	protected function hydrateProfilePostAttachments(iterable $posts): void
	{
		$list = [];
		foreach ($posts as $post) {
			$list[] = $post;
		}
		if ($list === []) {
			return;
		}

		try {
			$this->repository('XF:Attachment')->addAttachmentsToContent($list, 'profile_post');
		} catch (\Throwable $e) {
			\XF::logException($e, false, 'OmniFeed API profile attach hydrate: ');
		}
	}

	/**
	 * @param iterable<\XF\Entity\Thread> $threads
	 */
	protected function hydrateThreadAttachments(iterable $threads): void
	{
		$posts = [];
		foreach ($threads as $thread) {
			if ($thread->FirstPost) {
				$posts[] = $thread->FirstPost;
			}
		}
		if ($posts === []) {
			return;
		}

		try {
			$this->repository('XF:Attachment')->addAttachmentsToContent($posts, 'post');
		} catch (\Throwable $e) {
			\XF::logException($e, false, 'OmniFeed API thread attach hydrate: ');
		}
	}

	/**
	 * @param iterable<\Kairete\Blog\Entity\BlogPost> $posts
	 */
	protected function hydrateBlogPostAttachments(iterable $posts): void
	{
		$list = [];
		foreach ($posts as $post) {
			$list[] = $post;
		}
		if ($list === []) {
			return;
		}

		try {
			$this->repository('XF:Attachment')->addAttachmentsToContent($list, 'blog_post');
		} catch (\Throwable $e) {
			\XF::logException($e, false, 'OmniFeed API blog attach hydrate: ');
		}
	}

	protected function getThreadPreviewCharLimit(): int
	{
		$raw = (int) (\XF::options()->kaireteOmniFeedThreadPreviewChars ?? 280);

		return \max(80, \min(5000, $raw));
	}

	/**
	 * @return array<string, int>
	 */
	protected function pagination(int $total, int $page, int $perPage, ?int $shown = null): array
	{
		$page = \max(1, $page);
		$perPage = \max(1, \min(50, $perPage));
		$lastPage = \max(1, (int) \ceil($total / $perPage));

		return [
			'current_page' => $page,
			'last_page' => $lastPage,
			'per_page' => $perPage,
			'shown' => $shown ?? \min($perPage, \max(0, $total - (($page - 1) * $perPage))),
			'total' => $total,
		];
	}
}
