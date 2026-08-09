import 'package:get/get.dart';
import 'package:kairete/features/social_news/models/social_news_models.dart';
import 'package:kairete/features/social_news/services/social_news_service.dart';

class SocialNewsHomeController extends GetxController {
  SocialNewsHomeController({this.publicationSlug});

  final String? publicationSlug;
  final SocialNewsService _service = SocialNewsService();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final homepage = Rxn<SocialNewsHomepage>();
  final publicationTitle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomepage();
  }

  Future<void> loadHomepage() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _service.fetchHomepage(publicationSlug: publicationSlug);
      publicationTitle.value = data.publication.title;
      homepage.value = data;
    } on SocialNewsException catch (e) {
      errorMessage.value = e.message;
      homepage.value = null;
      publicationTitle.value = '';
    } catch (_) {
      errorMessage.value = 'Impossibile caricare Social News.';
      homepage.value = null;
      publicationTitle.value = '';
    } finally {
      isLoading.value = false;
    }
  }
}
