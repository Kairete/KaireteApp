<?php

namespace Kairete\Multisite\Service\MobileApi;

use XF\App;

class DeviceSession
{
	protected App $app;

	public function __construct(App $app)
	{
		$this->app = $app;
	}

	public function issue(int $userId, string $deviceKey, string $appId): string
	{
		$deviceKey = $this->normalizeKey($deviceKey);
		if ($userId <= 0 || $deviceKey === '')
		{
			return '';
		}

		$token = \XF::generateRandomString(32);
		$now = \XF::$time;

		$this->app->db()->insert('xf_ms_mobile_device_session', [
			'user_id' => $userId,
			'device_key' => $deviceKey,
			'session_token' => $token,
			'app_id' => substr($appId, 0, 100),
			'last_used_date' => $now,
			'created_date' => $now,
			'expires_date' => $now + 86400 * 365,
		], false, 'session_token = VALUES(session_token), user_id = VALUES(user_id), app_id = VALUES(app_id), last_used_date = VALUES(last_used_date), expires_date = VALUES(expires_date)');

		return $token;
	}

	/**
	 * @return array{user_id: int, session_token: string}|null
	 */
	public function restore(string $deviceKey, string $sessionToken = ''): ?array
	{
		$deviceKey = $this->normalizeKey($deviceKey);
		if ($deviceKey === '')
		{
			return null;
		}

		$db = $this->app->db();
		$row = null;

		if ($sessionToken !== '')
		{
			$row = $db->fetchRow('
				SELECT user_id, session_token
				FROM xf_ms_mobile_device_session
				WHERE device_key = ? AND session_token = ? AND expires_date > ?
			', [$deviceKey, $sessionToken, \XF::$time]);
		}

		if (!$row)
		{
			$row = $db->fetchRow('
				SELECT user_id, session_token
				FROM xf_ms_mobile_device_session
				WHERE device_key = ? AND expires_date > ?
				ORDER BY last_used_date DESC
				LIMIT 1
			', [$deviceKey, \XF::$time]);
		}

		if (!$row)
		{
			return null;
		}

		$userId = (int) $row['user_id'];
		if ($userId <= 0)
		{
			return null;
		}

		$db->update('xf_ms_mobile_device_session', [
			'last_used_date' => \XF::$time,
		], 'device_key = ? AND session_token = ?', [$deviceKey, $row['session_token']]);

		return [
			'user_id' => $userId,
			'session_token' => (string) $row['session_token'],
		];
	}

	protected function normalizeKey(string $key): string
	{
		$key = trim($key);
		if (strlen($key) > 128)
		{
			$key = substr($key, 0, 128);
		}

		return $key;
	}
}
