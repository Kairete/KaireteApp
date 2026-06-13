<?php

namespace Kairete\Multisite\Api\Controller;

use Kairete\Multisite\Service\MobileApi\TenantBootstrap;
use Kairete\Multisite\Service\MobileApi\TenantContext;
use Kairete\Multisite\Service\MobileApi\TenantScopedFeed;
use XF\Api\Controller\AbstractController;
use XF\Mvc\ParameterBag;

class Tenant extends AbstractController
{
	public function actionGet(ParameterBag $params)
	{
		$bootstrap = new TenantBootstrap($this->app());

		return $this->apiResult([
			'tenants' => $bootstrap->listActiveTenants(),
		]);
	}

	public function actionGetBootstrap(ParameterBag $params)
	{
		$tenantId = (int) ($params->tenant_id ?: $this->filter('tenant_id', 'uint'));
		$tenant = TenantContext::resolveActiveTenant($this->app(), $tenantId);
		if (!$tenant)
		{
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		$bootstrap = new TenantBootstrap($this->app());

		return $this->apiResult([
			'bootstrap' => $bootstrap->build($tenant, \XF::visitor()),
		]);
	}

	public function actionGetMappedUserFeed(ParameterBag $params)
	{
		$this->assertRegisteredUser();

		$tenantId = (int) ($params->tenant_id ?: $this->filter('tenant_id', 'uint'));
		$tenant = TenantContext::resolveActiveTenant($this->app(), $tenantId);
		if (!$tenant)
		{
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		$userId = (int) ($params->user_id ?: $this->filter('user_id', 'uint'));
		if ($userId <= 0)
		{
			$userId = (int) \XF::visitor()->user_id;
		}

		$page = \max(1, (int) $this->filter('page', 'uint'));
		$limit = (int) $this->filter('limit', 'uint');
		if ($limit < 1)
		{
			$limit = 20;
		}

		try
		{
			$feed = new TenantScopedFeed($this->app());

			return $this->apiResult($feed->buildUserMappedFeed($tenant, $userId, $page, $limit));
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Multisite API mapped user feed: ');

			return $this->error(\XF::phrase('unexpected_error_occurred'), 500);
		}
	}

	public function actionGetMappedForums(ParameterBag $params)
	{
		$this->assertRegisteredUser();

		$tenantId = (int) ($params->tenant_id ?: $this->filter('tenant_id', 'uint'));
		$tenant = TenantContext::resolveActiveTenant($this->app(), $tenantId);
		if (!$tenant)
		{
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		try
		{
			$feed = new TenantScopedFeed($this->app());
			$nodes = $feed->listMappedForumNodes($tenant);

			return $this->apiResult([
				'nodes' => $nodes,
				'tenant_id' => (int) $tenant->tenant_id,
			]);
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Multisite API mapped forums: ');

			return $this->error(\XF::phrase('unexpected_error_occurred'), 500);
		}
	}

	public function actionGetMappedBlogEntries(ParameterBag $params)
	{
		$this->assertRegisteredUser();

		$tenantId = (int) ($params->tenant_id ?: $this->filter('tenant_id', 'uint'));
		$tenant = TenantContext::resolveActiveTenant($this->app(), $tenantId);
		if (!$tenant)
		{
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		$page = \max(1, (int) $this->filter('page', 'uint'));
		$limit = (int) $this->filter('limit', 'uint');
		if ($limit < 1)
		{
			$limit = 20;
		}

		try
		{
			$feed = new TenantScopedFeed($this->app());

			return $this->apiResult($feed->listMappedBlogEntries($tenant, $page, $limit));
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Multisite API mapped blog entries: ');

			return $this->error(\XF::phrase('unexpected_error_occurred'), 500);
		}
	}
}
