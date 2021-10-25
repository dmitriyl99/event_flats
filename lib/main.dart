import 'package:event_flats/models/repositories/api_flats_repository.dart';
import 'package:event_flats/models/repositories/users_repository.dart';
import 'package:event_flats/models/user.dart';
import 'package:event_flats/services/api_authentication.dart';
import 'package:event_flats/view/screens/admin/user_show.screen.dart';
import 'package:event_flats/view/screens/admin/users_list.screen.dart';
import 'package:event_flats/view/screens/flats/add.screen.dart';
import 'package:event_flats/view/screens/flats/edit.screen.dart';
import 'package:event_flats/view/screens/flats/filter.screen.dart';
import 'package:event_flats/view/screens/flats/home.screen.dart';
import 'package:event_flats/view/screens/flats/show.screen.dart';
import 'package:event_flats/view/screens/login.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  await ApiAuthenticationService.init();
  var authenticationService = ApiAuthenticationService();
  var currentUser = authenticationService.getUser();
  String initialRoute = LoginScreen.route;
  if (currentUser != null) {
    initialRoute = HomeScreen.route;
  }
  await FirebaseAuth.instance.signInAnonymously();
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
    ApiAuthenticationService authenticationService = ApiAuthenticationService();
    ApiFlatsRepository flatsRepository =
        ApiFlatsRepository(authenticationService);
    UsersRepository usersRepository =
        new UsersRepository(authenticationService);
    return MaterialApp(
      title: 'Luper Flats',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      routes: {
        LoginScreen.route: (context) => new LoginScreen(authenticationService),
        HomeScreen.route: (context) =>
            new HomeScreen(flatsRepository, authenticationService),
        FlatShowScreen.route: (context) =>
            new FlatShowScreen(authenticationService, flatsRepository),
        AddFlatScreen.route: (context) => new AddFlatScreen(flatsRepository),
        EditFlatScreen.route: (context) => new EditFlatScreen(flatsRepository),
        FilterScreen.route: (context) => new FilterScreen(),
        UsersListScreen.route: (context) =>
            new UsersListScreen(usersRepository),
        UserShowScreen.route: (context) =>
            new UserShowScreen(usersRepository, flatsRepository)
      },
      initialRoute: initialRoute,
    );
  }
}
