import 'package:flutter/material.dart';
import 'package:kairete/features/tags/controllers/tags_controller.dart';
import 'package:get/get.dart';
import '../../../constants/app_routes.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';

class TagsScreen extends StatelessWidget {
  TagsScreen({super.key});
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  TagsController controller = Get.put(TagsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar(key: _key, isShowBack: true),
      body: Obx(() => ListView.builder(
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return NewfeedCell(
                onTapDetail: () {
                  controller.toDetail(item: item);
                },
                titleCate: item.category?.title,
                userName: item.user?.customFields?.fullName ??
                    item.user?.username ??
                    '',
                title: item.title,
                avatar: item.user?.avatarUrls?.l,
                date: item.attachments?[0].attachDate,
                blogTitle: item.blog?.title,
                thumbnailUrl: item.coverImage?.thumbnailUrl,
                messagePlainText: item.messagePlainText,
                reactionIconUrl: item.reactionIconUrl,
                reactions: item.reactions,
                shareCount: 0,
                // isShowShare: false,
                commentCount: item.commentCount,
                isShowLike: item.canReact ?? true,
                onTapReactions: () {
                  controller.showReactions(blogId: item.blogEntryId ?? 0);
                },
                onTapReply: () {
                  controller.toComment(item: item);
                },
                // tags: item.tags,
                // onTapTag: (tag) {
                //   Get.toNamed(
                //     Routes.tagsDetail,
                //     preventDuplicates: false,
                //   );
                //   Get.find<TagsController>().items.clear();
                //   Get.find<TagsController>()
                //       .fetchItems(id: tag?.replaceAll('#', '') ?? '');
                // },
              );
            },
          )),
    );
  }
}
