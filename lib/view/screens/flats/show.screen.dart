import 'package:event_flats/models/flat.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FlatShowScreen extends StatelessWidget {
  static String route = '/flats/show';

  const FlatShowScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flat = ModalRoute.of(context)!.settings.arguments as Flat;

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
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                flat.address,
                style: TextStyle(fontSize: 23),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
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
              flat.description,
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
          title: Text(flat.address),
        ),
        body: Container(
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
                _flatDescription(),
                _divider(),
                _callButton(),
              ],
            ),
          ),
        ));
  }
}
