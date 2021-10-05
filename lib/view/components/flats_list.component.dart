import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/view/components/flat.component.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/viewmodels/filter.viewmodel.dart';
import 'package:flutter/material.dart';

class FlatsListComponent extends StatefulWidget {
  final Future<List<Flat>> loadingFlatsFuture;
  final FlatsRepository flatsRepository;
  final AuthenticationService authenticationService;
  final FilterViewModel? filterViewModel;

  final RefreshCallback onRefresh;

  const FlatsListComponent(
      this.loadingFlatsFuture, this.flatsRepository, this.authenticationService,
      {Key? key, this.filterViewModel, required this.onRefresh})
      : super(key: key);

  @override
  _FlatsListComponentState createState() => _FlatsListComponentState();
}

class _FlatsListComponentState extends State<FlatsListComponent> {
  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🧐',
            style: TextStyle(fontSize: 42),
          ),
          Text(
            'Что-то пошло не так...',
            style: TextStyle(fontSize: 21),
          ),
        ],
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
              'Квартиры ещё не добавлены. Нажмите на кнопку в правом нижнем углу, чтобы добавить квартиру',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildList(AsyncSnapshot<List<Flat>> snapshot) {
    var flats = snapshot.data!;
    if (flats.length == 0 && widget.filterViewModel != null) {
      return _buildNotFound();
    } else if (flats.length == 0) {
      return _buildEmptyList();
    }
    return RefreshIndicator(
      backgroundColor: AppColors.primaryColor,
      color: Colors.black,
      onRefresh: widget.onRefresh,
      child: ListView(
        children: flats
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
                  confirmDismiss: (direction) async {
                    if (direction != DismissDirection.endToStart) return false;
                    if (!(widget.authenticationService.getUser())!.isAdmin) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text('Ограничение'),
                                content: Container(
                                    height: 100,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                    return result;
                  },
                  onDismissed: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      await widget.flatsRepository.removeById(flat.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: AppColors.primaryColor,
                          content: Text(
                            'Квартира удалена',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          )));
                    }
                  },
                  child: FlatComponent(flat, widget.flatsRepository));
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: FutureBuilder<List<Flat>>(
        future: widget.loadingFlatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoading();
          }
          if (snapshot.hasError) {
            print(snapshot.error.toString() + '\n${snapshot.stackTrace}');
            return buildError();
          }
          return buildList(snapshot);
        },
      ),
    );
  }
}
