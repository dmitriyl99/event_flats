import 'dart:developer';

import 'package:event_flats/events/flat_created.dart';
import 'package:event_flats/events/flat_favorited.dart';
import 'package:event_flats/events/flat_updated.dart';
import 'package:event_flats/events/service.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/view/components/drawer.dart';
import 'package:event_flats/view/viewmodels/filter.viewmodel.dart';
import 'package:flutter/material.dart';

import '../../../models/flat.dart';
import '../../../services/exceptions/authentication_failed.dart';
import '../../../services/exceptions/no_internet.dart';
import '../../../services/exceptions/server_error_exception.dart';
import '../../../services/exceptions/user_empty.dart';
import '../../components/dialogs.dart';
import '../../components/errors.dart';
import '../../components/flat.component.dart';
import '../../resources/colors.dart';
import '../login.screen.dart';
import 'filter.screen.dart';

class FlatsListScreen extends StatefulWidget {
  final FlatsRepository _flatsRepository;
  final AuthenticationService _authenticationService;

  const FlatsListScreen(this._flatsRepository, this._authenticationService,
      {Key? key})
      : super(key: key);

  @override
  State<FlatsListScreen> createState() => _FlatsListScreenState();
}

class _FlatsListScreenState extends State<FlatsListScreen> {
  FilterViewModel? _filter = new FilterViewModel(sortDate: true);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    EventService.bus.on<FlatFavorited>().listen((event) {
      if (mounted) {
        Flat flat =
            _flats.where((element) => element.id == event.flat.id).first;
        setState(() {
          flat.isFavorite = event.flat.isFavorite;
        });
      }
    });
    EventService.bus.on<FlatCreated>().listen((event) {
      if (mounted) {
        setState(() {
          _page = 1;
          _flats = [];
        });
      }
    });
    EventService.bus.on<FlatUpdated>().listen((event) {
      if (mounted) {
        setState(() {
          _page = 1;
          _flats = [];
        });
      }
    });
    _scrollcontroller.addListener(() {
      if (_scrollcontroller.position.pixels >=
          _scrollcontroller.position.maxScrollExtent) {
        if (!_isLoading)
          setState(() {
            _page += 1;
          });
      }
    });
  }

  List<Flat> _flats = [];
  int _page = 1;
  final _scrollcontroller = ScrollController();

  @override
  void dispose() {
    _scrollcontroller.dispose();
    super.dispose();
  }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.white),
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🔍',
              style: TextStyle(fontSize: 42),
            ),
            Text(
              'По вашему запросу ничего не найдено',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🏠',
              style: TextStyle(fontSize: 42),
            ),
            Text(
              'Квартиры ещё не добавлены',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDismiss(DismissDirection direction, Flat flat) async {
    if (direction != DismissDirection.endToStart) return false;
    if (!(widget._authenticationService.getUser())!.isAdmin) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Ограничение'),
                content: Container(
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.yellow,
                          size: 42,
                        ),
                        Text(
                          'У вас нет прав на удаление квартир',
                          style: TextStyle(fontSize: 21),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Ок',
                        style: TextStyle(fontSize: 19),
                      ))
                ],
              ));
      return false;
    }
    var result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Вы уверены?'),
            content: Text(
                'Вы уверены, что хотите удалить квартиру ${flat.address}?'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        'Отмена',
                        style: TextStyle(fontSize: 18),
                      )),
                  TextButton(
                    child: Text(
                      'Да',
                      style: TextStyle(fontSize: 19),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              ),
            ],
          );
        });
    return result;
  }

  void _onDismissed(DismissDirection direction, Flat flat) async {
    if (direction == DismissDirection.endToStart) {
      try {
        await widget._flatsRepository.removeById(flat.id);
      } on ServerErrorException {
        showDialog(
            context: context,
            builder: (context) => buildServerErrorDialog(context));
        return;
      } on NoInternetException {
        showDialog(
            context: context,
            builder: (context) => buildNoInternetDialog(context));
        return;
      } on AuthenticationFailed {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.primaryColor,
          content: Text(
            'Квартира удалена',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          )));
      setState(() {});
    }
  }

  Widget buildList(List<Flat> flats, {bool isLoading = false}) {
    if (flats.length == 0 && _filter != null) {
      return _buildNotFound();
    } else if (flats.length == 0) {
      return _buildEmptyList();
    }
    return RefreshIndicator(
      backgroundColor: AppColors.primaryColor,
      color: Colors.black,
      onRefresh: () async {
        setState(() {
          _page = 1;
          _flats = [];
        });
      },
      child: ListView(
        controller: _scrollcontroller,
        children: _flats
            .asMap()
            .map<int, Widget>((int index, Flat flat) {
              Widget value = Dismissible(
                  direction: DismissDirection.endToStart,
                  background: Container(
                    padding: EdgeInsets.only(right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, size: 32),
                            Text('Удалить')
                          ],
                        )
                      ],
                    ),
                    decoration: BoxDecoration(color: Colors.red),
                  ),
                  key: Key(flat.id.toString()),
                  confirmDismiss: (direction) {
                    return _confirmDismiss(direction, flat);
                  },
                  onDismissed: (direction) {
                    _onDismissed(direction, flat);
                  },
                  child: FlatComponent(flat, widget._flatsRepository));
              if (index == _flats.length - 1 && isLoading) {
                return MapEntry(
                    index,
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ));
              }
              if (index == _flats.length - 1 && !isLoading)
                return MapEntry(
                    index,
                    Padding(
                      padding: const EdgeInsets.only(bottom: 70),
                      child: value,
                    ));
              return MapEntry(index, value);
            })
            .values
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(widget._authenticationService),
      appBar: AppBar(
        actions: [
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
                  this._page = 1;
                  this._flats = [];
                });
              },
              icon: Image.asset('assets/filter_white.png'),
              iconSize: 20,
            ),
          )
        ],
        title: Text('WebHome'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: FutureBuilder<List<Flat>>(
          future:
              widget._flatsRepository.getFlats(filter: _filter, page: _page),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              _isLoading = true;
              return buildList(_flats, isLoading: true);
            }
            if (snapshot.hasError) {
              var error = snapshot.error;
              if (error is ServerErrorException)
                return buildServerError(onRefresh: () => setState(() {}));
              if (error is NoInternetException)
                return buildNoInternetError(onRefresh: () => setState(() {}));
              if (error is UnauthorizedUserException ||
                  error is AuthenticationFailed) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    LoginScreen.route, (route) => false);
                return buildDefaultError();
              }
              print(error);
              log('Error while getting flats list',
                  error: error, stackTrace: snapshot.stackTrace);
              return buildDefaultError(onRefresh: () => setState(() {}));
            }
            _isLoading = false;
            final loadedFlats = snapshot.data as List<Flat>;
            loadedFlats.forEach((loadedFlat) {
              if (_flats
                  .where((element) => element.id == loadedFlat.id)
                  .isNotEmpty) {
                return;
              }
              _flats.add(loadedFlat);
            });
            return buildList(_flats);
          },
        ),
      ),
    );
  }
}
