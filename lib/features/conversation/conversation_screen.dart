import 'package:flutter/material.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/components/kairete_textfield_action.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/features/conversation/conversation_controller.dart';
import 'package:kairete/features/conversation/create/conversation_create_screen.dart';
import 'package:kairete/features/conversation/message/message_screen.dart';
import 'package:kairete/features/dashboard/screens/dashboard_screen.dart';
import 'package:get/get.dart';

class ConversationScreen extends StatelessWidget {
  ConversationScreen({super.key});
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  ConversationController controller = Get.put(ConversationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar(
          key: _key,
          isShowBack: true,
          isShowMenu: false,
          isShowActions: false,
          isShowSearch: false,
          title: 'Conversatios'),
      // bottomSheet: KaireteWriteTextField(
      //   onChanged: (p0) {
      //     // controller.textOnChanged(text: p0);
      //   },
      //   onSend: () {
      //     // controller.postComent();
      //   },
      //   onTap: () {
      //     Get.to(
      //       () => ConversationCreateScreen(),
      //       fullscreenDialog: true,
      //     );
      //   },
      //   // controller: controller.textEditingController,
      // ),
      body: Container(
          child: Obx(
        () => ListView.separated(
          separatorBuilder: (context, index) {
            return Divider();
          },
          itemBuilder: (context, index) {
            final item = controller.conversations[index];
            return InkWell(
              onTap: () {
                Get.to(() => MessageScreen(), arguments: {
                  'id': item.id,
                  'firstMessageId': item.firstMessageId,
                });
              },
              child: Container(
                // height: 50,
                // color: Colors.red,
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KaireteCacheNetworkImage(
                      url: item.avatarUrls?.m ?? '',
                      isCircle: true,
                      width: 40,
                      height: 40,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title ?? '',
                            style: kTextRegularStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            item.message ?? '',
                            style: kTextRegularStyle.copyWith(fontSize: 16),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
          itemCount: controller.conversations.length,
        ),
      )),
    );
  }
}
