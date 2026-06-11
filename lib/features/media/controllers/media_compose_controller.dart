import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/utils/attachment_picker.dart' as attach_pick;
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/services/media_service.dart';

class MediaComposeController extends GetxController {
  final MediaService _service = MediaService();

  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();

  final albums = <MediaAlbum>[].obs;
  final selectedAlbumId = RxnInt();
  final pendingFile = RxnString();
  final pendingFilename = RxnString();

  final isLoading = true.obs;
  final isSending = false.obs;
  final canSend = false.obs;
  final loadError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    titleCtrl.addListener(_onFieldsChanged);
    descriptionCtrl.addListener(_onFieldsChanged);
    _loadAlbums();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    tagsCtrl.dispose();
    super.onClose();
  }

  void _onFieldsChanged() {
    canSend.value = titleCtrl.text.trim().isNotEmpty &&
        (selectedAlbumId.value ?? 0) > 0 &&
        pendingFile.value != null;
  }

  Future<void> _loadAlbums() async {
    isLoading.value = true;
    loadError.value = '';
    try {
      albums.value = await _service.fetchAlbums();
      if (albums.isNotEmpty) {
        selectedAlbumId.value = albums.first.albumId;
      }
      _onFieldsChanged();
    } on MediaException catch (e) {
      loadError.value = e.message;
    } catch (_) {
      loadError.value = 'Impossibile caricare gli album.';
    } finally {
      isLoading.value = false;
    }
  }

  void setAlbumId(int? albumId) {
    selectedAlbumId.value = albumId;
    _onFieldsChanged();
  }

  Future<void> pickAttachment() async {
    final files = await attach_pick.pickMediaAttachments(allowMultiple: false);
    if (files.isEmpty) return;
    final file = files.first;
    pendingFile.value = file.path;
    pendingFilename.value = file.displayName;
    _onFieldsChanged();
  }

  Future<void> publish() async {
    if (!canSend.value || isSending.value) return;
    final albumId = selectedAlbumId.value;
    final path = pendingFile.value;
    final name = pendingFilename.value;
    if (albumId == null || albumId <= 0 || path == null || name == null) return;

    isSending.value = true;
    try {
      await _service.createMedia(
        title: titleCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        albumId: albumId,
        tags: tagsCtrl.text.trim(),
        filePath: path,
        filename: name,
      );
      Get.back(result: true);
    } on MediaException catch (e) {
      Get.snackbar('Errore', e.message);
    } catch (_) {
      Get.snackbar('Errore', 'Pubblicazione media non riuscita.');
    } finally {
      isSending.value = false;
    }
  }
}

class AlbumPrivacyOption {
  const AlbumPrivacyOption(this.label, this.value);
  final String label;
  final String value;
}

const albumPrivacyOptions = [
  AlbumPrivacyOption('Solo proprietario album', 'private'),
  AlbumPrivacyOption('Membri registrati', 'follow_member'),
  AlbumPrivacyOption('Tutti', 'public'),
  AlbumPrivacyOption('Membri specifici', 'shared'),
];

class AlbumCreateController extends GetxController {
  final MediaService _service = MediaService();

  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final selectedPrivacy = 'private'.obs;
  final pendingFile = RxnString();
  final pendingFilename = RxnString();

  final isSending = false.obs;
  final canSend = false.obs;

  @override
  void onInit() {
    super.onInit();
    titleCtrl.addListener(_onFieldsChanged);
    _onFieldsChanged();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }

  void _onFieldsChanged() {
    canSend.value = titleCtrl.text.trim().isNotEmpty;
  }

  void setPrivacy(String value) {
    selectedPrivacy.value = value;
  }

  Future<void> pickCover() async {
    final files = await attach_pick.pickMediaAttachments(allowMultiple: false);
    if (files.isEmpty) return;
    final file = files.first;
    pendingFile.value = file.path;
    pendingFilename.value = file.displayName;
  }

  Future<void> publish() async {
    if (!canSend.value || isSending.value) return;
    isSending.value = true;
    try {
      final album = await _service.createAlbum(
        title: titleCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        viewPrivacy: selectedPrivacy.value,
      );
      final coverPath = pendingFile.value;
      final coverName = pendingFilename.value;
      if (coverPath != null &&
          coverPath.isNotEmpty &&
          coverName != null &&
          coverName.isNotEmpty) {
        await _service.createMedia(
          title: titleCtrl.text.trim(),
          description: descriptionCtrl.text.trim(),
          albumId: album.albumId,
          filePath: coverPath,
          filename: coverName,
        );
      }
      Get.back(result: true);
    } on MediaException catch (e) {
      Get.snackbar('Errore', e.message);
    } catch (_) {
      Get.snackbar('Errore', 'Creazione album non riuscita.');
    } finally {
      isSending.value = false;
    }
  }
}
