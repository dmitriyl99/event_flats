import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/firebase_flats_repository.dart';
import 'package:event_flats/models/user.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/view/components/flat.component.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/screens/flats/add.screen.dart';
import 'package:event_flats/view/screens/flats/filter.screen.dart';
import 'package:event_flats/view/viewmodels/filter.viewmodel.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlatsListScreen extends StatefulWidget {
  final FireabaseFlatsRepository _flatsRepository;
  final AuthenticationService _authenticationService;

  static const String route = '/flats';
  const FlatsListScreen(this._flatsRepository, this._authenticationService,
      {Key? key})
      : super(key: key);

  @override
  State<FlatsListScreen> createState() => _FlatsListScreenState();
}

class _FlatsListScreenState extends State<FlatsListScreen> {
  Widget buildError(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.white),
      ),
    );
  }

  void onFlatEdit() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: () async {},
                icon: Icon(Icons.favorite),
                iconSize: 32,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: () async {
                  var flats = await widget._flatsRepository.getFlats();
                  double maxPrice = 100000;
                  if (flats.length > 0) {
                    flats.sort((a, b) {
                      return b.price.compareTo(a.price);
                    });
                    maxPrice = flats[0].price;
                  }
                  var filter = await Navigator.of(context).pushNamed(
                      FilterScreen.route,
                      arguments: {'maxPrice': maxPrice});
                  if (filter == null) return;
                  filter = filter as FilterViewModel;
                  print(filter);
                },
                icon: Icon(Icons.settings),
                iconSize: 32,
              ),
            )
          ],
          title: Text('Event Flats'),
        ),
        floatingActionButton: FloatingActionButton.extended(
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
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: widget._flatsRepository.getFlatsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return buildLoading();
              }
              if (snapshot.hasError) {
                return Text(
                    snapshot.error.toString() + '\n${snapshot.stackTrace}');
              }
              return ListView(
                children: snapshot.data!.docs
                    .map<Widget>((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  var flat = Flat.fromJson(data);
                  flat.id = document.id;
                  return Dismissible(
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
                      key: Key(flat.id),
                      confirmDismiss: (direction) async {
                        if (direction != DismissDirection.endToStart)
                          return false;
                        var result = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Вы уверены?'),
                                content: Text(
                                    'Вы уверены, что хотите удалить квартиру ${flat.address}?'),
                                actions: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                        if (result) {
                          await widget._flatsRepository.removeById(flat.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: AppColors.primaryColor,
                              content: Text(
                                'Квартира удалена',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              )));
                        }
                        return false;
                      },
                      child: FlatComponent(
                          flat, widget._flatsRepository, onFlatEdit));
                }).toList(),
              );
            },
          ),
        ));
  }
}
