import 'newsfeed.dart';
import 'newsfeed_block_filter_bar.dart';
import 'newsfeed_item_footer_button.dart';
import 'newsfeed_item_header.dart';
import 'newsfeed_item_header_inside_body.dart';
import 'newsfeed_item_header_tags.dart';
import 'newsfeed_item_header_tags_hover.dart';
import 'newsfeed_item_header_title.dart';
import 'newsfeed_item_header_username.dart';
import 'newsfeed_item_message.dart';
import 'newsfeed_item_reactions_bar.dart';
import 'newsfeed_tab.dart';
import 'newsfeed_tab_selected.dart';

class Css {
  Newsfeed? newsfeed;
  NewsfeedBlockFilterBar? newsfeedBlockFilterBar;
  NewsfeedItemFooterButton? newsfeedItemFooterButton;
  NewsfeedItemHeader? newsfeedItemHeader;
  NewsfeedItemHeaderInsideBody? newsfeedItemHeaderInsideBody;
  NewsfeedItemHeaderTags? newsfeedItemHeaderTags;
  NewsfeedItemHeaderTagsHover? newsfeedItemHeaderTagsHover;
  NewsfeedItemHeaderTitle? newsfeedItemHeaderTitle;
  NewsfeedItemHeaderUsername? newsfeedItemHeaderUsername;
  NewsfeedItemMessage? newsfeedItemMessage;
  NewsfeedItemReactionsBar? newsfeedItemReactionsBar;
  NewsfeedTab? newsfeedTab;
  NewsfeedTabSelected? newsfeedTabSelected;

  Css({
    this.newsfeed,
    this.newsfeedBlockFilterBar,
    this.newsfeedItemFooterButton,
    this.newsfeedItemHeader,
    this.newsfeedItemHeaderInsideBody,
    this.newsfeedItemHeaderTags,
    this.newsfeedItemHeaderTagsHover,
    this.newsfeedItemHeaderTitle,
    this.newsfeedItemHeaderUsername,
    this.newsfeedItemMessage,
    this.newsfeedItemReactionsBar,
    this.newsfeedTab,
    this.newsfeedTabSelected,
  });

  factory Css.fromJson(Map<String, dynamic> json) => Css(
        newsfeed: json['newsfeed'] == null
            ? null
            : Newsfeed.fromJson(json['newsfeed'] as Map<String, dynamic>),
        newsfeedBlockFilterBar: json['newsfeedBlockFilterBar'] == null
            ? null
            : NewsfeedBlockFilterBar.fromJson(
                json['newsfeedBlockFilterBar'] as Map<String, dynamic>),
        newsfeedItemFooterButton: json['newsfeedItemFooterButton'] == null
            ? null
            : NewsfeedItemFooterButton.fromJson(
                json['newsfeedItemFooterButton'] as Map<String, dynamic>),
        newsfeedItemHeader: json['newsfeedItemHeader'] == null
            ? null
            : NewsfeedItemHeader.fromJson(
                json['newsfeedItemHeader'] as Map<String, dynamic>),
        newsfeedItemHeaderInsideBody: json['newsfeedItemHeaderInsideBody'] ==
                null
            ? null
            : NewsfeedItemHeaderInsideBody.fromJson(
                json['newsfeedItemHeaderInsideBody'] as Map<String, dynamic>),
        newsfeedItemHeaderTags: json['newsfeedItemHeaderTags'] == null
            ? null
            : NewsfeedItemHeaderTags.fromJson(
                json['newsfeedItemHeaderTags'] as Map<String, dynamic>),
        newsfeedItemHeaderTagsHover: json['newsfeedItemHeaderTagsHover'] == null
            ? null
            : NewsfeedItemHeaderTagsHover.fromJson(
                json['newsfeedItemHeaderTagsHover'] as Map<String, dynamic>),
        newsfeedItemHeaderTitle: json['newsfeedItemHeaderTitle'] == null
            ? null
            : NewsfeedItemHeaderTitle.fromJson(
                json['newsfeedItemHeaderTitle'] as Map<String, dynamic>),
        newsfeedItemHeaderUsername: json['newsfeedItemHeaderUsername'] == null
            ? null
            : NewsfeedItemHeaderUsername.fromJson(
                json['newsfeedItemHeaderUsername'] as Map<String, dynamic>),
        newsfeedItemMessage: json['newsfeedItemMessage'] == null
            ? null
            : NewsfeedItemMessage.fromJson(
                json['newsfeedItemMessage'] as Map<String, dynamic>),
        newsfeedItemReactionsBar: json['newsfeedItemReactionsBar'] == null
            ? null
            : NewsfeedItemReactionsBar.fromJson(
                json['newsfeedItemReactionsBar'] as Map<String, dynamic>),
        newsfeedTab: json['newsfeedTab'] == null
            ? null
            : NewsfeedTab.fromJson(json['newsfeedTab'] as Map<String, dynamic>),
        newsfeedTabSelected: json['newsfeedTabSelected'] == null
            ? null
            : NewsfeedTabSelected.fromJson(
                json['newsfeedTabSelected'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'newsfeed': newsfeed?.toJson(),
        'newsfeedBlockFilterBar': newsfeedBlockFilterBar?.toJson(),
        'newsfeedItemFooterButton': newsfeedItemFooterButton?.toJson(),
        'newsfeedItemHeader': newsfeedItemHeader?.toJson(),
        'newsfeedItemHeaderInsideBody': newsfeedItemHeaderInsideBody?.toJson(),
        'newsfeedItemHeaderTags': newsfeedItemHeaderTags?.toJson(),
        'newsfeedItemHeaderTagsHover': newsfeedItemHeaderTagsHover?.toJson(),
        'newsfeedItemHeaderTitle': newsfeedItemHeaderTitle?.toJson(),
        'newsfeedItemHeaderUsername': newsfeedItemHeaderUsername?.toJson(),
        'newsfeedItemMessage': newsfeedItemMessage?.toJson(),
        'newsfeedItemReactionsBar': newsfeedItemReactionsBar?.toJson(),
        'newsfeedTab': newsfeedTab?.toJson(),
        'newsfeedTabSelected': newsfeedTabSelected?.toJson(),
      };
}
