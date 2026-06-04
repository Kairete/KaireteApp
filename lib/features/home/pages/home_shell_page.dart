import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_page.dart';

class HomeShellPage extends GetView<AuthFlowController> {
  HomeShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OmniFeed'),
        actions: [
          IconButton(
            tooltip: 'Esci',
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: OmnifeedPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final feed = Get.find<OmnifeedController>();
          feed.openCompose();
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
