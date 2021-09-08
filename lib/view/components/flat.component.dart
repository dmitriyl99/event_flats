import 'package:event_flats/helpers/date_formatting.dart';
import 'package:event_flats/models/flat.dart';
import 'package:flutter/material.dart';

class FlatComponent extends StatelessWidget {
  final Flat flat;

  const FlatComponent(this.flat, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Image.asset(
            flat.isFavorite ? 'assets/house_favorite.png' : 'assets/house.png',
            height: 30,
          ),
          onTap: () {},
          title: Row(
            children: [
              Text(
                flat.name,
                style: TextStyle(fontSize: 18),
              ),
              Container(
                decoration: BoxDecoration(),
                padding: EdgeInsets.all(2),
                child: Text(flat.price.toString()),
              ),
            ],
          ),
          subtitle: Text(
              '${flat.numberOfRooms}/${flat.floor}/${flat.numberOfFloors}'),
          trailing: Column(
            children: [
              Text(
                flat.flatRepair,
                style: TextStyle(fontSize: 16),
              ),
              Text(
                DateFormattingHelper.formatDate(flat.createdAt),
                style: TextStyle(fontSize: 16),
              )
            ],
          ),
        ),
      ),
    );
  }
}
