import 'package:get/get.dart';
import 'package:kairete/features/app_widgets/models/app_widget_models.dart';
import 'package:kairete/features/app_widgets/services/app_widgets_service.dart';
import 'package:kairete/features/app_widgets/utils/app_widget_injector.dart';

mixin AppWidgetsListMixin on GetxController {
  final appWidgetsPayload = Rxn<AppWidgetPayload>();

  Future<void> loadAppWidgets(
    String placement, {
    int? contextId,
    bool forceRefresh = true,
  }) async {
    appWidgetsPayload.value = await AppWidgetsService.instance.fetch(
      placement,
      contextId: contextId,
      forceRefresh: forceRefresh,
    );
  }

  /// Solo i widget del placement caricato (newsfeed / blog / …).
  List<Object> injectedSlots<T>(List<T> items) =>
      AppWidgetInjector.inject(items, appWidgetsPayload.value);
}
