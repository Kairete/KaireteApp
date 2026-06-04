import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_compose_controller.dart';

class OmnifeedComposePage extends StatefulWidget {
  const OmnifeedComposePage({super.key});

  @override
  State<OmnifeedComposePage> createState() => _OmnifeedComposePageState();
}

class _OmnifeedComposePageState extends State<OmnifeedComposePage> {
  @override
  void initState() {
    super.initState();
    Get.put(OmnifeedComposeController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<OmnifeedComposeController>()) {
      Get.delete<OmnifeedComposeController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OmnifeedComposeController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo post'),
        actions: [
          Obx(() {
            return TextButton(
              onPressed: c.canSend.value && !c.isSending.value
                  ? c.publish
                  : null,
              child: Text(c.isSending.value ? '...' : 'Pubblica'),
            );
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: c.messageCtrl,
          maxLines: 12,
          decoration: const InputDecoration(
            hintText: 'Scrivi qualcosa…',
            alignLabelWithHint: true,
          ),
        ),
      ),
    );
  }
}
