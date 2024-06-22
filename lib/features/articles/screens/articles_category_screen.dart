import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/features/articles/controllers/articles_category_controller.dart';
import 'package:kairete/features/articles/controllers/articles_detail_controller.dart';
import 'package:kairete/features/dashboard/screens/dashboard_screen.dart';
import 'package:kairete/helper/time.dart';

class AritclesCategoryScreen extends StatelessWidget {
  AritclesCategoryScreen({super.key});
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: baseAppBar(
          key: _key,
          isShowBack: true,
          isShowSearch: false,
          isShowActions: false,
          isShowMenu: false,
          title: 'Categories',
          onTapBack: () {
            Get.find<ArticlesDetailController>().updateOriginData();
          }),
      body: GetX<ArticlesCategoryController>(
        init: ArticlesCategoryController(),
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: () async {
              controller.fetchItems(isRefresh: true);
            },
            child: Container(
              padding: EdgeInsets.only(
                top: 24,
              ),
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return Container(
                    height: 3,
                    color: Colors.grey.shade400,
                    margin: EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                    ),
                  );
                },
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return InkWell(
                    onTap: () {
                      controller.toDetail(item: item);
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KaireteCacheNetworkImage(
                            url: item.coverImage?.thumbnailUrl ?? '',
                            width: 120,
                            height: 60,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  TimeManager.instance.convertFromTimeStamp(
                                      timestamp:
                                          item.attachments?[0].attachDate ?? 0),
                                  style:
                                      kTextRegularStyle.copyWith(fontSize: 14),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  item.title ?? '',
                                  maxLines: 3,
                                  style: kTextTitleBlog.copyWith(
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                  // return cell(controller, item);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
