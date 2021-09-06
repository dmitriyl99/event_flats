import 'package:event_flats/models/user.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/screens/flats/list.screen.dart';
import 'package:event_flats/view/screens/login.screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());

  var authenticationService = FirebaseAuthenticationService();
  var currentUser = await authenticationService.getUser();
  String initialRoute = LoginScreen.route;
  if (currentUser != null) {
    initialRoute = FlatsListScreen.route;
  }
  runApp(MyApp(
    initialRoute: initialRoute,
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, this.initialRoute = LoginScreen.route})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Flats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.primaryColor,
      ),
      routes: {
        LoginScreen.route: (context) =>
            new LoginScreen(FirebaseAuthenticationService()),
        FlatsListScreen.route: (context) => new FlatsListScreen()
      },
      initialRoute: initialRoute,
    );
  }
}
