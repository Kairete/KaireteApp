<?php

namespace Kairete\Multisite\Service\MobileApi;

use Kairete\Multisite\Entity\Tenant;
use Kairete\Multisite\Service\Homepage\Redirector;
use Kairete\Multisite\Service\Member\TenantMappingScope;
use Kairete\Multisite\Service\Registration\TenantGroupJoiner;
use XF\App;
use XF\Entity\User;

class TenantBootstrap
{
	protected App $app;

	public function __construct(App $app)
	{
		$this->app = $app;
	}

	public function build(Tenant $tenant, ?User $visitor = null): array
	{
		$visitor = $visitor ?: \XF::visitor();
		if ($visitor->user_id)
		{
			(new TenantGroupJoiner($this->app))->joinUserToTenantGroup($visitor, $tenant);
		}

		$scope = TenantMappingScope::fromTenant($tenant);
		$redirector = new Redirector($this->app);
		$groupId = $redirector->resolveSocialGroupId($tenant);

		return [
			'tenant_id' => (int) $tenant->tenant_id,
			'title' => (string) $tenant->title,
			'slug' => (string) $tenant->slug,
			'newsfeed_group_id' => $groupId,
			'scope' => $scope,
			'tabs' => $this->resolveTabs($scope, $groupId),
		];
	}

	/**
	 * @param array<string, mixed> $scope
	 * @return list<string>
	 */
	protected function resolveTabs(array $scope, int $groupId): array
	{
		$tabs = ['feed'];

		if (!empty($scope['blogIds']) || !empty($scope['blogCategoryIds']))
		{
			$tabs[] = 'blog';
		}
		if ($groupId > 0 || !empty($scope['groupId']))
		{
			$tabs[] = 'groups';
		}
		if (!empty($scope['mediaCategoryIds']) || !empty($scope['mediaAlbumIds']))
		{
			$tabs[] = 'media';
		}
		if (!empty($scope['forumNodeIds']))
		{
			$tabs[] = 'forum';
		}

		return $tabs;
	}

	/**
	 * @return list<array<string, mixed>>
	 */
	public function listActiveTenants(): array
	{
		$tenants = $this->app->finder('Kairete\Multisite:Tenant')
			->where('active', 1)
			->order('title')
			->fetch();

		$out = [];
		foreach ($tenants as $tenant)
		{
			$out[] = [
				'tenant_id' => (int) $tenant->tenant_id,
				'title' => (string) $tenant->title,
				'slug' => (string) $tenant->slug,
				'has_dedicated_app' => true,
			];
		}

		return $out;
	}
}
