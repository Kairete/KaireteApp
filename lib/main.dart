import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kairete/admob/admob_manager.dart';
import 'package:kairete/routes/app_pages.dart';
// import 'package:requests_inspector/requests_inspector.dart';
import 'app.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdMobManager().initialize();
  await Firebase.initializeApp();
  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  // await GetStorage.init();
  await AuthMiddleware.instance.getCurrenState();

  Get.put(DashboardController());
  final navigatorKey = GlobalKey<NavigatorState>();

  runApp(
    MaterialApp(
      home: MyApp(),
      builder: EasyLoading.init(),
    ),
  );
}
