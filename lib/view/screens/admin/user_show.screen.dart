import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/models/repositories/users_repository.dart';
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:event_flats/services/exceptions/no_internet.dart';
import 'package:event_flats/services/exceptions/server_error_exception.dart';
import 'package:event_flats/services/exceptions/user_empty.dart';
import 'package:event_flats/view/components/errors.dart';
import 'package:event_flats/view/components/flat.component.dart';
import 'package:event_flats/view/components/user_form.component.dart';
import 'package:event_flats/view/viewmodels/filter.viewmodel.dart';
import 'package:flutter/material.dart';

import '../login.screen.dart';

class UserShowScreen extends StatefulWidget {
  final UsersRepository _usersRepository;
  final FlatsRepository _flatsRepository;
  const UserShowScreen(this._usersRepository, this._flatsRepository, {Key? key})
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
                          .map<FlatComponent>(
                              (e) => FlatComponent(e, widget._flatsRepository))
                          .toList()
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
