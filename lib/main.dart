import 'package:engnotes/notifier/note_notifier.dart';
import 'package:engnotes/screens/home.dart';
import 'package:engnotes/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notifier/auth_notifier.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (context) => AuthNotifier(),
        ),
        ChangeNotifierProvider(
          builder: (context) => NoteNotifier(),
        ),
      ],
      child: MyApp(),
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Engineering Notes',
        theme: ThemeData.dark(),
        home: SplashScreen(
          'assets/splashscreen.flr',
          Consumer<AuthNotifier>(
            builder: (context, notifier, child) {
              return notifier.user != null ? Home() : Login();
            },
          ),
          startAnimation: 'intro',
          backgroundColor: Colors.black,
        ));
  }
}
