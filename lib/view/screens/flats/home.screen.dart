import 'package:event_flats/models/repositories/api_flats_repository.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/services/api_authentication.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/screens/flats/favorites.screen.dart';
import 'package:event_flats/view/screens/flats/list.screen.dart';
import 'package:event_flats/view/screens/flats/personal.screen.dart';
import 'package:event_flats/view/viewmodels/filter.viewmodel.dart';
import 'package:flutter/material.dart';

import 'add.screen.dart';
import 'filter.screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(this._flatsRepository, {Key? key}) : super(key: key);

  static const String route = '/home';
  final FlatsRepository _flatsRepository;

  @override
  _HomeScreenState createState() => _HomeScreenState(_flatsRepository);
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentScreenIndex = 0;
  late List<Widget> _screens;
  FilterViewModel? _filter;

  _HomeScreenState(FlatsRepository _flatsRepository) {
    _screens = [
      FlatsListScreen(_flatsRepository),
      FlatsPersonalListScreen(),
      FlatsFavoritesListScreen()
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
        appBar: AppBar(
          actions: [
            if (_currentScreenIndex == 0)
              Padding(
                padding: EdgeInsets.only(right: 15),
                child: IconButton(
                  onPressed: () async {
                    var filter = await Navigator.of(context).pushNamed(
                        FilterScreen.route,
                        arguments: {'currentFilter': _filter});
                    if (filter == null) return;
                    setState(() {
                      this._filter = filter as FilterViewModel;
                    });
                  },
                  icon: Image.asset('assets/filter_white.png'),
                  iconSize: 32,
                ),
              )
          ],
          title: Text('Event Flats'),
          centerTitle: true,
        ),
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
        body: _screens[_currentScreenIndex]);
  }
}
