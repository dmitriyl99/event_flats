import 'package:event_flats/helpers/date_formatting.dart';
import 'package:event_flats/helpers/number_formatting.dart';
import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/screens/flats/show.screen.dart';
import 'package:flutter/material.dart';

class FlatComponent extends StatelessWidget {
  final Flat flat;

  const FlatComponent(this.flat, this._flatsRepository, {Key? key})
      : super(key: key);

  final FlatsRepository _flatsRepository;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(FlatShowScreen.route, arguments: flat);
            },
            child: ListTile(
              isThreeLine: true,
              leading: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _flatsRepository.toggleFavorite(flat.id);
                    },
                    child: Image.asset(
                      flat.isFavorite
                          ? 'assets/house_favorite.png'
                          : 'assets/house.png',
                      height: 36,
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    '${flat.numberOfRooms}/${flat.floor}/${flat.numberOfFloors}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(FlatShowScreen.route, arguments: flat);
              },
              title: Text(
                flat.address,
                style: TextStyle(fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(flat.flatRepair)],
              ),
              trailing: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.all(7),
                    child: Text(
                      NumberFormattingHelper.currency(flat.price),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(DateFormattingHelper.formatDate(flat.createdAt))
                ],
              ),
            ),
          ),
        ));
  }
}
