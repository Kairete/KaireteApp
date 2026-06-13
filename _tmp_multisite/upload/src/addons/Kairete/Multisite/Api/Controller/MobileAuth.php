<?php

namespace Kairete\Multisite\Api\Controller;

use Kairete\Multisite\Service\MobileApi\DeviceSession;
use XF\Api\Controller\AbstractController;
use XF\Mvc\ParameterBag;

class MobileAuth extends AbstractController
{
	public function actionPost(ParameterBag $params)
	{
		$this->assertRegisteredUser();

		$deviceKey = trim((string) $this->filter('device_key', 'str'));
		$appId = trim((string) $this->filter('app_id', 'str'));
		if ($deviceKey === '')
		{
			return $this->error(\XF::phrase('please_enter_value_for_required_field_x', ['field' => 'device_key']));
		}

		$token = (new DeviceSession($this->app()))->issue(
			(int) \XF::visitor()->user_id,
			$deviceKey,
			$appId
		);

		return $this->apiResult([
			'session_token' => $token,
			'user_id' => (int) \XF::visitor()->user_id,
		]);
	}

	public function actionPostRestoreByDevice(ParameterBag $params)
	{
		$deviceKey = trim((string) $this->filter('device_key', 'str'));
		$sessionToken = trim((string) $this->filter('session_token', 'str'));
		$appId = trim((string) $this->filter('app_id', 'str'));

		if ($deviceKey === '')
		{
			return $this->error(\XF::phrase('please_enter_value_for_required_field_x', ['field' => 'device_key']));
		}

		$restored = (new DeviceSession($this->app()))->restore($deviceKey, $sessionToken);
		if (!$restored)
		{
			return $this->error(\XF::phrase('login_required'), 401);
		}

		return $this->apiResult([
			'user_id' => $restored['user_id'],
			'session_token' => $restored['session_token'],
			'app_id' => $appId,
		]);
	}
}
