import 'package:chatonline_app/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    OneSignal.shared.init('7a5bcb46-9de7-4e74-897e-6e0a9db4e723');
    //OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.none);
    //OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) { });
    return MaterialApp(
      title: 'Chat Flutter',
      theme: ThemeData(
          primarySwatch: Colors.red,
          iconTheme: IconThemeData(
            color: Colors.blue,
          )),
      home: ChatScreen(),
    );
  }
}
