import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kairete/routes/app_pages.dart';
import 'app.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  await GetStorage.init();
  await AuthMiddleware.instance.getCurrenState();
  Get.put(DashboardController());

  runApp(
    MaterialApp(
      home: MyApp(),
      builder: EasyLoading.init(),
    ),
  );
}
