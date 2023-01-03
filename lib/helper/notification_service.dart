import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'notice_navigator.dart';

class NotificationManager {
  NotificationManager._privateConstructor();

  static final NotificationManager _instance =
      NotificationManager._privateConstructor();

  static NotificationManager get instance => _instance;

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FCMNavigator navigator = IFCMNavigator();

  void init() {
    AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              ledColor: Colors.white)
        ],
        channelGroups: [
          NotificationChannelGroup(
              channelGroupkey: 'basic_channel_group',
              channelGroupName: 'Basic group')
        ],
        debug: true);
  }

  disableNotice() async {
    FirebaseMessaging.instance.setAutoInitEnabled(false);
    await FirebaseMessaging.instance.deleteToken();
  }

  void enableNotice() async {
    FirebaseMessaging.instance.setAutoInitEnabled(true);
  }

  Future<dynamic> onActionSelected(ActionNoticeType value) async {
    print(value);
    switch (value) {
      case ActionNoticeType.SUBSCRIBE:
        {
          print('FlutterFire Messaging: Subscribing to topic "fcm_test".');
          await FirebaseMessaging.instance.subscribeToTopic('fcm_test');
          print(
              'FlutterFire Messaging: Subscribing to topic "fcm_test" successful.');
        }
        break;
      case ActionNoticeType.UNSUBCRIBE:
        {
          print('FlutterFire Messaging: Unsubscribing from topic "fcm_test".');
          await FirebaseMessaging.instance.unsubscribeFromTopic('fcm_test');
          print(
              'FlutterFire Messaging: Unsubscribing from topic "fcm_test" successful.');
        }
        break;
      case ActionNoticeType.APNS:
        {
          if (defaultTargetPlatform == TargetPlatform.iOS) {
            print('FlutterFire Messaging: Getting APNs token...');
            String? token = await FirebaseMessaging.instance.getAPNSToken();
            print('FlutterFire Messaging: Got APNs token: $token');
            return token;
          } else {
            print(
                'FlutterFire Messaging: Getting an APNs token is only supported on iOS and macOS platforms.');
          }
        }
        break;
      default:
        print('FlutterFire Messaging: Getting FCM token...');
        String? token = await FirebaseMessaging.instance.getToken();
        print('FlutterFire Messaging: Got FCM token: $token');
        if (token != null) {
          updateFCM(token);
        }
        handlerMessage();
        return token;
    }
  }

  requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('authorized');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  updateFCM(String fcmToken) async {
    // FCMUsecase usecase = IFCMUsecase();
    // final body = {
    //   'device_token': fcmToken,
    // };
    // final json = await usecase.pushToken(body);
    // if (json != null) {
    //   print('Push FCM success');
    // }
  }

  handlerMessage() async {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('subscriber message');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      if (notification != null && Platform.isAndroid) {
        print("Received notification title: ${notification.title}");
        print("Received notification body: ${notification.body}");
        await AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: createUniqueId(),
                channelKey: 'basic_channel',
                title: notification.title,
                body: notification.body));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleFCMMessage(message);
    });

    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleFCMMessage(initialMessage);
    }
  }

  handleFCMMessage(RemoteMessage remoteMessage) {
    navigator.nextStep(data: remoteMessage.data);
  }

  Future<void> creteNoticeLocal() async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 1, channelKey: 'basic_channel', title: 'Demo', body: 'aaaa'));
  }

  int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }
}

enum ActionNoticeType {
  SUBSCRIBE,
  UNSUBCRIBE,
  APNS,
  FCM,
}
