import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/models/user.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/view/components/flat.component.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/screens/flats/add.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlatsListScreen extends StatefulWidget {
  final FlatsRepository _flatsRepository;
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

  Future<Map<String, dynamic>> init() async {
    var flats = await widget._flatsRepository.getFlats();
    var user = await widget._authenticationService.getUser();

    return {'flats': flats, 'user': user};
  }

  Widget buildList(BuildContext context, List<Flat> flats, User currentUser) {
    if (flats.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.home,
            size: 64,
          ),
          SizedBox(
            height: 24,
          ),
          Text(
            'Квартиры ещё не добавлены. Нажмите кнопку в правом нижнем углу, чтобы добавить квартиру',
            style: TextStyle(color: Colors.white, fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return RefreshIndicator(
      strokeWidth: 3.0,
      backgroundColor: AppColors.primaryColor,
      color: Colors.white,
      onRefresh: () async {
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 12.5),
        child: ListView.separated(
            itemBuilder: (context, index) {
              var flat = flats[index];
              if (currentUser.isAdmin) {
                return Dismissible(
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
                                  'ВЫ уверены, что хотите удалить квартиру ${flat.address}?'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text('Отмена')),
                                TextButton(
                                  child: Text('Уверен'),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          });
                      return result;
                    },
                    onDismissed: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        await widget._flatsRepository.removeById(flat.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: AppColors.primaryColor,
                            content: Text(
                              'Квартира удалена',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            )));
                        setState(() {});
                      }
                    },
                    child: FlatComponent(flat, onFlatEdit));
              }
              return FlatComponent(flat, onFlatEdit);
            },
            separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    color: AppColors.listDividerColor,
                    height: 8,
                    thickness: 1,
                  ),
                ),
            itemCount: flats.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: IconButton(onPressed: () {}, icon: Icon(Icons.sort)),
            )
          ],
          title: Text('Event Flats'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primaryColor,
          onPressed: () async {
            var result =
                await Navigator.of(context).pushNamed(AddFlatScreen.route);
            if (result != null) {
              setState(() {});
            }
          },
          label: Text(
            'Добавить',
            style: TextStyle(color: Colors.white),
          ),
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: FutureBuilder(
          future: init(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return buildError(
                  snapshot.error.toString() + '\n${snapshot.stackTrace}');
            } else if (snapshot.connectionState != ConnectionState.done) {
              return buildLoading();
            }
            var data = snapshot.data as Map<String, dynamic>;
            return buildList(
                context, data['flats'] as List<Flat>, data['user'] as User);
          },
        ));
  }
}
