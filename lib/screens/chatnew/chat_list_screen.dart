import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/background_component.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/screens/chatnew/component/user_item_widget.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.lblchat,
        textColor: white,
        showBack: Navigator.canPop(context),
        elevation: 3.0,
        backWidget: BackWidget(),
        color: context.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          return await 2.seconds.delay;
        },
        child: PaginateFirestore(
          itemBuilder: (context, snap, index) {
            UserData contact = UserData.fromJson(snap[index].data() as Map<String, dynamic>);
            return UserItemWidget(userUid: contact.uid.validate());
          },
          physics: AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 10),
          options: GetOptions(source: Source.serverAndCache),
          isLive: true,
          padding: EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 0),
          itemsPerPage: PER_PAGE_CHAT_LIST_COUNT,
          separator: Divider(height: 0, indent: 82),
          shrinkWrap: true,
          // query: chatServices.fetchChatList(),
          query: chatMessageService.fetchChatListQuery(userId: appStore.uid.validate()),
          onEmpty: BackgroundComponent(text: language.lblNoChatFound),
          initialLoader: LoaderWidget(),
          itemBuilderType: PaginateBuilderType.listView,
          onError: (e) => BackgroundComponent(text: language.lblNoChatFound),
        ),
      ),
    );
  }
}
