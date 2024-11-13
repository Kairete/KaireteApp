import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kairete/constants/color.dart';

import '../features/profile/usecase/user_profile_usecase.dart';
import 'notice_navigator.dart';
import 'package:http/http.dart' as http;

class NotificationManager {
  NotificationManager._privateConstructor();

  static final NotificationManager _instance =
      NotificationManager._privateConstructor();

  static NotificationManager get instance => _instance;
  String? currentFCMToken;

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FCMNavigator navigator = IFCMNavigator();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'your channel id 2',
    'your channel name 2',
    description: 'your channel description 2',
  );

  void init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
    FCMUsecase usecase = IFCMUsecase();
    NotificationManager.instance.currentFCMToken = fcmToken;
    final body = {
      'token': fcmToken,
    };
    final json = await usecase.pushFCM(body: body);
    if (json != null) {
      print('Push FCM success');
    }
  }

  deleteFCM() async {
    FCMUsecase usecase = IFCMUsecase();
    final body = {
      'token': NotificationManager.instance.currentFCMToken,
    };
    final json = await usecase.removeFCM(body: body);
    if (json != null) {
      print('Push FCM success');
    }
  }

  Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  handlerMessage() async {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('subscriber message');
      }
    });
    final ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(
        await _getByteArrayFromUrl('https://dummyimage.com/400x800'));

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      print("====== ${message.data}");
      if (notification != null) {
        print(notification.body);
        print(notification.title);

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                iOS: const DarwinNotificationDetails(
                    presentAlert: true,
                    presentSound: true,
                    subtitle: '12312312'),
                android: AndroidNotificationDetails(channel.id, channel.name,
                    channelDescription: channel.description,
                    color: kPrimaryColor
                    // icon: android?.smallIcon,
                    )));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleFCMMessage(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleFCMMessage(initialMessage);
    }
  }

  handleFCMMessage(RemoteMessage remoteMessage) {
    navigator.nextStep(data: remoteMessage.data);
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("onBackgroundMessage: $message");
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
