import 'dart:developer';

import 'package:event_flats/events/service.dart';
import 'package:event_flats/events/user_updated.dart';
import 'package:event_flats/helpers/string.dart';
import 'package:event_flats/models/repositories/users_repository.dart';
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:event_flats/services/exceptions/forbidden_exception.dart';
import 'package:event_flats/services/exceptions/no_internet.dart';
import 'package:event_flats/services/exceptions/server_error_exception.dart';
import 'package:event_flats/services/exceptions/user_empty.dart';
import 'package:event_flats/view/components/errors.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/screens/admin/user_show.screen.dart';
import 'package:flutter/material.dart';

import '../login.screen.dart';

class UsersListScreen extends StatefulWidget {
  final UsersRepository _usersRepository;

  const UsersListScreen(this._usersRepository, {Key? key}) : super(key: key);

  static const String route = '/admin/users';

  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  @override
  void initState() {
    super.initState();
    EventService.bus.on<UserUpdated>().listen((event) {
      setState(() {});
    });
  }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.white),
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() {});
  }

  Widget buildList(List<Map<String, dynamic>> users) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: RefreshIndicator(
          backgroundColor: AppColors.primaryColor,
          color: Colors.black,
          child: ListView.builder(
            itemBuilder: (context, index) {
              var user = users[index];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Card(
                  elevation: 4,
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(UserShowScreen.route, arguments: user);
                    },
                    leading: Icon(
                      Icons.person,
                      size: 36,
                    ),
                    title: Text(user['name']),
                    subtitle: Text(users[index]['flats_count'].toString() +
                        ' ${flatByCount(users[index]['flats_count'])}'),
                    trailing: user['last_activity_date'] != null
                        ? Column(
                            children: [
                              Text('Активность:'),
                              Text(user['last_activity_date'])
                            ],
                          )
                        : null,
                  ),
                ),
              );
            },
            itemCount: users.length,
          ),
          onRefresh: _onRefresh),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Пользователи'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: widget._usersRepository.index(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoading();
          }
          if (snapshot.hasError) {
            var error = snapshot.error;
            if (error is ServerErrorException)
              return buildServerError(onRefresh: _onRefresh);
            if (error is NoInternetException)
              return buildNoInternetError(onRefresh: _onRefresh);
            if (error is UnauthorizedUserException ||
                error is AuthenticationFailed) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
              return buildDefaultError();
            }
            if (error is ForbiddenException) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Отказано в доступе',
                            textAlign: TextAlign.center),
                        content: Text(
                            'У вас нет доступа к этой части приложения, вы будете возращены на главный экран'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Ок',
                                style: TextStyle(fontSize: 18),
                              ))
                        ],
                      )).then((value) => Navigator.of(context).pop());
            }
            return buildDefaultError(onRefresh: _onRefresh);
          }
          return buildList(snapshot.data!);
        },
      ),
    );
  }
}
