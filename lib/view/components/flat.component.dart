import 'package:event_flats/events/flat_favorited.dart';
import 'package:event_flats/events/service.dart';
import 'package:event_flats/helpers/date_formatting.dart';
import 'package:event_flats/helpers/number_formatting.dart';
import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:event_flats/services/exceptions/no_internet.dart';
import 'package:event_flats/services/exceptions/server_error_exception.dart';
import 'package:event_flats/view/components/dialogs.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/screens/flats/show.screen.dart';
import 'package:event_flats/view/screens/login.screen.dart';
import 'package:flutter/material.dart';

class FlatComponent extends StatelessWidget {
  final Flat flat;

  const FlatComponent(this.flat, this._flatsRepository, {Key? key})
      : super(key: key);

  final FlatsRepository _flatsRepository;

  void _onHouseTap(context) async {
    try {
      await _flatsRepository.toggleFavorite(flat.id);
    } on ServerErrorException {
      showDialog(
          context: context,
          builder: (context) => buildServerErrorDialog(context));
      return;
    } on NoInternetException {
      showDialog(
          context: context,
          builder: (context) => buildNoInternetDialog(context));
      return;
    } on AuthenticationFailed {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
      return;
    }
    EventService.bus.fire(FlatFavorited(flat));
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = TextStyle(fontSize: 18);
    if (flat.sold) {
      titleStyle = titleStyle.copyWith(
          color: Colors.red, decoration: TextDecoration.lineThrough);
    }
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
                    onTap: () {
                      _onHouseTap(context);
                    },
                    child: Image.asset(
                      flat.isFavorite
                          ? 'assets/house_favorite.png'
                          : 'assets/house.png',
                      height: 24,
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    '${flat.numberOfRooms}/${flat.floor}/${flat.numberOfFloors}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(FlatShowScreen.route, arguments: flat);
              },
              title: Text(
                flat.address,
                style: titleStyle,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (flat.landmark != null && flat.landmark!.isNotEmpty)
                    Text(flat.landmark!,
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text(
                    flat.flatRepair,
                  ),
                ],
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
