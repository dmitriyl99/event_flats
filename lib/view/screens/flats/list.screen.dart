import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/view/components/flat.component.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlatsListScreen extends StatelessWidget {
  final FlatsRepository _flatsRepository;

  static const String route = '/flats';
  const FlatsListScreen(this._flatsRepository, {Key? key}) : super(key: key);

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

  Widget buildList(BuildContext context, List<Flat> flats) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.5),
      child: ListView.separated(
          itemBuilder: (context, index) {
            return FlatComponent(flats[index]);
          },
          separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: AppColors.dividerColor,
                  height: 8,
                  thickness: 1,
                ),
              ),
          itemCount: flats.length),
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
          onPressed: () {},
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
          future: _flatsRepository.getFlats(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return buildError(snapshot.error.toString());
            } else if (snapshot.connectionState != ConnectionState.done) {
              return buildLoading();
            }
            return buildList(context, snapshot.data as List<Flat>);
          },
        ));
  }
}
