<?php

namespace Kairete\Multisite\Service\MobileApi;

use Kairete\Multisite\Entity\Tenant;
use Kairete\Multisite\Service\Homepage\Redirector;
use Kairete\Multisite\Service\MappedForumNodes;
use Kairete\Multisite\Service\Member\MappedUserFeed;
use Kairete\Multisite\Service\Member\TenantMappingScope;
use Kairete\Multisite\Service\Registration\TenantGroupJoiner;
use Kairete\OmniFeed\Service\MobileApi\ApiSerializer;
use Kairete\OmniFeed\Service\MobileApi\FeedAssembler;
use XF\App;
use XF\Entity\User;

/**
 * Feed mobile limitati al mapping tenant (gruppo sociale + moduli mappati).
 */
class TenantScopedFeed
{
	protected App $app;

	public function __construct(App $app)
	{
		$this->app = $app;
	}

	public static function resolveTenantIdFromApp(App $app): int
	{
		$request = $app->request();
		$fromHeader = (int) $request->getServer('HTTP_X_MS_TENANT_ID');
		if ($fromHeader > 0)
		{
			return $fromHeader;
		}

		return (int) $request->filter('tenant_id', 'uint');
	}

	public function resolveTenant(): ?Tenant
	{
		$tenantId = self::resolveTenantIdFromApp($this->app);
		if ($tenantId <= 0)
		{
			return null;
		}

		return TenantContext::resolveActiveTenant($this->app, $tenantId);
	}

	/**
	 * Feed home twin app = post del gruppo sociale mappato (senza network hub).
	 *
	 * @return array<string, mixed>
	 */
	public function buildCommunityFeed(Tenant $tenant, int $page = 1, int $limit = 10, string $sort = 'post_date'): array
	{
		$visitor = \XF::visitor();
		if (!$visitor->user_id)
		{
			return $this->emptyFeed($page, $limit, $sort, 'tenant_group');
		}

		if ($visitor->user_id)
		{
			try
			{
				(new TenantGroupJoiner($this->app))->joinUserToTenantGroup($visitor, $tenant);
			}
			catch (\Throwable $e)
			{
			}
		}

		$sort = \in_array($sort, ['post_date', 'last_activity'], true) ? $sort : 'post_date';
		$groupId = (new Redirector($this->app))->resolveSocialGroupId($tenant);
		$rawItems = [];

		if ($groupId > 0 && $this->socialGroupsAvailable())
		{
			try
			{
				$posts = $this->app->finder('Kairete\SocialGroups:GroupPost')
					->where('group_id', $groupId)
					->where('post_state', 'visible')
					->with(['User', 'Group'])
					->order('post_date', 'DESC')
					->fetch();
				foreach ($posts as $post)
				{
					if (!$post->canView())
					{
						continue;
					}
					$postDate = (int) $post->post_date;
					$rawItems[] = [
						'sort_date' => $postDate,
						'activity_date' => $postDate,
						'payload' => ApiSerializer::groupPost($post),
					];
				}
			}
			catch (\Throwable $e)
			{
				\XF::logException($e, false, 'Multisite tenant community group posts: ');
			}
		}

		if ($sort === 'last_activity')
		{
			\usort($rawItems, static fn (array $a, array $b): int => ($b['activity_date'] ?? 0) <=> ($a['activity_date'] ?? 0));
		}
		else
		{
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
			'tenant_id' => (int) $tenant->tenant_id,
		];
	}

	/**
	 * Wall profilo utente limitato ai moduli mappati del tenant.
	 *
	 * @return array<string, mixed>
	 */
	public function buildUserMappedFeed(Tenant $tenant, int $userId, int $page = 1, int $limit = 20): array
	{
		/** @var User|null $user */
		$user = $this->app->em()->find('XF:User', $userId);
		if (!$user || !$user->canView())
		{
			return $this->emptyFeed($page, $limit, 'post_date', 'tenant_mapped_user');
		}

		$scope = TenantMappingScope::fromTenant($tenant);
		$items = (new MappedUserFeed($this->app))->buildForUser($user, $scope, $limit * $page);
		$payloads = MobileFeedSerializer::fromMappedWallItems($items);

		$total = \count($payloads);
		$offset = \max(0, ($page - 1) * $limit);
		$pageItems = \array_slice($payloads, $offset, $limit);

		return [
			'newsfeedItems' => $pageItems,
			'pagination' => $this->pagination($total, $page, $limit, \count($pageItems)),
			'mode' => 'tenant_mapped_user',
			'user_id' => $userId,
			'tenant_id' => (int) $tenant->tenant_id,
		];
	}

	/**
	 * @return list<array<string, mixed>>
	 */
	public function listMappedForumNodes(Tenant $tenant): array
	{
		$scope = TenantMappingScope::fromTenant($tenant);
		$nodeIds = MappedForumNodes::expandNodeIdsForThreadFeed(
			$this->app->db(),
			(array) ($scope['forumNodeIds'] ?? [])
		);
		if (!$nodeIds)
		{
			return [];
		}

		$nodes = $this->app->finder('XF:Node')
			->where('node_id', $nodeIds)
			->where('node_type_id', 'Forum')
			->with('Forum')
			->order('lft')
			->fetch();

		$out = [];
		foreach ($nodes as $node)
		{
			if (!$node->canView())
			{
				continue;
			}
			$forum = $node->Forum;
			$out[] = [
				'node_id' => (int) $node->node_id,
				'title' => (string) $node->title,
				'node_type_id' => (string) $node->node_type_id,
				'parent_node_id' => (int) ($node->parent_node_id ?? 0),
				'description' => (string) ($node->description ?? ''),
				'display_order' => (int) ($node->display_order ?? 0),
				'view_url' => (string) $this->app->router('public')->buildLink('canonical:forums', $node),
				'type_data' => $forum ? [
					'discussion_count' => (int) ($forum->discussion_count ?? 0),
					'message_count' => (int) ($forum->message_count ?? 0),
					'last_post_date' => (int) ($forum->last_post_date ?? 0),
				] : [],
			];
		}

		return $out;
	}

	/**
	 * @return array<string, mixed>
	 */
	public function listMappedBlogEntries(Tenant $tenant, int $page = 1, int $limit = 20): array
	{
		$scope = TenantMappingScope::fromTenant($tenant);
		$blogIds = (array) ($scope['blogIds'] ?? []);
		$categoryIds = (array) ($scope['blogCategoryIds'] ?? []);
		if ((!$blogIds && !$categoryIds)
			|| !\XF::isAddOnActive('Kairete/Blog')
			|| !\class_exists(\Kairete\Blog\Entity\BlogPost::class))
		{
			return ['blogEntryItems' => [], 'pagination' => $this->pagination(0, $page, $limit)];
		}

		$finder = $this->app->finder('Kairete\Blog:BlogPost')
			->with(['User', 'Blog', 'BlogCategory'])
			->where('post_state', 'visible')
			->order('post_date', 'DESC');
		if ($blogIds && $categoryIds)
		{
			$finder->whereOr([
				['blog_id', $blogIds],
				['category_id', $categoryIds],
			]);
		}
		elseif ($blogIds)
		{
			$finder->where('blog_id', $blogIds);
		}
		else
		{
			$finder->where('category_id', $categoryIds);
		}

		$posts = $finder->fetch();
		$entries = [];
		$assembler = \class_exists(FeedAssembler::class) ? new FeedAssembler($this->app) : null;
		$serializeRef = $assembler ? new \ReflectionMethod($assembler, 'serializeBlogItem') : null;
		if ($serializeRef)
		{
			$serializeRef->setAccessible(true);
		}

		foreach ($posts as $post)
		{
			try
			{
				if (!$post->canView())
				{
					continue;
				}
			}
			catch (\Throwable $e)
			{
				continue;
			}

			if ($serializeRef)
			{
				$payload = $serializeRef->invoke($assembler, [
					'previewText' => ApiSerializer::messageToPlain((string) $post->message, 280),
					'openUrl' => (string) $post->getPublicUrl(),
				], $post);
				$entries[] = $this->blogEntryFromFeedPayload($payload);
			}
		}

		$total = \count($entries);
		$offset = \max(0, ($page - 1) * $limit);
		$pageItems = \array_slice($entries, $offset, $limit);

		return [
			'blogEntryItems' => $pageItems,
			'pagination' => $this->pagination($total, $page, $limit, \count($pageItems)),
			'tenant_id' => (int) $tenant->tenant_id,
		];
	}

	/**
	 * @param array<string, mixed> $scope
	 * @return list<array{sort_date: int, activity_date: int, payload: array<string, mixed>}>
	 */
	protected function buildMappedCommunityRows(array $scope): array
	{
		$rows = [];
		$rows = \array_merge($rows, $this->buildMappedForumRows($scope));
		$rows = \array_merge($rows, $this->buildMappedBlogRows($scope));
		$rows = \array_merge($rows, $this->buildMappedMediaRows($scope));

		return $rows;
	}

	/**
	 * @param array<string, mixed> $scope
	 * @return list<array{sort_date: int, activity_date: int, payload: array<string, mixed>}>
	 */
	protected function buildMappedForumRows(array $scope): array
	{
		$nodeIds = MappedForumNodes::expandNodeIdsForThreadFeed(
			$this->app->db(),
			(array) ($scope['forumNodeIds'] ?? [])
		);
		if (!$nodeIds)
		{
			return [];
		}

		$threads = $this->app->finder('XF:Thread')
			->where('node_id', $nodeIds)
			->where('discussion_state', 'visible')
			->with(['User', 'Forum', 'FirstPost'])
			->order('post_date', 'DESC')
			->limit(25)
			->fetch();

		$rows = [];
		foreach ($threads as $thread)
		{
			try
			{
				if (!$thread->canView())
				{
					continue;
				}
			}
			catch (\Throwable $e)
			{
				continue;
			}

			$postDate = (int) $thread->post_date;
			$preview = ApiSerializer::messageToPlain((string) ($thread->FirstPost ? $thread->FirstPost->message : ''), 280);
			$rows[] = [
				'sort_date' => $postDate,
				'activity_date' => (int) ($thread->last_post_date ?? $postDate),
				'payload' => ApiSerializer::thread($thread, $preview),
			];
		}

		return $rows;
	}

	/**
	 * @param array<string, mixed> $scope
	 * @return list<array{sort_date: int, activity_date: int, payload: array<string, mixed>}>
	 */
	protected function buildMappedBlogRows(array $scope): array
	{
		$blogIds = (array) ($scope['blogIds'] ?? []);
		$categoryIds = (array) ($scope['blogCategoryIds'] ?? []);
		if ((!$blogIds && !$categoryIds)
			|| !\XF::isAddOnActive('Kairete/Blog')
			|| !\class_exists(\Kairete\Blog\Entity\BlogPost::class)
			|| !\class_exists(FeedAssembler::class))
		{
			return [];
		}

		$finder = $this->app->finder('Kairete\Blog:BlogPost')
			->with(['User', 'Blog', 'BlogCategory'])
			->where('post_state', 'visible')
			->order('post_date', 'DESC')
			->limit(25);
		if ($blogIds && $categoryIds)
		{
			$finder->whereOr([
				['blog_id', $blogIds],
				['category_id', $categoryIds],
			]);
		}
		elseif ($blogIds)
		{
			$finder->where('blog_id', $blogIds);
		}
		else
		{
			$finder->where('category_id', $categoryIds);
		}

		$assembler = new FeedAssembler($this->app);
		$serializeRef = new \ReflectionMethod($assembler, 'serializeBlogItem');
		$serializeRef->setAccessible(true);

		$rows = [];
		foreach ($finder->fetch() as $post)
		{
			try
			{
				if (!$post->canView())
				{
					continue;
				}
			}
			catch (\Throwable $e)
			{
				continue;
			}

			$postDate = (int) $post->post_date;
			$rows[] = [
				'sort_date' => $postDate,
				'activity_date' => $postDate,
				'payload' => $serializeRef->invoke($assembler, [
					'previewText' => ApiSerializer::messageToPlain((string) $post->message, 280),
					'openUrl' => (string) $post->getPublicUrl(),
				], $post),
			];
		}

		return $rows;
	}

	/**
	 * @param array<string, mixed> $scope
	 * @return list<array{sort_date: int, activity_date: int, payload: array<string, mixed>}>
	 */
	protected function buildMappedMediaRows(array $scope): array
	{
		$categoryIds = (array) ($scope['mediaCategoryIds'] ?? []);
		$albumIds = (array) ($scope['mediaAlbumIds'] ?? []);
		if ((!$categoryIds && !$albumIds) || !\class_exists('XFMG\Entity\MediaItem'))
		{
			return [];
		}

		$finder = $this->app->finder('XFMG:MediaItem')
			->with(['User', 'Album', 'Category'])
			->where('media_state', 'visible')
			->order('media_date', 'DESC')
			->limit(25);
		if ($categoryIds && $albumIds)
		{
			$finder->whereOr([
				['category_id', $categoryIds],
				['album_id', $albumIds],
			]);
		}
		elseif ($categoryIds)
		{
			$finder->where('category_id', $categoryIds);
		}
		else
		{
			$finder->where('album_id', $albumIds);
		}

		$rows = [];
		foreach ($finder->fetch() as $media)
		{
			try
			{
				if (!$media->canView())
				{
					continue;
				}
			}
			catch (\Throwable $e)
			{
				continue;
			}

			$mediaDate = (int) ($media->media_date ?? 0);
			$rows[] = [
				'sort_date' => $mediaDate,
				'activity_date' => $mediaDate,
				'payload' => ApiSerializer::media($media),
			];
		}

		return $rows;
	}

	/**
	 * @param array<string, mixed> $payload
	 * @return array<string, mixed>
	 */
	protected function blogEntryFromFeedPayload(array $payload): array
	{
		$blog = $payload['Blog'] ?? null;
		$category = $payload['Content']['Category'] ?? null;

		return [
			'post_id' => (int) ($payload['content_id'] ?? 0),
			'blog_entry_id' => (int) ($payload['content_id'] ?? 0),
			'title' => (string) ($payload['ContentTitle'] ?? ''),
			'message' => (string) ($payload['message_plain_text'] ?? ''),
			'post_date' => (int) ($payload['item_date'] ?? 0),
			'comment_count' => (int) ($payload['comment_count'] ?? 0),
			'reaction_score' => (int) ($payload['reaction_score'] ?? 0),
			'Blog' => \is_array($blog) ? $blog : null,
			'BlogCategory' => \is_array($category) ? $category : null,
			'User' => $payload['User'] ?? null,
		];
	}

	protected function socialGroupsAvailable(): bool
	{
		return \XF::isAddOnActive('Kairete/SocialGroups')
			&& \class_exists(\Kairete\SocialGroups\Entity\GroupPost::class);
	}

	/**
	 * @return array<string, mixed>
	 */
	protected function emptyFeed(int $page, int $limit, string $sort, string $mode): array
	{
		return [
			'newsfeedItems' => [],
			'pagination' => $this->pagination(0, $page, $limit),
			'mode' => $mode,
			'sort' => $sort,
		];
	}

	/**
	 * @return array<string, mixed>
	 */
	protected function pagination(int $total, int $page, int $limit, int $count = 0): array
	{
		return [
			'page' => $page,
			'per_page' => $limit,
			'total' => $total,
			'count' => $count,
			'has_more' => ($page * $limit) < $total,
		];
	}
}
