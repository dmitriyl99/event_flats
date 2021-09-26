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
              leading: GestureDetector(
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
              onTap: () {
                Navigator.of(context)
                    .pushNamed(FlatShowScreen.route, arguments: flat);
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      flat.address,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${flat.numberOfRooms}/${flat.floor}/${flat.numberOfFloors}'),
                  Text(flat.flatRepair)
                ],
              ),
              trailing: Container(
                decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(5),
                child: Text(
                  NumberFormattingHelper.currency(flat.price),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          ),
        ));
  }
}
