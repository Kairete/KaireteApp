import 'package:get/get.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_compose_page.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_detail_page.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';

class OmnifeedController extends GetxController {
  final OmnifeedService _service = OmnifeedService();

  final items = <OmnifeedItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeed();
  }

  Future<void> loadFeed() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final feed = await _service.fetchFeed();
      items.value = feed.items;
    } on OmnifeedException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Impossibile caricare il feed.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> react(OmnifeedItem item) async {
    try {
      await _service.reactToItem(itemId: item.itemId);
      await loadFeed();
    } on OmnifeedException catch (e) {
      Get.snackbar('Errore', e.message);
    }
  }

  void openDetail(OmnifeedItem item) {
    Get.to(() => OmnifeedDetailPage(item: item));
  }

  Future<void> openCompose() async {
    final created = await Get.to<bool>(() => const OmnifeedComposePage());
    if (created == true) await loadFeed();
  }
}
