import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:hashtagable/widgets/hashtag_text.dart';
import 'package:kairete/admob/admob_manager.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/components/kairete_icon.dart';
import 'package:kairete/components/kairete_textfield_action.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/features/articles/models/articles_model.dart';
import 'package:kairete/features/articles/screens/articles_category_screen.dart';
import 'package:kairete/features/blogs/screens/my_blog_screen.dart';
import 'package:kairete/features/dashboard/controllers/dashboard_controller.dart';
import 'package:kairete/features/forum/models/forum_model.dart';
import 'package:kairete/features/forum/screens/forum_detail_screen.dart';
import 'package:kairete/features/groups/controllers/group_controller.dart';
import 'package:kairete/features/groups/screens/newfeed_group_screen.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_controller.dart';
import 'package:get/get.dart';
import 'package:kairete/features/newsfeed/models/suggestion_model/suggestion_model.dart';
import 'package:kairete/features/newsfeed/screens/create_newsfeed_screen.dart';
import 'package:kairete/features/profile/usecase/user_profile_usecase.dart';
import 'package:kairete/helper/extenstions.dart';
import 'package:kairete/helper/time.dart';
import 'package:kairete/helper/user.dart';
import '../../../components/kairete_button.dart';
import '../../../components/kairete_popup.dart';
import '../../../components/reactions_view.dart';
import '../../../constants/app_routes.dart';
import '../../dashboard/models/style_model/css.dart';
import '../../login/models/user_model.dart';
import '../models/newsfeed_model.dart';
import '../usecase/newsfeed_usecase.dart';

// ignore: must_be_immutable
class NewsFeedScreen extends StatelessWidget {
  NewsFeedScreen({Key? key}) : super(key: key);

  NewsFeedController controller = Get.put(NewsFeedController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.items.isEmpty
        ? const SizedBox()
        : Scaffold(
            // bottomSheet: KaireteWriteTextField(
            //   onTap: () {
            //     controller.toCreate();
            //   },
            // ),
            // bottomSheet: AdMobManager().getBannerAdWidget(),
            body: NewsfeedListItem(
              items: controller.items.value,
              onCreate: () {
                controller.toCreate();
              },
              onTapDetail: (item) {
                controller.toDetail(item: item);
              },
              onFilter: () {
                controller.onFilter();
              },
              onTabFilter: (value) {
                controller.onSelectedTabFilter(index: value);
              },
              suggestions: controller.suggestions.value,
            ),
          ));
  }
}

// ignore: must_be_immutable

class NewsfeedListItem extends GetView<NewsFeedController> {
  const NewsfeedListItem({
    Key? key,
    required this.items,
    this.onTapDetail,
    this.onCreate,
    this.isShowCreate = true,
    this.onFilter,
    this.onTabFilter,
    this.suggestions,
  }) : super(key: key);

  final List<NewsfeedModel> items;
  final Function(NewsfeedModel)? onTapDetail;
  final Function? onCreate;
  final bool isShowCreate;
  final Function? onFilter;
  final Function(int)? onTabFilter;
  final SuggestionModel? suggestions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: ListView.builder(
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          final originIndex = index == 0 ? 0 : index - 1;
          final item = items[originIndex];
          return index == 0
              ? (isShowCreate ? createView() : const SizedBox())
              : getView(index: index, list: controller.randomList, item: item);
        },
      ),
    );
  }

  Widget getView({
    required int index,
    required List<int> list,
    required NewsfeedModel item,
  }) {
    print("=====");
    print(index);
    print(list);
    // print(list[1]);
    // print(list[2]);

    if (list[0] == index) {
      return groupView(item);
    } else if (list[1] == index) {
      return blogView(item);
    } else if (list[2] == index) {
      return friendView(item);
    } else if (list[3] == index) {
      return groupForum(item);
    } else {
      return feedCell(item);
    }
  }

  Column groupForum(NewsfeedModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                child: Text(
                  'Suggested forums for you:',
                  style: kTextTitleBlog.copyWith(color: kPrimaryColor),
                ),
              ),
              if (controller.suggestions.value.forums != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: controller.suggestions.value.forums!
                        .map(
                          (e) => infoSuggestionView(
                            e.title,
                            'Discusstion: ${e.typeData?.discussionCount}',
                            null,
                            null,
                            '${TimeManager.instance.convertFromTimeStamp(timestamp: e.typeData?.lastPostDate ?? 0)}',
                            'join',
                            () {
                              Get.to(() => ForumDetailScreen(), arguments: {
                                'item': e,
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
        feedCell(item)
      ],
    );
  }

  Column groupView(NewsfeedModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                child: Text(
                  'Suggested groups for you:',
                  style: kTextTitleBlog.copyWith(color: kPrimaryColor),
                ),
              ),
              if (controller.suggestions.value.groups != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: controller.suggestions.value.groups!
                        .map(
                          (e) => infoSuggestionView(
                            e.name,
                            '${e.privacy} - ${e.memberCount.toString()}',
                            e.avatarUrl,
                            e.ownerUsername,
                            e.category?.title,
                            'join',
                            () {
                              Get.put(GroupController());
                              Get.find<GroupController>().upDateGroup(item: e);
                              Get.to(
                                () => NewfeedGroupScreen(),
                                arguments: {'groupId': e.groupId},
                              );
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
        feedCell(item)
      ],
    );
  }

  Column blogView(NewsfeedModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                child: Text(
                  'Suggested blogs for you:',
                  style: kTextTitleBlog.copyWith(color: kPrimaryColor),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              if (controller.suggestions.value.blogs != null)
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: controller.suggestions.value.blogs!
                          .map(
                            (e) => infoSuggestionView(
                              e.title,
                              'Views: ${e.viewCount}',
                              e.user?.avatarUrls?.m,
                              e.user?.username,
                              '${TimeManager.instance.convertFromTimeStamp(timestamp: e.lastBlogEntryDate ?? 0)}',
                              'join',
                              () {
                                Get.to(
                                  () => MyBlogScreen(),
                                  arguments: {'blog': BlogEntryItem(blog: e)},
                                );
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
        feedCell(item)
      ],
    );
  }

  Column friendView(NewsfeedModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                child: Text(
                  'Suggested friends for you:',
                  style: kTextTitleBlog.copyWith(color: kPrimaryColor),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              if (controller.suggestions.value.users != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: controller.suggestions.value.users!
                        .map(
                          (e) => infoSuggestionView(
                            e.username,
                            'Reactions: ${e.reactionScore}\nMessage: ${e.messageCount}',
                            e.avatarUrls?.m,
                            e.username,
                            '${TimeManager.instance.convertFromTimeStamp(timestamp: e.registerDate ?? 0)}',
                            'Follow',
                            () async {
                              final useCase = IUserProfileUsecase();
                              final body = {
                                'reaction_id': 1,
                                'id': e.userId,
                              };
                              final json = await useCase.follow(body: body);
                              if (json != null) {
                                controller.fetchSuggestions();
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
        feedCell(item)
      ],
    );
  }

  Widget infoSuggestionView(
    String? title,
    String? content,
    String? avatarUrl,
    String? userName,
    String? subContent,
    String? titleAction,
    Function() onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: 16,
      ),
      child: Card(
        child: Container(
          padding: EdgeInsets.only(
            top: 8,
          ),
          height: titleAction != null ? 140 : 110,
          width: 300,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KaireteCacheNetworkImage(
                      url: avatarUrl ?? '',
                      width: 36,
                      height: 36,
                      isCircle: true,
                      nameImage: userName,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title ?? '',
                            style: kTextTitleBlog.copyWith(
                              color: kPrimaryColor,
                            ),
                            maxLines: 2,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            content ?? '',
                            style: kTextRegularStyle,
                            maxLines: 2,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            subContent ?? '',
                            style: kTextRegularStyle,
                            maxLines: 2,
                          ),
                          if (titleAction != null)
                            SizedBox(
                              height: 8,
                            ),
                          if (titleAction != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                KaireteActionButton(
                                  onTap: onTap,
                                  title: titleAction,
                                  width: 80,
                                  height: 30,
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Divider(),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector createView() {
    return GestureDetector(
      onTap: () {
        if (onCreate != null) {
          onCreate!();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          KaireteTextFieldButotn(
            onTap: () {
              controller.toCreate();
            },
          ),
          Obx(() => Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilterButton(
                      icon: 'ic_user',
                      onTap: () {
                        if (onTabFilter != null) {
                          onTabFilter!(0);
                        }
                      },
                      isActive: controller.selectedTabFilter.value == 0,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    FilterButton(
                      icon: 'ic_news',
                      onTap: () {
                        if (onTabFilter != null) {
                          onTabFilter!(1);
                        }
                      },
                      isActive: controller.selectedTabFilter.value == 1,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    FilterButton(
                      icon: 'ic_friends',
                      onTap: () {
                        if (onTabFilter != null) {
                          onTabFilter!(2);
                        }
                      },
                      isActive: controller.selectedTabFilter.value == 2,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    FilterButton(
                      icon: 'ic_home',
                      onTap: () {
                        if (onTabFilter != null) {
                          onTabFilter!(3);
                        }
                      },
                      isActive: controller.selectedTabFilter.value == 3,
                    ),
                    Expanded(child: Container()),
                    InkWell(
                      onTap: () {
                        controller.onSort();
                      },
                      child: const Icon(
                        Icons.sort_rounded,
                        color: kPrimaryColor,
                        size: 25,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    InkWell(
                      onTap: () {
                        if (onFilter != null) {
                          onFilter!();
                        }
                      },
                      child: const SvgIcon(
                        name: 'ic_filter',
                        color: kPrimaryColor,
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  NewfeedCell feedCell(NewsfeedModel item) {
    String? userName;
    String? blogTitle = item.itemCategory;
    switch (item.type) {
      case ContentTypeNewFeed.profilePost:
        userName = item.user?.username;
        break;
      case ContentTypeNewFeed.album:
        userName = item.user?.username;
        blogTitle = null;
        break;
      case ContentTypeNewFeed.blogEntry:
        userName = item.user?.username;
        blogTitle = item.blogEntryItem?.blog?.title;
        break;
      case ContentTypeNewFeed.thread:
        userName = item.user?.username;
        break;
      case ContentTypeNewFeed.tlGroupPost:
        userName = item.user?.username;
        break;
      default:
        userName = item.title;
        break;
    }

    return NewfeedCell(
      onTapDetail: () {
        if (onTapDetail != null) {
          onTapDetail!(item);
        }
      },
      onTapAvatar: () {
        controller.toProfile(user: item.user);
      },
      onTapGroupTitle: () {
        print(item.type);
        // if (item.type == ContentTypeNewFeed.blogEntry) {
        // controller.toMyBlogs(blog: item.blogEntryItem);
        // }

        switch (item.type) {
          case ContentTypeNewFeed.thread:
            final node = Nodes();
            node.nodeId = int.parse(item.itemCategory ?? '0');
            Get.to(() => ForumDetailScreen(), arguments: {'item': node});
            break;
          case ContentTypeNewFeed.blogEntry:
            controller.toMyBlogs(blog: item.blogEntryItem);
            break;
          case ContentTypeNewFeed.profilePost:
            final user = User();
            user.userId = int.parse(item.itemCategory ?? '0');
            controller.toProfile(user: user);
            break;
          case ContentTypeNewFeed.tlGroupPost:
            // Get.to(() => GroupFeedScreen(), arguments: {
            //   'groupId': item.groupId,
            //   'postId': item.postId,
            // });
            break;
          case ContentTypeNewFeed.article:
            final id = int.parse(item.itemCategory ?? '0');
            Get.to(() => AritclesCategoryScreen(), arguments: {
              'id': id,
            });
            break;
          default:
        }
      },
      // authorBlog: item.type == ContentTypeNewFeed.blogEntry
      //     ? item.blogEntryItem?.user?.username
      //     : null,
      onTapReply: () {
        controller.toReplies(item: item);
      },
      onTapReactions: () {
        controller.showReactionPopup(item: item);
      },
      avatar: item.user?.avatarUrls?.l,
      nameImage:
          (item.user?.customFields?.fullName ?? item.user?.username ?? ''),
      userName: userName,
      blogTitle: blogTitle,
      // groupTitle: 'item.groupPostItem?.group?.name',
      date: item.itemDate,
      commentCount: item.commentCount,
      shareCount: item.shareCount,
      reactionIconUrl: item.reactionIconUrl,
      isShowLike: item.user?.userId != UserManager.instance.userId,
      isShowDelete: item.user?.userId == UserManager.instance.userId,
      reactions: item.reactions,
      messagePlainText: item.messagePlainText,
      title: (item.title != '' &&
              item.groupPostItem == null &&
              item.type != ContentTypeNewFeed.tlGroupPost)
          ? item.title
          : null,
      thumbnailUrl: item.blogEntryItem?.attachments?[0].thumbnailUrl ??
          item.groupPostItem?.firstComment?.attachments?[0].thumbnailUrl,
      tags: item.blogEntryItem?.tags,
      onTapTag: (p0) {
        final tag = p0?.replaceAll('#', '');
        List<dynamic> list = item.blogEntryItem?.tagsKey.toList();
        final key = list.firstWhereOrNull((element) {
          Map<String, dynamic> data = element;
          return data['tag'].replaceAll(' ', '') == tag;
        });
        controller.toTagDetail(id: key?['tag_url']);
      },
      onTapReaction: () {
        controller.getReactionsList(item: item);
      },
      itemId: item.itemId,
      onDeleteSuccess: () {
        controller.fechItems();
      },
    );
  }
}

// ignore: must_be_immutable
class NewfeedCell extends StatelessWidget {
  NewfeedCell({
    Key? key,
    required this.onTapDetail,
    this.avatar,
    this.nameImage,
    this.userName,
    this.blogTitle,
    this.groupTitle,
    this.date,
    this.commentCount,
    this.shareCount,
    this.reactionIconUrl,
    this.isShowLike = true,
    this.onTapReply,
    this.onTapReactions,
    this.reactions,
    this.messagePlainText,
    this.title,
    this.thumbnailUrl,
    this.isShowShare = true,
    this.titleCate,
    this.authorBlog,
    this.onTapAvatar,
    this.isDetail = true,
    this.onTapHeader,
    this.isWatched,
    this.onTapWatch,
    this.isFollow,
    this.onTapFolow,
    this.isIgnore,
    this.onTapIgnore,
    this.tags,
    this.onTapTag,
    this.onTapReaction,
    this.category,
    this.isShowWatch = true,
    this.onTapTitle,
    this.onTapThumb,
    this.onTapDelete,
    this.isShowDelete = false,
    this.itemId,
    this.onDeleteSuccess,
    this.onEdit,
    this.newfeed,
    this.onTapGroupTitle,
  }) : super(key: key);

  final Function? onTapDetail;
  final String? avatar;
  final String? nameImage;
  final String? userName;
  final String? blogTitle;
  final String? category;
  final String? groupTitle;
  final int? date;
  final int? commentCount;
  final int? shareCount;
  final String? reactionIconUrl;
  final bool isShowLike;
  final List<Reactions>? reactions;
  final String? messagePlainText;
  final String? title;
  final String? thumbnailUrl;
  final bool isShowShare;
  final Function? onTapReply;
  final Function? onTapReactions;
  final String? titleCate;
  final String? authorBlog;
  final Function? onTapAvatar;
  final bool isDetail;
  final Function? onTapHeader;
  final bool? isWatched;
  final Function? onTapWatch;
  final bool? isFollow;
  final Function? onTapFolow;
  final bool? isIgnore;
  final Function? onTapIgnore;
  final bool isShowWatch;
  final String? tags;
  final bool isShowDelete;
  final int? itemId;
  final NewsfeedModel? newfeed;
  final Function(String?)? onTapTag;
  final Function()? onTapReaction;
  final Function()? onTapTitle;
  final Function()? onTapThumb;
  final Function()? onTapDelete;
  final Function()? onDeleteSuccess;
  final Function()? onEdit;
  final Function? onTapGroupTitle;

  Css? style = Get.find<DashboardController>().style;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: kBorderDefaultColor,
              ),
              color: Colors.grey.shade200,
            ),
            child: Row(
              children: [
                Expanded(
                  child: HeaderInfoCellWithAvatar(
                    onTapAvatar: onTapAvatar,
                    avatar: avatar,
                    nameImage: nameImage,
                    userName: userName,
                    blogTitle: blogTitle,
                    groupTitle: groupTitle,
                    authorBlog: authorBlog,
                    date: date,
                    titleCate: titleCate,
                    onTap: onTapHeader,
                    onTapGroupTitle: onTapGroupTitle,
                    // customAction: ActionsView(
                    //   isFollowed: isFollow,
                    //   isIgnored: isIgnore,
                    //   isWatched: isWatched,
                    //   onTapWatch: onTapWatch,
                    // ),
                  ),
                ),
                // ActionsView(
                //   isFollowed: isFollow,
                //   isIgnored: isIgnore,
                //   isWatched: isWatched,
                //   onTapWatch: onTapWatch,
                // ),
                if (isShowWatch)
                  Row(
                    children: [
                      ActionButton(
                        title: isFollow ?? false ? 'Unfollow' : 'Follow',
                        onTap: () {
                          if (onTapWatch != null) {
                            onTapWatch!();
                          }
                        },
                        icon: 'ic_ignore',
                        isActive: isWatched,
                      ),
                      if (isShowDelete)
                        SizedBox(
                          width: 4,
                        ),
                      if (isShowDelete)
                        InkWell(
                          onTap: () {
                            if (itemId != null) {
                              final useCase = INewsFeedUsecase();
                              showKairetePopup(
                                onTapDone: () async {
                                  final json =
                                      await useCase.delete(id: itemId!);
                                  if (json != null) {
                                    onDeleteSuccess!();
                                  }
                                },
                                title: 'Delete',
                                content:
                                    'Are you sure you want to delete this item?',
                                cancelTitle: 'cancel',
                              );
                            } else {
                              onTapDelete!();
                            }
                          },
                          child: Icon(
                            Icons.delete,
                            color: Colors.black,
                          ),
                        ),
                      if (isShowDelete)
                        InkWell(
                          onTap: () async {
                            if (newfeed != null) {
                              final result = await Get.to(
                                () => CreateNewsfeedScreen(),
                                fullscreenDialog: true,
                                arguments: {
                                  'item': newfeed,
                                },
                              );
                              if (result != null) {
                                onEdit!();
                              }
                            }
                          },
                          child: Icon(
                            Icons.edit,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 16,
                ),
                if (title != null)
                  InkWell(
                    onTap: onTapTitle,
                    child: Text(
                      title ?? '',
                      style: kTextMediumtStyle.copyWith(
                        color: style?.newsfeedItemHeaderInsideBody?.color
                                .toColor() ??
                            Colors.red,
                        fontSize: style?.newsfeedItemHeaderInsideBody?.fontSize
                                .parseDouble() ??
                            22,
                        fontWeight: style
                            ?.newsfeedItemHeaderInsideBody?.fontWeight
                            .getWegiht(),
                      ),
                    ),
                  ),
                if (title != null)
                  const SizedBox(
                    height: 8,
                  ),
                if (thumbnailUrl != null)
                  InkWell(
                    onTap: onTapThumb,
                    child: KaireteCacheNetworkImage(
                      url: thumbnailUrl!,
                    ),
                  ),
                if (thumbnailUrl != null)
                  const SizedBox(
                    height: 8,
                  ),
                isDetail
                    ? Text(
                        messagePlainText ?? '',
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: kTextMediumtStyle.copyWith(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      )
                    : HtmlWidget(
                        (messagePlainText)
                                ?.replaceAll("\\n", "")
                                .replaceAll("=\\  ", "=")
                                .replaceAll("g\\", "") ??
                            '',
                        textStyle: const TextStyle(fontSize: 17),
                      ),
                const SizedBox(
                  height: 8,
                ),
                if (tags != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: HashTagText(
                      text: tags ?? '',
                      decoratedStyle: TextStyle(
                        fontSize: 16,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      basicStyle: TextStyle(fontSize: 14, color: Colors.black),
                      onTap: (text) {
                        print(text);
                        if (onTapTag != null) {
                          onTapTag!(text);
                        }
                      },
                    ),
                  ),
                if (isDetail)
                  KaireteTextButton(
                    onTap: () {
                      if (onTapDetail != null) {
                        onTapDetail!();
                      }
                    },
                    title: 'See detail',
                  ),
                if (reactions != null)
                  InkWell(
                    onTap: onTapReaction,
                    child: ReactionsItemView(reactions: reactions ?? []),
                  )
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          ReationsItemView(
            commentCount: commentCount,
            onTapReply: onTapReply,
            isShowLike: isShowLike,
            onTapReactions: onTapReactions,
            reactionIconUrl: reactionIconUrl,
            isShowShare: isShowShare,
            shareCount: shareCount,
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}

class HeaderInfoCellWithAvatar extends StatelessWidget {
  const HeaderInfoCellWithAvatar({
    Key? key,
    required this.onTapAvatar,
    required this.avatar,
    required this.nameImage,
    required this.userName,
    required this.blogTitle,
    required this.groupTitle,
    required this.authorBlog,
    required this.date,
    required this.titleCate,
    this.onTap,
    this.customAction,
    this.category,
    this.onTapGroupTitle,
  }) : super(key: key);

  final Function? onTapAvatar;
  final String? avatar;
  final String? nameImage;
  final String? userName;
  final String? blogTitle;
  final String? groupTitle;
  final String? authorBlog;
  final int? date;
  final String? titleCate;
  final Function? onTap;
  final Widget? customAction;
  final String? category;
  final Function? onTapGroupTitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              if (onTapAvatar != null) {
                onTapAvatar!();
              }
            },
            child: KaireteCacheNetworkImage(
              url: avatar ?? '',
              width: 36,
              height: 36,
              isCircle: true,
              nameImage: nameImage,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: HeaderInfoCellItem(
              userName: userName,
              onTapAvatar: onTapAvatar,
              blogTitle: blogTitle,
              groupTitle: groupTitle,
              authorBlog: authorBlog,
              date: date,
              titleCate: titleCate,
              customAction: customAction,
              onTapGroupTitle: onTapGroupTitle,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class ReationsItemView extends StatelessWidget {
  ReationsItemView({
    Key? key,
    required this.commentCount,
    required this.onTapReply,
    required this.isShowLike,
    required this.onTapReactions,
    required this.reactionIconUrl,
    required this.isShowShare,
    required this.shareCount,
  }) : super(key: key);

  final int? commentCount;
  final Function? onTapReply;
  final bool isShowLike;
  final Function? onTapReactions;
  final String? reactionIconUrl;
  final bool isShowShare;
  final int? shareCount;

  Css? style = Get.find<DashboardController>().style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        border: Border.all(
          width: 0.5,
          color: Colors.grey.shade400,
        ),
        color: kF5F5F5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          KaireteIconButton(
            title: '$commentCount Replies',
            onTap: () {
              if (onTapReply != null) {
                onTapReply!();
              }
            },
          ),
          if (isShowLike)
            KaireteIconButton(
              title: 'Like',
              icon: 'ic_like',
              onTap: () {
                if (onTapReactions != null) {
                  onTapReactions!();
                }
              },
              url: reactionIconUrl,
            ),
          if (isShowShare && shareCount != null)
            KaireteIconButton(
              title: '$shareCount Share',
              icon: 'ic_share',
            ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class HeaderInfoCellItem extends StatelessWidget {
  HeaderInfoCellItem({
    Key? key,
    required this.userName,
    required this.onTapAvatar,
    required this.blogTitle,
    required this.groupTitle,
    required this.authorBlog,
    required this.date,
    required this.titleCate,
    this.customAction,
    this.category,
    this.onTapGroupTitle,
  }) : super(key: key);

  final String? userName;
  final Function? onTapAvatar;
  final String? blogTitle;
  final String? groupTitle;
  final String? authorBlog;
  final int? date;
  final String? titleCate;
  final Widget? customAction;
  final String? category;
  final Function? onTapGroupTitle;

  Css? style = Get.find<DashboardController>().style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: userName,
                  style: kTextRegularStyle.copyWith(
                    fontWeight: style?.newsfeedItemHeaderUsername?.fontWeight
                            ?.getWegiht() ??
                        FontWeight.w600,
                    fontSize: style?.newsfeedItemHeaderUsername?.fontSize
                            ?.parseDouble() ??
                        16,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (onTapAvatar != null) {
                        onTapAvatar!();
                      }
                    },
                  children: [
                    if ((blogTitle != null && blogTitle != "") ||
                        (groupTitle != null && groupTitle != ""))
                      const WidgetSpan(
                          child: Icon(
                        Icons.play_arrow,
                        color: kPrimaryColor,
                        size: 16,
                      )),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (onTapGroupTitle != null) {
                            onTapGroupTitle!();
                          }
                        },
                      text: category ?? blogTitle ?? groupTitle ?? '',
                      style: kTextRegularStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            style?.newsfeedItemHeaderTitle?.color?.toColor() ??
                                kPrimaryColor,
                        fontSize: style?.newsfeedItemHeaderTitle?.fontSize
                                .parseDouble() ??
                            16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 4,
            ),
            if (customAction != null) customAction!
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        RichText(
          text: TextSpan(
            text: '',
            style: kTextMediumtStyle.copyWith(
                color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w600),
            children: <TextSpan>[
              if (authorBlog != null)
                TextSpan(
                    text: authorBlog,
                    style: kTextMediumtStyle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    )),
              if (authorBlog != null) TextSpan(text: ' - '),
              TextSpan(
                  text: TimeManager.instance
                      .convertFromTimeStamp(timestamp: date ?? 0),
                  style: kTextMediumtStyle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  )),
              if (titleCate != null) TextSpan(text: ' - '),
              if (titleCate != null)
                TextSpan(
                    text: titleCate,
                    style: kTextMediumtStyle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kPrimaryColor,
                    )),
            ],
          ),
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class FilterButton extends StatelessWidget {
  FilterButton({
    Key? key,
    this.icon,
    this.onTap,
    this.isActive = false,
  }) : super(key: key);

  final String? icon;
  final Function? onTap;
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: kBorderDefaultColor,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isActive ? kPrimaryColor : Colors.white,
        ),
        child: SvgIcon(
          name: icon ?? 'ic_home',
          width: 25,
          height: 25,
          color: isActive ? Colors.white : kPrimaryColor,
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class KaireteIconButton extends StatelessWidget {
  KaireteIconButton({
    Key? key,
    this.title,
    this.icon,
    this.width,
    this.height,
    this.onTap,
    this.color,
    this.url,
    this.textColor,
  }) : super(key: key);

  final String? title;
  final String? icon;
  final double? width;
  final double? height;
  final Function? onTap;
  final Color? color;
  final Color? textColor;
  final String? url;

  Css? style = Get.find<DashboardController>().style;

  @override
  Widget build(BuildContext context) {
    print(url);
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: style?.newsfeedItemFooterButton?.background.toColor() ??
                color ??
                kPrimaryColor,
            border: Border.all(color: color ?? kBorderDefaultColor, width: 1)),
        child: Row(
          children: [
            url != null
                ? KaireteCacheNetworkImage(
                    url: url!,
                    width: 20,
                    height: 20,
                  )
                : SvgIcon(
                    name: icon ?? 'ic_reply',
                    width: width ?? 21,
                    height: height ?? 16,
                    color: style?.newsfeedItemFooterButton?.color.toColor() ??
                        textColor ??
                        Colors.white,
                  ),
            const SizedBox(
              width: 4,
            ),
            Text(
              title ?? '0 replies',
              style: kTextRegularStyle.copyWith(
                fontSize:
                    style?.newsfeedItemFooterButton?.fontSize.parseDouble(),
                fontWeight:
                    style?.newsfeedItemFooterButton?.fontWeight.getWegiht() ??
                        FontWeight.w700,
                color: style?.newsfeedItemFooterButton?.color.toColor() ??
                    textColor ??
                    Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
