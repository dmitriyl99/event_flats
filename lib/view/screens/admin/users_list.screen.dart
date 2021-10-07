import 'dart:developer';

import 'package:event_flats/models/repositories/users_repository.dart';
import 'package:flutter/material.dart';

class UsersListScreen extends StatefulWidget {
  final UsersRepository _usersRepository;

  const UsersListScreen(this._usersRepository, {Key? key}) : super(key: key);

  static const String route = '/admin/users';

  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Пользователи'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: widget._usersRepository.index(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return buildLoading();
          if (snapshot.hasError) {
            log(snapshot.error.toString());
            log(snapshot.stackTrace.toString());
          }
          return Container();
        },
      ),
    );
  }
}
