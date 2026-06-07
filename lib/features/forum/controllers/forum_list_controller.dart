import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/features/forum/models/forum_node.dart';
import 'package:kairete/features/forum/pages/forum_thread_list_page.dart';
import 'package:kairete/features/forum/services/forum_service.dart';

class ForumListController extends GetxController {
  final ForumService _service = ForumService();

  final groups = <ForumNodeGroup>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadForums();
  }

  Future<void> loadForums() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      groups.value = await _service.fetchForumGroups().timeout(
            const Duration(seconds: 25),
          );
    } on TimeoutException {
      errorMessage.value =
          'Il forum impiega troppo tempo. Controlla la rete e riprova.';
    } on ForumException catch (e) {
      errorMessage.value = e.message;
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      errorMessage.value = 'Impossibile caricare i forum.';
    } finally {
      isLoading.value = false;
    }
  }

  void openForum(ForumNode forum) {
    Get.to(
      () => ForumThreadListPage(
        forumId: forum.nodeId,
        forumTitle: forum.title,
      ),
    );
  }
}
