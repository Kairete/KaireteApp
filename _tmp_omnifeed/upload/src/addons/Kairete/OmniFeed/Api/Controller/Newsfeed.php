<?php

namespace Kairete\OmniFeed\Api\Controller;

use Kairete\OmniFeed\Service\MobileApi\FeedAssembler;
use XF\Api\Controller\AbstractController;
use XF\Mvc\ParameterBag;

class Newsfeed extends AbstractController
{
	public function actionGet(ParameterBag $params)
	{
		$this->assertRegisteredUser();

		$page = \max(1, (int) $this->filter('page', 'uint'));
		$limit = (int) $this->filter('limit', 'uint');
		if ($limit < 1) {
			$limit = 10;
		}
		$mode = (string) $this->filter('mode', 'str');
		if ($mode === '') {
			$mode = 'network';
		}
		$sort = (string) $this->filter('sort', 'str');
		if ($sort === '') {
			$sort = 'post_date';
		}

		try {
			$assembler = new FeedAssembler($this->app());
			$result = $assembler->buildFeed($mode, $page, $limit, $sort);

			return $this->apiResult($result);
		} catch (\Throwable $e) {
			\XF::logException($e, false, 'OmniFeed API newsfeed: ');

			return $this->error(\XF::phrase('unexpected_error_occurred'), 500);
		}
	}

	/**
	 * POST api/newsfeed/post — pubblica sul proprio profilo (app mobile).
	 */
	public function actionPost(ParameterBag $params)
	{
		$this->assertRegisteredUser();
		$this->assertApiScopeByRequestMethod('newsfeed');

		$visitor = \XF::visitor();
		$message = \trim((string) $this->filter('message', 'str'));
		$attachmentHash = \trim((string) $this->filter('attachment_hash', 'str'));
		if ($attachmentHash === '') {
			$attachmentHash = \trim((string) $this->filter('attachment_key', 'str'));
		}
		if ($message === '' && $attachmentHash === '') {
			return $this->error(\XF::phrase('please_enter_valid_message'));
		}

		$tenantId = 0;
		if (\class_exists(\Kairete\Multisite\Service\MobileApi\TenantScopedFeed::class)) {
			$tenantId = \Kairete\Multisite\Service\MobileApi\TenantScopedFeed::resolveTenantIdFromApp($this->app());
		}
		if ($tenantId > 0
			&& \class_exists(\Kairete\Multisite\Service\MobileApi\TenantContext::class)
			&& \class_exists(\Kairete\Multisite\Service\Member\TenantProfilePostBridge::class)) {
			$tenant = \Kairete\Multisite\Service\MobileApi\TenantContext::resolveActiveTenant($this->app(), $tenantId);
			if ($tenant) {
				if ($attachmentHash !== '') {
					return $this->error('Gli allegati sul profilo tenant non sono ancora supportati. Pubblica solo testo.');
				}
				if (!\Kairete\Multisite\Service\Member\TenantProfilePostBridge::createGroupPost(
					$this->app(),
					$tenant,
					$visitor,
					$message !== '' ? $message : ' '
				)) {
					return $this->error(\XF::phrase('unexpected_error_occurred'));
				}

				return $this->apiSuccess([
					'tenant_id' => $tenantId,
					'posted_to' => 'tenant_group',
				]);
			}
		}

		if (!$visitor->hasPermission('profilePost', 'post')) {
			return $this->noPermission();
		}

		$userProfile = $visitor->Profile;
		if (!$userProfile) {
			return $this->error(\XF::phrase('unexpected_error_occurred'));
		}

		/** @var \XF\Service\ProfilePost\Creator $creator */
		$creator = $this->service('XF:ProfilePost\Creator', $userProfile);
		if (\method_exists($creator, 'setMessage')) {
			$creator->setMessage($message !== '' ? $message : ' ');
		} else {
			$creator->setContent($message !== '' ? $message : ' ');
		}
		if ($attachmentHash !== '' && \method_exists($creator, 'setAttachmentHash')) {
			$hash = $attachmentHash;
			if (\method_exists($this, 'getAttachmentTempHashFromKey')) {
				$converted = (string) $this->getAttachmentTempHashFromKey(
					$attachmentHash,
					'profile_post',
					['profile_user_id' => (int) $visitor->user_id]
				);
				if ($converted !== '') {
					$hash = $converted;
				}
			}
			$creator->setAttachmentHash($hash);
		}

		if (!$creator->validate($errors)) {
			return $this->error($errors);
		}

		/** @var \XF\Entity\ProfilePost $profilePost */
		$profilePost = $creator->save();
		if (\method_exists($creator, 'sendNotifications')) {
			$creator->sendNotifications();
		}

		return $this->apiSuccess([
			'profile_post_id' => (int) $profilePost->profile_post_id,
		]);
	}

	/**
	 * POST api/newsfeed/blog-post — articolo blog da composer OmniFeed (app mobile).
	 */
	public function actionPostBlog(ParameterBag $params)
	{
		$this->assertRegisteredUser();
		$this->assertApiScopeByRequestMethod('newsfeed');

		if (!\XF::isAddOnActive('Kairete/Blog')
			|| !\class_exists(\Kairete\Blog\Service\MobileApi\BlogComposeAssembler::class)) {
			return $this->error(\XF::phrase('unexpected_error_occurred'));
		}

		$blogId = $this->filter('blog_id', 'uint');
		$title = \trim((string) $this->filter('title', 'str'));
		$message = \trim((string) $this->filter('message', 'str'));
		$categoryId = $this->filter('category_id', 'uint');
		$tags = \trim((string) $this->filter('tags', 'str'));
		$attachmentHash = \trim((string) $this->filter('attachment_hash', 'str'));

		if ($title === '' || $message === '' || $blogId <= 0) {
			return $this->error(\XF::phrase('please_enter_valid_message'));
		}

		try {
			$compose = new \Kairete\Blog\Service\MobileApi\BlogComposeAssembler($this->app());
			$entry = $compose->createEntry($blogId, $title, $message, $categoryId, $tags, $attachmentHash);
		} catch (\InvalidArgumentException $e) {
			return $this->error($e->getMessage());
		} catch (\Throwable $e) {
			\XF::logException($e, false, 'OmniFeed API blog post: ');

			return $this->error(\XF::phrase('unexpected_error_occurred'));
		}

		$postId = 0;
		if (\is_object($entry) && isset($entry->post_id)) {
			$postId = (int) $entry->post_id;
		} elseif (\is_array($entry) && isset($entry['post_id'])) {
			$postId = (int) $entry['post_id'];
		}

		return $this->apiSuccess([
			'blog_post_id' => $postId,
		]);
	}

	/**
	 * GET api/newsfeed/user-feed?id={userId}
	 */
	public function actionGetUserFeed(ParameterBag $params)
	{
		$this->assertRegisteredUser();

		$userId = (int) $this->filter('id', 'uint');
		if ($userId <= 0) {
			$userId = (int) \XF::visitor()->user_id;
		}
		$page = \max(1, (int) $this->filter('page', 'uint'));
		$limit = (int) $this->filter('limit', 'uint');
		if ($limit < 1) {
			$limit = 20;
		}
		$sort = (string) $this->filter('sort', 'str');
		if ($sort === '') {
			$sort = 'post_date';
		}

		try {
			$tenantId = 0;
			if (\class_exists(\Kairete\Multisite\Service\MobileApi\TenantScopedFeed::class)) {
				$tenantId = \Kairete\Multisite\Service\MobileApi\TenantScopedFeed::resolveTenantIdFromApp($this->app());
			}
			if ($tenantId > 0
				&& \class_exists(\Kairete\Multisite\Service\MobileApi\TenantContext::class)
				&& \class_exists(\Kairete\Multisite\Service\MobileApi\TenantScopedFeed::class)) {
				$tenant = \Kairete\Multisite\Service\MobileApi\TenantContext::resolveActiveTenant($this->app(), $tenantId);
				if ($tenant) {
					$result = (new \Kairete\Multisite\Service\MobileApi\TenantScopedFeed($this->app()))
						->buildUserMappedFeed($tenant, $userId, $page, $limit);

					return $this->apiResult($result);
				}
			}

			$assembler = new FeedAssembler($this->app());
			$result = $assembler->buildUserFeed($userId, $page, $limit, $sort);

			return $this->apiResult($result);
		} catch (\Throwable $e) {
			\XF::logException($e, false, 'OmniFeed API user-feed: ');

			return $this->error(\XF::phrase('unexpected_error_occurred'), 500);
		}
	}

	/**
	 * GET api/newsfeed/forum-watch?forum_id=
	 */
	public function actionGetForumWatch(ParameterBag $params)
	{
		$this->assertRegisteredUser();

		$forumId = (int) $this->filter('forum_id', 'uint');
		if ($forumId <= 0) {
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		/** @var \XF\Entity\Forum|null $forum */
		$forum = $this->em()->find('XF:Forum', $forumId);
		if (!$forum || !$forum->canView()) {
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		$visitor = \XF::visitor();
		$isWatched = false;
		if ($visitor->user_id) {
			$watch = $this->finder('XF:ForumWatch')
				->where('node_id', $forumId)
				->where('user_id', $visitor->user_id)
				->fetchOne();
			$isWatched = $watch !== null;
		}

		return $this->apiResult([
			'forum_id' => $forumId,
			'is_watched' => $isWatched,
			'can_watch' => $forum->canWatch(),
		]);
	}

	/**
	 * POST api/newsfeed/forum-watch — body: forum_id, stop (optional)
	 */
	public function actionPostForumWatch(ParameterBag $params)
	{
		$this->assertRegisteredUser();

		$forumId = (int) $this->filter('forum_id', 'uint');
		if ($forumId <= 0) {
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		/** @var \XF\Entity\Forum|null $forum */
		$forum = $this->em()->find('XF:Forum', $forumId);
		if (!$forum || !$forum->canView()) {
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		if (!$forum->canWatch()) {
			return $this->noPermission();
		}

		$stop = $this->filter('stop', 'bool');
		$visitor = \XF::visitor();

		try {
			/** @var \XF\Repository\ForumWatch $forumWatchRepo */
			$forumWatchRepo = $this->repository('XF:ForumWatch');
			if ($stop) {
				$forumWatchRepo->setWatchState($forum, $visitor, 'delete');
			} else {
				$forumWatchRepo->setWatchState($forum, $visitor, 'thread', true, false);
			}
		} catch (\Throwable $e) {
			\XF::logException($e, false, 'OmniFeed API forum-watch: ');

			return $this->error(\XF::phrase('unexpected_error_occurred'), 500);
		}

		$watch = $this->finder('XF:ForumWatch')
			->where('node_id', $forumId)
			->where('user_id', $visitor->user_id)
			->fetchOne();

		return $this->apiResult([
			'success' => true,
			'forum_id' => $forumId,
			'is_watched' => $watch !== null,
		]);
	}

	/**
	 * POST api/newsfeed/media-upload — upload foto/video/audio in album (app mobile).
	 */
	public function actionPostMediaUpload(ParameterBag $params)
	{
		try {
			$this->assertRegisteredUser();
			$this->assertApiScopeByRequestMethod('newsfeed');

			if (!\class_exists('XFMG\Entity\Album')
				|| !\class_exists(\Kairete\OmniFeed\Service\MobileApi\MediaComposeAssembler::class)) {
				return $this->error(\XF::phrase('requested_page_not_found'), 404);
			}

			$albumId = (int) $this->filter('album_id', 'uint');
			$categoryId = (int) $this->filter('category_id', 'uint');
			$title = \trim((string) $this->filter('title', 'str'));
			$description = \trim((string) $this->filter('description', 'str'));
			$tags = \trim((string) $this->filter('tags', 'str'));

			if ($albumId <= 0 || $title === '') {
				return $this->error(\XF::phrase('please_enter_valid_message'));
			}

			$upload = $this->resolveApiUploadFile();
			if (!$upload) {
				return $this->error('File mancante. Invia il file come multipart con campo "file".');
			}

			$assembler = new \Kairete\OmniFeed\Service\MobileApi\MediaComposeAssembler($this->app());
			$media = $assembler->createMediaInAlbum(
				$albumId,
				$title,
				$description,
				$tags,
				$upload,
				$categoryId
			);

			return $this->apiResult([
				'success' => true,
				'media' => $this->serializeMediaForMobileApi($media),
			]);
		} catch (\InvalidArgumentException $e) {
			return $this->error($e->getMessage());
		} catch (\XF\PrintableException $e) {
			return $this->error((string) $e->getMessage());
		} catch (\Throwable $e) {
			\XF::logException($e, false, 'OmniFeed API media-upload: ');

			return $this->error($this->formatMediaUploadError($e), 500);
		}
	}

	protected function formatMediaUploadError(\Throwable $e): string
	{
		$msg = \trim($e->getMessage());
		if ($msg !== '' && \strlen($msg) <= 500 && !\str_contains($msg, 'Stack trace')) {
			return $msg;
		}

		return 'Errore upload media. Verifica permessi XFMG, tipo video abilitato nella categoria e limiti PHP (upload_max_filesize).';
	}

	/**
	 * @return array<string, mixed>
	 */
	protected function resolveApiUploadFile(): ?\XF\Http\Upload
	{
		foreach (['file', 'upload', 'attachment', 'media'] as $field) {
			$upload = $this->request->getFile($field, false);
			if ($upload && $this->isUsableUpload($upload)) {
				return $upload;
			}
		}

		foreach (['file', 'upload', 'attachment', 'media'] as $field) {
			if (empty($_FILES[$field]) || !\is_array($_FILES[$field])) {
				continue;
			}
			$file = $_FILES[$field];
			$error = (int) ($file['error'] ?? UPLOAD_ERR_OK);
			if ($error !== UPLOAD_ERR_OK) {
				throw new \InvalidArgumentException($this->uploadErrorMessage($error));
			}

			$tmpName = (string) ($file['tmp_name'] ?? '');
			if ($tmpName === '') {
				continue;
			}
			if (!\is_uploaded_file($tmpName) && !@\is_readable($tmpName)) {
				continue;
			}

			return new \XF\Http\Upload(
				UPLOAD_ERR_OK,
				(string) ($file['name'] ?? 'upload.bin'),
				(string) ($file['type'] ?? 'application/octet-stream'),
				$tmpName,
				(int) ($file['size'] ?? 0)
			);
		}

		return $this->resolveBase64UploadFile();
	}

	protected function isUsableUpload(\XF\Http\Upload $upload): bool
	{
		if (\method_exists($upload, 'isValid')) {
			return (bool) $upload->isValid();
		}

		return true;
	}

	protected function resolveBase64UploadFile(): ?\XF\Http\Upload
	{
		$raw = \trim((string) $this->filter('file_base64', 'str'));
		if ($raw === '') {
			return null;
		}

		$data = \base64_decode($raw, true);
		if ($data === false || $data === '') {
			throw new \InvalidArgumentException('file_base64 non valido.');
		}

		$maxBytes = 25 * 1024 * 1024;
		if (\strlen($data) > $maxBytes) {
			throw new \InvalidArgumentException(
				'File troppo grande per upload base64 (max 25 MB). Aumenta upload_max_filesize in PHP.'
			);
		}

		$name = \trim((string) $this->filter('file_name', 'str'));
		if ($name === '') {
			$name = 'upload.bin';
		}
		$mime = \trim((string) $this->filter('file_mime', 'str'));
		if ($mime === '') {
			$mime = 'application/octet-stream';
		}

		$tmp = \tempnam(\sys_get_temp_dir(), 'omni_media_');
		if ($tmp === false) {
			throw new \InvalidArgumentException('Impossibile creare file temporaneo sul server.');
		}
		if (@\file_put_contents($tmp, $data) === false) {
			@\unlink($tmp);
			throw new \InvalidArgumentException('Impossibile salvare il file temporaneo sul server.');
		}

		return new \XF\Http\Upload(
			UPLOAD_ERR_OK,
			$name,
			$mime,
			$tmp,
			\strlen($data)
		);
	}

	protected function uploadErrorMessage(int $code): string
	{
		switch ($code) {
			case UPLOAD_ERR_INI_SIZE:
			case UPLOAD_ERR_FORM_SIZE:
				return 'File troppo grande per i limiti PHP del server (upload_max_filesize / post_max_size). Chiedi almeno 128M.';
			case UPLOAD_ERR_PARTIAL:
				return 'Upload interrotto: file ricevuto solo in parte. Riprova con connessione stabile.';
			case UPLOAD_ERR_NO_FILE:
				return 'File mancante. Invia il file come multipart con campo "file".';
			default:
				return 'Errore upload file (codice ' . $code . ').';
		}
	}

	/**
	 * @return array<string, mixed>
	 */
	protected function serializeMediaForMobileApi($media): array
	{
		if (\class_exists(\Kairete\OmniFeed\Service\MobileApi\ApiSerializer::class)) {
			try {
				return \Kairete\OmniFeed\Service\MobileApi\ApiSerializer::media($media);
			} catch (\Throwable $e) {
				\XF::logException($e, false, 'OmniFeed API media serialize: ');
			}
		}

		if (\method_exists($media, 'toApiResult')) {
			try {
				$result = $media->toApiResult();
				if (\is_array($result)) {
					return $result;
				}
				if (\is_object($result) && \method_exists($result, 'render')) {
					$rendered = $result->render();
					if (\is_array($rendered)) {
						return $rendered;
					}
				}
			} catch (\Throwable $e) {
				\XF::logException($e, false, 'OmniFeed API media serialize: ');
			}
		}

		$viewUrl = '';
		if (\method_exists($media, 'getContentUrl')) {
			$viewUrl = (string) $media->getContentUrl();
		}

		$album = $media->Album ?? null;
		$albumId = (int) ($media->album_id ?? 0);
		$albumTitle = '';
		if ($album) {
			$albumId = (int) ($album->album_id ?? $albumId);
			$albumTitle = (string) ($album->title ?? '');
		}

		return [
			'media_id' => (int) ($media->media_id ?? 0),
			'title' => (string) ($media->title ?? ''),
			'description' => (string) ($media->description ?? ''),
			'media_date' => (int) ($media->media_date ?? 0),
			'media_type' => (string) ($media->media_type ?? ''),
			'album_id' => $albumId,
			'album_label' => $albumTitle,
			'category_id' => (int) ($media->category_id ?? 0),
			'view_url' => $viewUrl,
			'Album' => $albumId > 0
				? ['album_id' => $albumId, 'title' => $albumTitle]
				: null,
		];
	}

	/**
	 * GET api/newsfeed/album-watch?album_id=
	 */
	public function actionGetAlbumWatch(ParameterBag $params)
	{
		$this->assertRegisteredUser();

		if (!\class_exists('XFMG\Entity\Album')) {
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		$albumId = (int) $this->filter('album_id', 'uint');
		if ($albumId <= 0) {
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		/** @var \XFMG\Entity\Album|null $album */
		$album = $this->em()->find('XFMG:Album', $albumId);
		if (!$album || !$album->canView()) {
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		$visitor = \XF::visitor();
		$isWatched = false;
		if ($visitor->user_id) {
			$watch = $this->finder('XFMG:AlbumWatch')
				->where('album_id', $albumId)
				->where('user_id', $visitor->user_id)
				->fetchOne();
			$isWatched = $watch !== null;
		}

		return $this->apiResult([
			'album_id' => $albumId,
			'is_watched' => $isWatched,
			'can_watch' => \method_exists($album, 'canWatch') ? $album->canWatch() : true,
		]);
	}

	/**
	 * POST api/newsfeed/album-watch — body: album_id, stop (optional)
	 */
	public function actionPostAlbumWatch(ParameterBag $params)
	{
		$this->assertRegisteredUser();

		if (!\class_exists('XFMG\Entity\Album')) {
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		$albumId = (int) $this->filter('album_id', 'uint');
		if ($albumId <= 0) {
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		/** @var \XFMG\Entity\Album|null $album */
		$album = $this->em()->find('XFMG:Album', $albumId);
		if (!$album || !$album->canView()) {
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		if (\method_exists($album, 'canWatch') && !$album->canWatch()) {
			return $this->noPermission();
		}

		$stop = $this->filter('stop', 'bool');
		$visitor = \XF::visitor();

		try {
			/** @var \XFMG\Repository\AlbumWatch $albumWatchRepo */
			$albumWatchRepo = $this->repository('XFMG:AlbumWatch');
			if ($stop) {
				$albumWatchRepo->setWatchState($album, $visitor, 'delete');
			} else {
				$albumWatchRepo->setWatchState($album, $visitor, 'watch');
			}
		} catch (\Throwable $e) {
			\XF::logException($e, false, 'OmniFeed API album-watch: ');

			return $this->error(\XF::phrase('unexpected_error_occurred'), 500);
		}

		$watch = $this->finder('XFMG:AlbumWatch')
			->where('album_id', $albumId)
			->where('user_id', $visitor->user_id)
			->fetchOne();

		return $this->apiResult([
			'success' => true,
			'album_id' => $albumId,
			'is_watched' => $watch !== null,
		]);
	}

	/**
	 * GET api/newsfeed/compose-attachments?context=profile
	 */
	public function actionGetComposeAttachments(ParameterBag $params)
	{
		$this->assertRegisteredUser();

		$context = (string) $this->filter('context', 'str');
		if ($context !== 'profile') {
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		$visitor = \XF::visitor();
		if (!$visitor->hasPermission('profilePost', 'post')) {
			return $this->noPermission();
		}

		$data = $this->getProfileAttachmentEditorData((int) $visitor->user_id);

		return $this->apiResult([
			'hash' => (string) ($data['hash'] ?? ''),
			'key' => (string) ($data['hash'] ?? ''),
			'type' => 'profile_post',
			'profile_user_id' => (int) $visitor->user_id,
		]);
	}

	/**
	 * @return array{type: string, hash: string, context: array<string, int>}
	 */
	protected function getProfileAttachmentEditorData(int $profileUserId): array
	{
		if ($profileUserId <= 0) {
			return ['type' => 'profile_post', 'hash' => '', 'context' => []];
		}

		try {
			$repo = $this->repository('XF:Attachment');
			if (\method_exists($repo, 'getEditorData')) {
				$profile = $this->em()->find('XF:UserProfile', $profileUserId);
				if ($profile) {
					$data = $repo->getEditorData('profile_post', $profile);
					if (\is_array($data) && !empty($data['hash'])) {
						return [
							'type' => 'profile_post',
							'hash' => (string) $data['hash'],
							'context' => ['profile_user_id' => $profileUserId],
						];
					}
				}
			}
			if (\method_exists($repo, 'insertTemporaryAttachmentHash')) {
				return [
					'type' => 'profile_post',
					'hash' => (string) $repo->insertTemporaryAttachmentHash(),
					'context' => ['profile_user_id' => $profileUserId],
				];
			}
		} catch (\Throwable $e) {
			\XF::logException($e, false, 'OmniFeed API profile attach hash: ');
		}

		return [
			'type' => 'profile_post',
			'hash' => \XF::generateRandomString(32),
			'context' => ['profile_user_id' => $profileUserId],
		];
	}
}
