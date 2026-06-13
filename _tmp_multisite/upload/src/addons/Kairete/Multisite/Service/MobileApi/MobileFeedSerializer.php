<?php

namespace Kairete\Multisite\Service\MobileApi;

use Kairete\OmniFeed\Service\MobileApi\ApiSerializer;
use Kairete\OmniFeed\Service\MobileApi\FeedAssembler;
use Kairete\OmniFeed\Service\MobileApi\ItemIdCodec;
use XF\Entity\Post;
use XF\Entity\Thread;

/**
 * Converte item wall/feed mappati Multisite in payload newsfeed mobile (OmniFeed).
 */
class MobileFeedSerializer
{
	public static function omniAvailable(): bool
	{
		return \class_exists(ApiSerializer::class) && \class_exists(ItemIdCodec::class);
	}

	/**
	 * @param array<string, mixed> $item
	 * @return array<string, mixed>|null
	 */
	public static function fromMappedWallItem(array $item): ?array
	{
		if (!self::omniAvailable())
		{
			return null;
		}

		$type = (string) ($item['type'] ?? '');

		if ($type === 'ksg_post' && !empty($item['post']))
		{
			return ApiSerializer::groupPost($item['post']);
		}

		if ($type === 'ms_mapped_thread')
		{
			$content = $item['mappedReactContent'] ?? null;
			if ($content instanceof Thread)
			{
				$preview = (string) ($item['mappedPreview'] ?? '');

				return ApiSerializer::thread($content, $preview);
			}
			if ($content instanceof Post && $content->Thread)
			{
				$preview = (string) ($item['mappedPreview'] ?? '');

				return ApiSerializer::thread($content->Thread, $preview);
			}
		}

		if ($type === 'ms_mapped_blog' && !empty($item['mappedReactContent']))
		{
			$post = $item['mappedReactContent'];
			if (\class_exists(FeedAssembler::class))
			{
				$assembler = new FeedAssembler(\XF::app());
				$ref = new \ReflectionClass($assembler);
				if ($ref->hasMethod('serializeBlogItem'))
				{
					$method = $ref->getMethod('serializeBlogItem');
					$method->setAccessible(true);
					$preview = (string) ($item['mappedPreview'] ?? '');

					return $method->invoke($assembler, [
						'previewText' => $preview,
						'openUrl' => (string) ($item['mappedOpenUrl'] ?? ''),
					], $post);
				}
			}
		}

		if ($type === 'ms_mapped_media' && !empty($item['mappedReactContent']))
		{
			$preview = (string) ($item['mappedPreview'] ?? '');

			return ApiSerializer::media($item['mappedReactContent'], $preview);
		}

		return null;
	}

	/**
	 * @param list<array<string, mixed>> $items
	 * @return list<array<string, mixed>>
	 */
	public static function fromMappedWallItems(array $items): array
	{
		$out = [];
		foreach ($items as $item)
		{
			if (!\is_array($item))
			{
				continue;
			}
			$payload = self::fromMappedWallItem($item);
			if ($payload)
			{
				$out[] = $payload;
			}
		}

		return $out;
	}
}
