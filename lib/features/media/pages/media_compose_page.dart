import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/config/app_build.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/features/media/controllers/media_compose_controller.dart';

class MediaComposePage extends StatefulWidget {
  const MediaComposePage({super.key, this.tenantMapped = false});

  final bool tenantMapped;

  @override
  State<MediaComposePage> createState() => _MediaComposePageState();
}

class _MediaComposePageState extends State<MediaComposePage> {
  late final String _controllerTag;

  @override
  void initState() {
    super.initState();
    final tenantMode = widget.tenantMapped || AppConfig.isTenantApp;
    _controllerTag = tenantMode ? 'media_compose_tenant' : 'media_compose_hub';
    if (Get.isRegistered<MediaComposeController>(tag: _controllerTag)) {
      Get.delete<MediaComposeController>(tag: _controllerTag, force: true);
    }
    Get.put(
      MediaComposeController(tenantMapped: tenantMode),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<MediaComposeController>(tag: _controllerTag)) {
      Get.delete<MediaComposeController>(tag: _controllerTag, force: true);
    }
    super.dispose();
  }

  MediaComposeController get _controller =>
      Get.find<MediaComposeController>(tag: _controllerTag);

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aggiungi media'),
            Text(
              AppBuild.appBarTitle,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: c.canSend.value && !c.isSending.value ? c.publish : null,
              child: Text(c.isSending.value ? '...' : 'Pubblica'),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.loadError.value.isNotEmpty) {
          return Center(child: Text(c.loadError.value));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (c.lastPublishError.value.isNotEmpty) ...[
              Material(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ultimo errore upload',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        c.lastPublishError.value,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: c.titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Titolo del media',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: c.descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrizione',
              ),
              minLines: 3,
              maxLines: 6,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: c.tagsCtrl,
              decoration: const InputDecoration(
                labelText: 'Tag',
                hintText: 'tag1, tag2, tag3',
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (c.isTenantUpload &&
                  c.categories.length <= 1 &&
                  c.albums.length <= 1) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (c.categories.length > 1)
                    DropdownButtonFormField<int>(
                      value: c.selectedCategoryId.value,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        helperText:
                            'Scegli la categoria XFMG (permessi video/foto/audio).',
                      ),
                      items: c.categories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat.categoryId,
                              child: Text(cat.title),
                            ),
                          )
                          .toList(),
                      onChanged: c.setCategoryId,
                    ),
                  if (c.categories.length > 1) const SizedBox(height: 12),
                  if (c.visibleAlbums.length > 1)
                    DropdownButtonFormField<int>(
                      value: c.visibleAlbums
                              .any((a) => a.albumId == c.selectedAlbumId.value)
                          ? c.selectedAlbumId.value
                          : null,
                      decoration: const InputDecoration(labelText: 'Album'),
                      items: c.visibleAlbums
                          .map(
                            (a) => DropdownMenuItem(
                              value: a.albumId,
                              child: Text(a.title),
                            ),
                          )
                          .toList(),
                      onChanged: c.setAlbumId,
                    ),
                  if (c.visibleAlbums.length > 1) const SizedBox(height: 16),
                ],
              );
            }),
            OutlinedButton.icon(
              onPressed: c.pickAttachment,
              icon: const Icon(Icons.attach_file),
              label: Obx(
                () => Text(
                  c.pendingFilename.value ?? 'Allegato (foto, video o audio)',
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
