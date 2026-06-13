<?php

namespace Kairete\Multisite\Service\MobileApi;

use Kairete\Multisite\Entity\Tenant;
use XF\App;
use XF\Mvc\Controller;

class TenantContext
{
	public static function resolveTenantIdFromRequest(Controller $controller): int
	{
		$request = $controller->request();
		$fromHeader = (int) $request->getServer('HTTP_X_MS_TENANT_ID');
		if ($fromHeader > 0)
		{
			return $fromHeader;
		}

		return (int) $request->filter('tenant_id', 'uint');
	}

	public static function resolveActiveTenant(App $app, int $tenantId): ?Tenant
	{
		if ($tenantId <= 0)
		{
			return null;
		}

		/** @var Tenant|null $tenant */
		$tenant = $app->em()->find('Kairete\Multisite:Tenant', $tenantId, ['Mappings', 'Domains']);
		if (!$tenant || !$tenant->active)
		{
			return null;
		}

		return $tenant;
	}

	public static function resolveFromRequest(Controller $controller): ?Tenant
	{
		$tenantId = self::resolveTenantIdFromRequest($controller);

		return self::resolveActiveTenant($controller->app(), $tenantId);
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
}
