import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/models/repositories/users_repository.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:event_flats/services/exceptions/no_internet.dart';
import 'package:event_flats/services/exceptions/server_error_exception.dart';
import 'package:event_flats/services/exceptions/user_empty.dart';
import 'package:event_flats/view/components/dialogs.dart';
import 'package:event_flats/view/components/errors.dart';
import 'package:event_flats/view/components/flat.component.dart';
import 'package:event_flats/view/components/user_form.component.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/viewmodels/filter.viewmodel.dart';
import 'package:flutter/material.dart';

import '../login.screen.dart';

class UserShowScreen extends StatefulWidget {
  final UsersRepository _usersRepository;
  final FlatsRepository _flatsRepository;
  final AuthenticationService _authenticationService;
  const UserShowScreen(
      this._usersRepository, this._flatsRepository, this._authenticationService,
      {Key? key})
      : super(key: key);

  static const String route = '/users/show';

  @override
  _UserShowScreenState createState() => _UserShowScreenState();
}

class _UserShowScreenState extends State<UserShowScreen> {
  Future<void> _onFlatsRefresh() async {
    setState(() {});
  }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.white),
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

  @override
  Widget build(BuildContext context) {
    var user =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Text(user['name']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              UserFormComponent(user, widget._usersRepository),
              SizedBox(
                height: 16,
              ),
              Divider(
                color: Colors.grey,
              ),
              FutureBuilder<List<Flat>>(
                future: widget._flatsRepository.getFlats(
                    filter: new FilterViewModel(
                        creatorId: user['id'], sortDate: true)),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    var error = snapshot.error;
                    if (error is ServerErrorException)
                      return buildServerError(onRefresh: _onFlatsRefresh);
                    if (error is NoInternetException)
                      return buildNoInternetError(onRefresh: _onFlatsRefresh);
                    if (error is UnauthorizedUserException ||
                        error is AuthenticationFailed) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          LoginScreen.route, (route) => false);
                      return buildDefaultError();
                    }
                    return buildDefaultError(onRefresh: _onFlatsRefresh);
                  }
                  if (snapshot.connectionState != ConnectionState.done)
                    return buildLoading();
                  var flats = snapshot.data!;
                  return Column(
                    children: [
                      Text(
                        'Всего квартир: ' + flats.length.toString(),
                        style: TextStyle(fontSize: 21),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      ...flats
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                child: FlatComponent(
                                    flat, widget._flatsRepository));
                            if (index == flats.length - 1)
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
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
