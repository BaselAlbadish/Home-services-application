import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/background_component.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/chat_message_model.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/screens/chatnew/component/chat_item_widget.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class UserChatScreens extends StatefulWidget {
  final UserData receiverUser;

  UserChatScreens({required this.receiverUser});

  @override
  _UserChatScreensState createState() => _UserChatScreensState();
}

class _UserChatScreensState extends State<UserChatScreens> with WidgetsBindingObserver {
  TextEditingController messageCont = TextEditingController();

  FocusNode messageFocus = FocusNode();

  UserData senderUser = UserData();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    WidgetsBinding.instance.addObserver(this);
    OneSignal.shared.disablePush(true);
    if (widget.receiverUser.uid.validate().isEmpty) {
      await userService.getUser(email: widget.receiverUser.email.validate()).then((value) {
        widget.receiverUser.uid = value.uid;
      }).catchError((e) {
        log(e.toString());
      });
    }
    senderUser = await userService.getUser(email: appStore.userEmail.validate());
    setState(() {});

    await chatMessageService.setUnReadStatusToTrue(senderId: appStore.uid.validate(), receiverId: widget.receiverUser.uid.validate()).catchError((e) {
      toast(e.toString());
    });
  }

  //region Widget
  Widget _buildChatFieldWidget() {
    return Row(
      children: [
        AppTextField(
          textFieldType: TextFieldType.OTHER,
          controller: messageCont,
          textStyle: primaryTextStyle(),
          minLines: 1,
          onFieldSubmitted: (s) {
            sendMessages();
          },
          focus: messageFocus,
          cursorHeight: 20,
          maxLines: 5,
          cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          decoration: inputDecoration(context).copyWith(
            hintText: 'Message',
            hintStyle: secondaryTextStyle(),
          ),
        ).expand(),
        8.width,
        Container(
          decoration: boxDecorationDefault(borderRadius: radius(80), color: primaryColor),
          child: IconButton(
            icon: Icon(Icons.send, color: Colors.white),
            onPressed: () {
              sendMessages();
            },
          ),
        )
      ],
    );
  }

  //endregion

  //region Methods
  Future<void> sendMessages() async {
    // If Message TextField is Empty.
    if (messageCont.text.trim().isEmpty) {
      messageFocus.requestFocus();
      return;
    }

    // Making Request for sending data to firebase
    ChatMessageModel data = ChatMessageModel();

    data.receiverId = widget.receiverUser.uid;
    data.senderId = appStore.uid;
    data.message = messageCont.text;
    data.isMessageRead = false;
    data.createdAt = DateTime.now().millisecondsSinceEpoch;
    data.messageType = MessageType.TEXT.name;

    messageCont.clear();

    await chatMessageService.addMessage(data).then((value) async {
      log("--Message Successfully Added--");

      /* /// Send Notification
      NotificationService().sendPushNotifications(loginStore.userFullName, data.message.validate(), uid: senderUser.uid.validate(), email: senderUser.email.validate(), receiverPlayerId: widget.receiverUser.player_id.validate()).catchError((e) {
        log("Notification Error ${e.toString()}");
      });*/

      await chatMessageService.addMessageToDb(senderRef: value, chatData: data, sender: senderUser, receiverUser: widget.receiverUser).then((value) {
        //
      }).catchError((e) {
        log(e.toString());
      });

      /// Save receiverId to Sender Doc.
      userService.saveToContacts(senderId: appStore.uid, receiverId: widget.receiverUser.uid.validate()).then((value) => log("---ReceiverId to Sender Doc.---")).catchError((e) {
        log(e.toString());
      });

      /// Save senderId to Receiver Doc.
      userService.saveToContacts(senderId: widget.receiverUser.uid.validate(), receiverId: appStore.uid).then((value) => log("---SenderId to Receiver Doc.---")).catchError((e) {
        log(e.toString());
      });

      // chatMessageService.setUnreadCount(senderId: appStore.uid, receiverId: widget.receiverUser.uid.validate(), status: 0);
    }).catchError((e) {
      log(e.toString());
    });
  }

  //endregion

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached) {
      OneSignal.shared.disablePush(false);
    }

    if (state == AppLifecycleState.paused) {
      OneSignal.shared.disablePush(false);
    }
    if (state == AppLifecycleState.resumed) {
      OneSignal.shared.disablePush(true);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    OneSignal.shared.disablePush(false);
    WidgetsBinding.instance.removeObserver(this);

    setStatusBarColor(transparentColor, statusBarBrightness: Brightness.dark, statusBarIconBrightness: Brightness.dark);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "",
        backWidget: BackWidget(iconColor: white),
        color: context.primaryColor,
        systemUiOverlayStyle: SystemUiOverlayStyle(statusBarColor: context.primaryColor, statusBarBrightness: Brightness.dark, statusBarIconBrightness: Brightness.light),
        titleWidget: Text(widget.receiverUser.firstName.validate(), style: TextStyle(color: white)),
        actions: [
          PopupMenuButton(
            onSelected: (index) {
              if (index == 0) {
                showConfirmDialogCustom(
                  context,
                  onAccept: (c) async {
                    appStore.setLoading(true);
                    await chatMessageService.clearAllMessages(senderId: senderUser.uid, receiverId: widget.receiverUser.uid.validate()).then((value) {
                      toast('Chat Cleared');
                      hideKeyboard(context);
                    }).catchError((e) {
                      toast(e);
                    });
                    appStore.setLoading(false);
                  },
                );
              }
            },
            itemBuilder: (context) {
              List<PopupMenuItem> list = [];
              list.add(
                PopupMenuItem(
                  value: 0,
                  child: Text('Clear Chat', style: primaryTextStyle()),
                ),
              );
              return list;
            },
          )
        ],
      ),
      body: SizedBox(
        height: context.height(),
        width: context.width(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset(chat_default_wallpaper).image,
                  fit: BoxFit.cover,
                  colorFilter: appStore.isDarkMode ? ColorFilter.mode(Colors.black54, BlendMode.luminosity) : ColorFilter.mode(primaryColor, BlendMode.overlay),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 80),
              child: PaginateFirestore(
                reverse: true,
                isLive: true,
                padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                physics: BouncingScrollPhysics(),
                query: chatMessageService.chatMessagesWithPagination(senderId: appStore.uid, receiverUserId: widget.receiverUser.uid.validate()),
                initialLoader: LoaderWidget(),
                itemsPerPage: PER_PAGE_CHAT_COUNT,
                onEmpty: BackgroundComponent(text: language.lblNoChatFound),
                shrinkWrap: true,
                onError: (e) => BackgroundComponent(text: language.lblNoChatFound),
                itemBuilderType: PaginateBuilderType.listView,
                itemBuilder: (context, snap, index) {
                  ChatMessageModel data = ChatMessageModel.fromJson(snap[index].data() as Map<String, dynamic>);
                  data.isMe = data.senderId == appStore.uid;
                  return ChatItemWidget(chatItemData: data);
                },
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildChatFieldWidget(),
            )
          ],
        ),
      ),
    );
  }
}
