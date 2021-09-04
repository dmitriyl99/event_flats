import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/screens/flats/list.screen.dart';
import 'package:event_flats/view/screens/login.screen.dart';
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
        primarySwatch: AppColors.primaryColor,
      ),
      routes: {
        LoginScreen.route: (context) => new LoginScreen(),
        FlatsListScreen.route: (context) => new FlatsListScreen()
      },
      initialRoute: LoginScreen.route,
    );
  }
}
