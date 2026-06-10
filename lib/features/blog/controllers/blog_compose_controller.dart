import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/services/attachment_service.dart';
import 'package:kairete/core/utils/attachment_picker.dart' as attach_pick;
import 'package:kairete/features/blog/models/blog_compose_options.dart';
import 'package:kairete/features/blog/services/blog_service.dart';

class BlogComposeController extends GetxController {
  BlogComposeController({this.editEntryId});

  final int? editEntryId;
  final BlogService _service = BlogService();
  final AttachmentService _attachments = AttachmentService();

  final titleCtrl = TextEditingController();
  final messageCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();

  final blogs = <WritableBlog>[].obs;
  final categories = <BlogCategoryOption>[].obs;
  final selectedBlogId = RxnInt();
  final selectedCategoryId = RxnInt();
  final existingAttachments = <String>[].obs;

  final isLoading = true.obs;
  final isSending = false.obs;
  final canSend = false.obs;
  final loadError = ''.obs;
  final pendingAttachments = <String>[].obs;
  final _attachmentPaths = <String, String>{};

  bool get isEditing => (editEntryId ?? 0) > 0;

  @override
  void onInit() {
    super.onInit();
    titleCtrl.addListener(_onFieldsChanged);
    messageCtrl.addListener(_onFieldsChanged);
    _loadOptions();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    messageCtrl.dispose();
    tagsCtrl.dispose();
    super.onClose();
  }

  void _onFieldsChanged() {
    canSend.value = titleCtrl.text.trim().isNotEmpty &&
        messageCtrl.text.trim().isNotEmpty &&
        (isEditing || (selectedBlogId.value ?? 0) > 0);
  }

  Future<void> _loadOptions() async {
    isLoading.value = true;
    loadError.value = '';
    try {
      final results = await Future.wait([
        _service.fetchWritableBlogs(),
        _service.fetchCategories(),
      ]);
      blogs.value = results[0] as List<WritableBlog>;
      categories.value = results[1] as List<BlogCategoryOption>;
      if (isEditing) {
        await _loadEntryForEdit();
      } else if (blogs.isNotEmpty) {
        selectedBlogId.value = blogs.first.blogId;
      }
      _onFieldsChanged();
    } on BlogException catch (e) {
      loadError.value = e.message;
    } catch (_) {
      loadError.value = 'Impossibile caricare i blog.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadEntryForEdit() async {
    final entry = await _service.fetchEntry(editEntryId!);
    titleCtrl.text = entry.title?.trim() ?? '';
    messageCtrl.text = entry.messagePlainText?.trim() ?? entry.previewBody;
    tagsCtrl.text = entry.tags.join(', ');
    selectedBlogId.value = entry.blog?.blogId;
    final categoryId = entry.category?.categoryId;
    selectedCategoryId.value = categoryId != null && categoryId > 0
        ? categoryId
        : null;
    existingAttachments.value = entry.attachments
        .map((a) => a.filename ?? a.directUrl ?? a.thumbnailUrl ?? '')
        .where((name) => name.trim().isNotEmpty)
        .toList();
  }

  void setBlogId(int? blogId) {
    if (isEditing) return;
    selectedBlogId.value = blogId;
    _onFieldsChanged();
  }

  void setCategoryId(int? categoryId) {
    selectedCategoryId.value = categoryId;
  }

  void addAttachment(String path, String displayName) {
    _attachmentPaths[displayName] = path;
    if (!pendingAttachments.contains(displayName)) {
      pendingAttachments.add(displayName);
    }
  }

  void removeAttachment(String displayName) {
    pendingAttachments.remove(displayName);
    _attachmentPaths.remove(displayName);
  }

  Future<void> pickAttachments() async {
    final files = await attach_pick.pickAttachments(allowMultiple: true);
    for (final file in files) {
      addAttachment(file.path, file.displayName);
    }
  }

  Future<void> reload() => _loadOptions();

  Future<void> publish() async {
    if (!canSend.value || isSending.value) return;
    final blogId = selectedBlogId.value;
    if (!isEditing && (blogId == null || blogId <= 0)) {
      Get.snackbar('Errore', 'Seleziona un blog.');
      return;
    }

    isSending.value = true;
    try {
      String attachmentKey = '';
      if (pendingAttachments.isNotEmpty) {
        final uploads = <({String path, String filename})>[];
        for (final name in pendingAttachments) {
          final path = _attachmentPaths[name];
          if (path != null) {
            uploads.add((path: path, filename: name));
          }
        }
        final session = await _attachments.uploadBlogFiles(
          blogId: blogId ?? 0,
          files: uploads,
        );
        attachmentKey = session.key;
      }

      if (isEditing) {
        await _service.updateEntry(
          blogEntryId: editEntryId!,
          title: titleCtrl.text.trim(),
          message: messageCtrl.text.trim(),
          categoryId: selectedCategoryId.value ?? 0,
          tags: tagsCtrl.text.trim(),
          attachmentHash: attachmentKey,
        );
      } else {
        await _service.createEntry(
          blogId: blogId!,
          title: titleCtrl.text.trim(),
          message: messageCtrl.text.trim(),
          categoryId: selectedCategoryId.value ?? 0,
          tags: tagsCtrl.text.trim(),
          attachmentHash: attachmentKey,
        );
      }
      Get.back(result: true);
    } on BlogException catch (e) {
      Get.snackbar('Errore', e.message);
    } on AttachmentException catch (e) {
      Get.snackbar('Errore allegati', e.message);
    } catch (_) {
      Get.snackbar('Errore', isEditing ? 'Modifica non riuscita.' : 'Pubblicazione non riuscita.');
    } finally {
      isSending.value = false;
    }
  }
}
