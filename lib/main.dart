import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:finedger/providers/page_provider.dart';
import 'package:finedger/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/account_provider.dart';



// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();

void main() async {
  // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   await Firebase.initializeApp();
  //   print("Handling a background message: ${message.messageId}");
  // }

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCHGCTEKylw4daavrNDtAgc-4A5TTUab_I",
      appId: "1:217026675332:android:cb225046e2de97368278d1",
      messagingSenderId: "217026675332",
      projectId: "finedger-fed20",
    ),
  );
  //
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  //
  // String? token = await messaging.getToken();
  // print("FCM Token: $token");
  //
  // if (token != null) {
  //   // Save this token in Firestore for the current user
  //   String userId = FirebaseAuth.instance.currentUser!.uid;
  //   FirebaseFirestore.instance.collection('users').doc(userId).update({
  //     'fcmToken': token,
  //   });
  // }
  // FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  //   String userId = FirebaseAuth.instance.currentUser!.uid;
  //   FirebaseFirestore.instance.collection('users').doc(userId).update({
  //     'fcmToken': newToken,
  //   });
  // });
  //
  //
  //
  // // Request permission to receive notifications
  // await messaging.requestPermission(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  //
  // // FlutterLocalNotifications Setup (already provided in the previous step)
  // const AndroidInitializationSettings initializationSettingsAndroid =
  // AndroidInitializationSettings('@mipmap/ic_launcher');
  //
  // const InitializationSettings initializationSettings = InitializationSettings(
  //   android: initializationSettingsAndroid,
  // );
  //
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  //
  // // Create Notification Channel for Android 8.0+
  // const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //   'finedger_default_channel', // id
  //   'FinEdger Notifications', // name
  //   description: 'This channel is used for FinEdger app notifications.', // description
  //   importance: Importance.high,
  // );
  //
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //     AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
  //
  // // Set up listeners for receiving messages when the app is in the foreground
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   RemoteNotification? notification = message.notification;
  //   AndroidNotification? android = message.notification?.android;
  //
  //   if (notification != null && android != null) {
  //     flutterLocalNotificationsPlugin.show(
  //       notification.hashCode,
  //       notification.title,
  //       notification.body,
  //       NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           channel.id,
  //           channel.name,
  //           channelDescription: channel.description,
  //           icon: '@mipmap/ic_launcher',
  //         ),
  //       ),
  //     );
  //   }
  // });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AccountProvider()),
        ChangeNotifierProvider(create: (context) => PageProvider()),
      ],
      child: const FinEdger(),
    ),
  );
}

class FinEdger extends StatelessWidget {
  const FinEdger({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Wrapper()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('images/splash.png'), // Your splash screen image.
      ),
    );
  }
}
