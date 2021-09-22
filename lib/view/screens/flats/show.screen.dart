import 'dart:io';

import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/models/user.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/screens/flats/edit.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
      _edited = true;
    }
  }

  bool _edited = false;

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
            Flexible(
              child: Text(
                flat.landmark,
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
              flat.area.toString() + ' кв.м',
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
              "\$" + flat.price.toString(),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            )
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

    Widget _callButton() {
      return ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.green),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.white),
            ))),
        onPressed: () async {
          String url = 'tel:' + flat.ownerPhone;
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(flat.ownerPhone),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.copy,
                      color: AppColors.primaryColor,
                    ))
              ],
            )));
          }
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
              Icon(Icons.call_outlined)
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
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
        actions: [
          FutureBuilder(
            future: widget.authenticationService.getUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var user = snapshot.data as User;
                if (user.isAdmin) {
                  return Row(
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 15),
                          child: IconButton(
                              onPressed: () {}, icon: Icon(Icons.delete)))
                    ],
                  );
                }
              }
              return Container();
            },
          ),
        ],
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
                    _nameAndAddressSection(),
                    _divider(),
                    _roomsAndFloors(),
                    _divider(),
                    _flatArea(),
                    _divider(),
                    _flatPrice(),
                    _divider(),
                    if (flat.description != null) _flatDescription(),
                    _divider(),
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
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          return Container();
        },
      ),
      floatingActionButton: FutureBuilder(
        future: widget.authenticationService.getUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var user = snapshot.data as User;
            if (user.isAdmin) {
              return FloatingActionButton.extended(
                backgroundColor: AppColors.primaryColor,
                onPressed: () {
                  _onEdit(context, flat);
                },
                label: Text(
                  'Редактировать',
                  style: TextStyle(color: Colors.white),
                ),
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              );
            }
          }

          return Container();
        },
      ),
    );
  }
}
