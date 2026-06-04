import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_textfield_action.dart';
import 'package:kairete/constants/size.dart';
import 'package:kairete/features/forum/controllers/thread_comment_controller.dart';
import '../../../components/kairete_button.dart';
import '../../../components/kairete_form.dart';
import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import 'package:kairete/theme/kairete_theme.dart';
import 'package:kairete/widgets/cards/kairete_comment_card.dart';
import '../../newsfeed/screens/reply_screen.dart';

// ignore: must_be_immutable
class ThreadCommentScreen extends StatelessWidget {
  ThreadCommentScreen({Key? key}) : super(key: key);

  ThreadCommentController controller = Get.put(ThreadCommentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KaireteTheme.headerBackground,
        foregroundColor: KaireteTheme.textPrimary,
        title: Text(
          'Risposte',
          style: kTextHeadingStyle.copyWith(color: KaireteTheme.textPrimary),
        ),
        // actions: [
        //   Obx(() => KairetePrimaryButton(
        //         onTap: () {
        //           controller.postComent();
        //         },
        //         title: 'POST',
        //         width: 100,
        //         state: controller.isEnable.value
        //             ? StateButton.active
        //             : StateButton.disable,
        //       ))
        // ],
      ),
      // backgroundColor: Colors.white,
      bottomSheet: KaireteWriteTextField(
        onChanged: (p0) {
          controller.textOnChanged(text: p0);
        },
        onSend: (p0) {
          controller.postComent();
        },
        controller: controller.textEditingController,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: kBottomSafea + 80),
          child: Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              //   child: KaireteTextField(
              //     onChanged: (value) {
              //       controller.textOnChanged(text: value);
              //     },
              //     hint: 'Write something…',
              //     maxLine: 3,
              //     borderColor: kPrimaryColor,
              //     controller: controller.textEditingController,
              //     textStyle: kTextRegularStyle.copyWith(
              //       fontWeight: FontWeight.w300,
              //       fontSize: 18,
              //     ),
              //   ),
              // ),
              Obx(() => Expanded(
                    child: ListView.builder(
                      itemCount: controller.items.length,
                      itemBuilder: (context, index) {
                        final item = controller.items[index];
                        final html = (item.messageParsed ?? '')
                            .replaceAll('\n', '')
                            .replaceAll('=\\  ', '=')
                            .replaceAll('g\\', '');
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            KaireteCommentCard(
                              authorName: item.user?.username ?? 'Unknown',
                              dateLabel: '',
                              contentHtml: html.isEmpty ? '<p></p>' : html,
                              onTapReply: () {
                                controller.toSubReply(item: item);
                              },
                              onTapLike: item.canReact ?? true
                                  ? () {
                                      controller.showReactions(
                                          commentId: item.commentId ?? 0);
                                    }
                                  : null,
                            ),
                          ],
                        );
                      },
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
