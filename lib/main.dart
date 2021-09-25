import 'package:event_flats/models/repositories/firebase_flats_repository.dart';
import 'package:event_flats/models/user.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/view/screens/flats/add.screen.dart';
import 'package:event_flats/view/screens/flats/edit.screen.dart';
import 'package:event_flats/view/screens/flats/filter.screen.dart';
import 'package:event_flats/view/screens/flats/list.screen.dart';
import 'package:event_flats/view/screens/flats/show.screen.dart';
import 'package:event_flats/view/screens/login.screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());

  await initializeDateFormatting('ru');

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
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      routes: {
        LoginScreen.route: (context) =>
            new LoginScreen(FirebaseAuthenticationService()),
        FlatsListScreen.route: (context) => new FlatsListScreen(
            FireabaseFlatsRepository(), FirebaseAuthenticationService()),
        FlatShowScreen.route: (context) => new FlatShowScreen(
            FirebaseAuthenticationService(), FireabaseFlatsRepository()),
        AddFlatScreen.route: (context) =>
            new AddFlatScreen(FireabaseFlatsRepository()),
        EditFlatScreen.route: (context) =>
            new EditFlatScreen(FireabaseFlatsRepository()),
        FilterScreen.route: (context) => new FilterScreen()
      },
      initialRoute: initialRoute,
    );
  }
}
