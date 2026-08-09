import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/config/app_branding.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/attachment_picker.dart' as attach_pick;
import 'package:kairete/core/utils/error_report_dialog.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/features/media/utils/media_navigation.dart';

class MediaComposeController extends GetxController {
  MediaComposeController({bool tenantMapped = false}) : _tenantMappedFlag = tenantMapped;

  final bool _tenantMappedFlag;

  final MediaService _service = MediaService();

  /// Tenant upload se esplicitamente richiesto o se siamo in una sotto-app.
  bool get isTenantUpload => _tenantMappedFlag || AppConfig.isTenantApp;

  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();

  final albums = <MediaAlbum>[].obs;
  final categories = <MediaCategory>[].obs;
  final selectedCategoryId = RxnInt();
  final selectedAlbumId = RxnInt();
  final pendingFile = RxnString();
  final pendingFilename = RxnString();

  final isLoading = true.obs;
  final isSending = false.obs;
  final canSend = false.obs;
  final loadError = ''.obs;
  final lastPublishError = ''.obs;

  List<MediaAlbum> get visibleAlbums {
    if (isTenantUpload) return albums;
    final categoryId = selectedCategoryId.value;
    if (categoryId == null || categoryId <= 0) {
      return albums;
    }
    return albums
        .where((a) => a.categoryId == 0 || a.categoryId == categoryId)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    titleCtrl.addListener(_onFieldsChanged);
    descriptionCtrl.addListener(_onFieldsChanged);
    _loadData();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    tagsCtrl.dispose();
    super.onClose();
  }

  void _onFieldsChanged() {
    final hasAlbum = (selectedAlbumId.value ?? 0) > 0;
    canSend.value = titleCtrl.text.trim().isNotEmpty &&
        hasAlbum &&
        pendingFile.value != null;
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    loadError.value = '';
    try {
      await AppBranding.ensureFromPackage();
      final useTenant = isTenantUpload;

      if (useTenant) {
        albums.value = await _service.fetchTenantUploadAlbums();
        categories.value = await _service.fetchTenantUploadCategories(
          uploadAlbums: albums,
        );
      } else {
        final results = await Future.wait([
          _service.fetchAlbums(),
          _service.fetchCategories(),
        ]);
        albums.value = results[0] as List<MediaAlbum>;
        categories.value = results[1] as List<MediaCategory>;
      }

      if (albums.isEmpty) {
        loadError.value = useTenant
            ? await _service.describeTenantUploadMappingIssue()
            : 'Nessun album disponibile. Verifica permessi Media Gallery sul forum.';
        return;
      }

      selectedAlbumId.value = albums.first.albumId;
      final album = albums.first;
      if (album.categoryId > 0) {
        selectedCategoryId.value = album.categoryId;
      } else if (categories.isNotEmpty) {
        selectedCategoryId.value = categories.first.categoryId;
      }

      _syncAlbumSelection();
      _onFieldsChanged();
    } on MediaException catch (e) {
      loadError.value = e.message;
    } catch (_) {
      loadError.value = 'Impossibile caricare album e categorie.';
    } finally {
      isLoading.value = false;
    }
  }

  void _syncAlbumSelection() {
    final visible = visibleAlbums;
    final current = selectedAlbumId.value;
    if (current != null &&
        visible.any((album) => album.albumId == current)) {
      return;
    }
    selectedAlbumId.value =
        visible.isNotEmpty ? visible.first.albumId : null;
  }

  void setCategoryId(int? categoryId) {
    selectedCategoryId.value = categoryId;
    _syncAlbumSelection();
    _onFieldsChanged();
  }

  void setAlbumId(int? albumId) {
    selectedAlbumId.value = albumId;
    if (albumId == null) {
      _onFieldsChanged();
      return;
    }
    final album = albums.firstWhereOrNull((a) => a.albumId == albumId);
    if (album != null && album.categoryId > 0) {
      selectedCategoryId.value = album.categoryId;
    }
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
    final categoryId = selectedCategoryId.value;
    final path = pendingFile.value;
    final name = pendingFilename.value;
    if (albumId == null ||
        albumId <= 0 ||
        path == null ||
        name == null) {
      return;
    }

    isSending.value = true;
    lastPublishError.value = '';
    try {
      final created = await _service.createMedia(
        title: titleCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        albumId: albumId,
        categoryId: categoryId ?? 0,
        tags: tagsCtrl.text.trim(),
        filePath: path,
        filename: name,
      );
      await MediaNavigation.openPublishedMedia(created.mediaId);
    } on MediaException catch (e) {
      lastPublishError.value = e.message;
      await showCopyableErrorDialog(title: 'Upload non riuscito', message: e.message);
    } on DioException catch (e) {
      final msg = XenforoApi.connectionMessage(e);
      lastPublishError.value = msg;
      await showCopyableErrorDialog(title: 'Upload non riuscito', message: msg);
    } catch (e) {
      final msg = e.toString();
      lastPublishError.value = msg;
      await showCopyableErrorDialog(title: 'Upload non riuscito', message: msg);
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
  final viewMembersCtrl = TextEditingController();
  final addMembersCtrl = TextEditingController();
  final selectedViewPrivacy = 'private'.obs;
  final selectedAddPrivacy = 'private'.obs;
  final coverPath = RxnString();
  final coverFilename = RxnString();

  final isSending = false.obs;
  final canSend = false.obs;

  @override
  void onInit() {
    super.onInit();
    titleCtrl.addListener(_onFieldsChanged);
    viewMembersCtrl.addListener(_onFieldsChanged);
    addMembersCtrl.addListener(_onFieldsChanged);
    _onFieldsChanged();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    viewMembersCtrl.dispose();
    addMembersCtrl.dispose();
    super.onClose();
  }

  void _onFieldsChanged() {
    final titleOk = titleCtrl.text.trim().isNotEmpty;
    final viewOk = selectedViewPrivacy.value != 'shared' ||
        viewMembersCtrl.text.trim().isNotEmpty;
    final addOk = selectedAddPrivacy.value != 'shared' ||
        addMembersCtrl.text.trim().isNotEmpty;
    canSend.value = titleOk && viewOk && addOk;
  }

  void setViewPrivacy(String value) {
    selectedViewPrivacy.value = value;
    _onFieldsChanged();
  }

  void setAddPrivacy(String value) {
    selectedAddPrivacy.value = value;
    _onFieldsChanged();
  }

  Future<void> pickCover() async {
    final files = await attach_pick.pickMediaAttachments(allowMultiple: false);
    if (files.isEmpty) return;
    final file = files.first;
    coverPath.value = file.path;
    coverFilename.value = file.displayName;
    _onFieldsChanged();
  }

  void clearCover() {
    coverPath.value = null;
    coverFilename.value = null;
    _onFieldsChanged();
  }

  Future<void> publish() async {
    if (!canSend.value || isSending.value) return;
    isSending.value = true;
    try {
      final categoryId = await _service.resolveDefaultMediaCategoryId();
      final album = await _service.createAlbum(
        title: titleCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        viewPrivacy: selectedViewPrivacy.value,
        addPrivacy: selectedAddPrivacy.value,
        viewUsers: viewMembersCtrl.text.trim(),
        addUsers: addMembersCtrl.text.trim(),
        categoryId: categoryId,
      );
      final coverFile = coverPath.value;
      final coverName = coverFilename.value;
      if (coverFile != null &&
          coverFile.isNotEmpty &&
          coverName != null &&
          coverName.isNotEmpty) {
        final mediaCategoryId =
            album.categoryId > 0 ? album.categoryId : categoryId;
        final cover = await _service.createMedia(
          title: titleCtrl.text.trim(),
          description: descriptionCtrl.text.trim(),
          albumId: album.albumId,
          categoryId: mediaCategoryId,
          filePath: coverFile,
          filename: coverName,
        );
        await MediaNavigation.openPublishedMedia(cover.mediaId);
        return;
      }
      Get.back(result: true);
    } on MediaException catch (e) {
      await showCopyableErrorDialog(title: 'Errore album', message: e.message);
    } on DioException catch (e) {
      await showCopyableErrorDialog(
        title: 'Errore album',
        message: XenforoApi.connectionMessage(e),
      );
    } catch (e) {
      await showCopyableErrorDialog(title: 'Errore album', message: e.toString());
    } finally {
      isSending.value = false;
    }
  }
}
