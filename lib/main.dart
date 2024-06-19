import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'model/room_manager.dart';
import 'page/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAgpIje1vP5gssyAcCWKg1akSeGKi4c56Y",
          appId: "1:242745106738:android:584afc1b31fb66a561372b",
          messagingSenderId: "242745106738",
          projectId: "tic-tac-toe-d6619"));
  await RoomManager.getInstance().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Home());
  }
}
