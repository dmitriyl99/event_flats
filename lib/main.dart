import 'package:event_flats/screens/login.screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Flats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {LoginScreen.route: (context) => new LoginScreen()},
      initialRoute: LoginScreen.route,
    );
  }
}
