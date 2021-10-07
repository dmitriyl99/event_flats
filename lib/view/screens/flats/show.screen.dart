import 'dart:io';

import 'package:event_flats/helpers/number_formatting.dart';
import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:event_flats/services/exceptions/no_internet.dart';
import 'package:event_flats/services/exceptions/server_error_exception.dart';
import 'package:event_flats/services/exceptions/user_empty.dart';
import 'package:event_flats/view/components/errors.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/screens/flats/edit.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../login.screen.dart';

class FlatShowScreen extends StatefulWidget {
  static String route = '/flats/show';

  final AuthenticationService authenticationService;
  final FlatsRepository flatsRepository;

  const FlatShowScreen(this.authenticationService, this.flatsRepository,
      {Key? key})
      : super(key: key);

  @override
  State<FlatShowScreen> createState() => _FlatShowScreenState();
}

class _FlatShowScreenState extends State<FlatShowScreen> {
  void _onEdit(BuildContext context, Flat flat) async {
    var result = await Navigator.of(context)
        .pushNamed(EditFlatScreen.route, arguments: flat);
    if (result != null && result == true) {
      setState(() {});
    }
  }

  void _onRefresh() {
    setState(() {});
  }

  bool _edited = false;

  Widget _buildImage(Flat flat) {
    return FutureBuilder(
      future: flat.photo,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        return Image.network(snapshot.data as String);
      },
    );
  }

  void _launchPhone(String phone) async {
    String url = 'tel:' + phone;
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _onCallButtonPressed(Flat flat) async {
    if (flat.phones != null) {
      if (flat.phones!.length == 1) {
        _launchPhone(flat.phones!.first);
      } else {
        var result = await showModalBottomSheet<String>(
            context: context,
            builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: flat.phones!
                      .map<ListTile>((phone) => ListTile(
                            title: Text(phone),
                            leading: Icon(Icons.phone),
                            onTap: () {
                              Navigator.of(context).pop(phone);
                            },
                          ))
                      .toList(),
                ));
        if (result != null) _launchPhone(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    late Flat flat = ModalRoute.of(context)!.settings.arguments as Flat;

    Widget _divider() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Divider(
          color: AppColors.descriptionDividerColor,
          thickness: 2,
        ),
      );
    }

    Widget _nameAndAddressSection() {
      return Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                flat.address,
                style: TextStyle(fontSize: 23),
              ),
            ),
            if (flat.landmark != null && flat.landmark!.isNotEmpty)
              Flexible(
                child: Text(
                  flat.landmark!,
                  style: TextStyle(fontSize: 23),
                ),
              ),
          ],
        ),
      );
    }

    Widget _roomsAndFloors() {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Комнат: ${flat.numberOfRooms}",
              style: TextStyle(fontSize: 22),
            ),
            Text("Этаж: ${flat.floor}", style: TextStyle(fontSize: 22)),
            Text("Этажность ${flat.numberOfFloors}",
                style: TextStyle(fontSize: 22))
          ],
        ),
      );
    }

    Widget _flatArea() {
      return Padding(
        padding: EdgeInsets.all(5.0),
        child: Row(
          children: [
            Text(
              'Общая площадь:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              flat.area!.toStringAsFixed(0) + ' кв.м',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            )
          ],
        ),
      );
    }

    Widget _flatPrice() {
      return Padding(
        padding: EdgeInsets.all(5.0),
        child: Row(
          children: [
            Text(
              'Цена за квартиру:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              NumberFormattingHelper.currency(flat.price),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            )
          ],
        ),
      );
    }

    Widget _flatRepair() {
      return Padding(
        padding: EdgeInsets.all(5.0),
        child: Row(
          children: [
            Text('Ремонт:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
            SizedBox(
              width: 5,
            ),
            Text(flat.flatRepair,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500))
          ],
        ),
      );
    }

    Widget _flatDescription() {
      return Padding(
        padding: EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Описание',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              flat.description!,
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
      );
    }

    Widget _ownerInfo() {
      return Column(
        children: [
          if (flat.ownerName != null && flat.ownerName!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Text('Имя владельца:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
                  SizedBox(
                    width: 5,
                  ),
                  Text(flat.ownerName!,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w500))
                ],
              ),
            ),
          if (flat.phones != null && flat.phones!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Text('Номер владельца:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
                  SizedBox(
                    width: 5,
                  ),
                  if (flat.phones!.length == 1)
                    Text(flat.phones![0],
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500))
                  else
                    Column(
                      children: flat.phones!
                          .map<Widget>((e) => Text(
                                e,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ))
                          .toList(),
                    )
                ],
              ),
            ),
        ],
      );
    }

    Widget _callButton() {
      return ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.green),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.white),
            ))),
        onPressed: () {
          _onCallButtonPressed(flat);
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Позвонить',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                width: 10,
              ),
              Icon(Icons.call_outlined)
            ],
          ),
        ),
      );
    }

    Widget? _editButton() {
      var currentUser = widget.authenticationService.getUser();
      if (currentUser == null) return null;
      if (!currentUser.isAdmin) return null;
      return FloatingActionButton.extended(
        backgroundColor: AppColors.primaryColor,
        onPressed: () {
          _onEdit(context, flat);
        },
        label: Text(
          'Редактировать',
          style: TextStyle(color: Colors.black),
        ),
        icon: Icon(
          Icons.edit,
          color: Colors.black,
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Event Flats'),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(_edited);
            },
            icon: Icon(
              Platform.isIOS ? CupertinoIcons.back : Icons.arrow_back,
              size: 28,
            ),
          ),
        ),
        body: FutureBuilder(
          future: widget.flatsRepository.getById(flat.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              flat = snapshot.data as Flat;
              return Container(
                padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImage(flat),
                      _nameAndAddressSection(),
                      _divider(),
                      _roomsAndFloors(),
                      _divider(),
                      if (flat.area != null) _flatArea(),
                      if (flat.area != null) _divider(),
                      _flatRepair(),
                      _divider(),
                      _flatPrice(),
                      _divider(),
                      if (flat.description != null &&
                          flat.description!.isNotEmpty)
                        _flatDescription(),
                      if (flat.description != null &&
                          flat.description!.isNotEmpty)
                        _divider(),
                      _ownerInfo(),
                      SizedBox(
                        height: 30,
                      ),
                      if (flat.phones != null && flat.phones!.isNotEmpty)
                        _callButton(),
                    ],
                  ),
                ),
              );
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ));
            }
            if (snapshot.hasError) {
              var error = snapshot.error;
              if (error is ServerErrorException)
                return buildServerError(onRefresh: _onRefresh);
              if (error is NoInternetException)
                return buildNoInternetError(onRefresh: _onRefresh);
              if (error is UnauthorizedUserException ||
                  error is AuthenticationFailed) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    LoginScreen.route, (route) => false);
                return buildDefaultError();
              }
              return buildDefaultError(onRefresh: _onRefresh);
            }
            return Container();
          },
        ),
        floatingActionButton: _editButton());
  }
}
