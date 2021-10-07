import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/screens/flats/favorites.screen.dart';
import 'package:event_flats/view/screens/flats/list.screen.dart';
import 'package:event_flats/view/screens/flats/personal.screen.dart';
import 'package:flutter/material.dart';

import 'add.screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(this._flatsRepository, this._authenticationService,
      {Key? key})
      : super(key: key);

  static const String route = '/home';
  final FlatsRepository _flatsRepository;
  final AuthenticationService _authenticationService;

  @override
  _HomeScreenState createState() =>
      _HomeScreenState(_flatsRepository, _authenticationService);
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentScreenIndex = 0;
  late List<Widget> _screens;

  _HomeScreenState(FlatsRepository _flatsRepository,
      AuthenticationService _authenticationService) {
    _screens = [
      FlatsListScreen(_flatsRepository, _authenticationService),
      FlatsPersonalListScreen(),
      FlatsFavoritesListScreen(_flatsRepository, _authenticationService)
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _currentScreenIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryColor,
              onPressed: () {
                Navigator.of(context).pushNamed(AddFlatScreen.route);
              },
              label: Text(
                'Добавить',
                style: TextStyle(color: Colors.black),
              ),
              icon: Icon(
                Icons.add,
                color: Colors.black,
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentScreenIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Общий список'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Персональные'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Избранные')
        ],
      ),
      body: _screens[_currentScreenIndex],
    );
  }
}
