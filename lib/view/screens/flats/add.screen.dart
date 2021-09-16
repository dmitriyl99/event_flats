import 'package:event_flats/view/resources/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AddFlatScreen extends StatefulWidget {
  static String route = '/flats/add';

  AddFlatScreen({Key? key}) : super(key: key);

  @override
  State<AddFlatScreen> createState() => _AddFlatScreenState();
}

class _AddFlatScreenState extends State<AddFlatScreen> {
  GlobalKey<FormState> _formKey = new GlobalKey();

  List<String> _districts = [
    "Алмазарский район",
    "Бектемирский район",
    'Мирабадский район',
    'Мирзо-Улугбекский район',
    'Сергелийский район',
    'Шайхантаурский район',
    'Юнусабадский район',
    'Яккасарайский район',
    'Чиланзарский район',
    'Яшнабадский район'
  ];

  List<String> _repairs = [
    "Евро-ремонт",
    "Средний",
    "Требует ремонта",
    "Черновая отделка"
  ];

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(
        color: AppColors.descriptionDividerColor,
        thickness: 2,
      ),
    );
  }

  String? _currentDistrict;
  String? _currentRepair;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Добавить квартиру'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: IconButton(
                icon: Icon(
                  Icons.check,
                  size: 32,
                ),
                onPressed: () {},
              ),
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Адрес',
                    style: TextStyle(fontSize: 24),
                  ),
                  _divider(),
                  FormField<String>(builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(labelText: "Район"),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            value: _currentDistrict ?? _districts.first,
                            isDense: true,
                            onChanged: (value) {
                              setState(() {
                                _currentDistrict = value;
                              });
                            },
                            items: _districts
                                .map<DropdownMenuItem<String>>(
                                    (value) => DropdownMenuItem(
                                          value: value,
                                          child: Text(value),
                                        ))
                                .toList()),
                      ),
                    );
                  }),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Ориентир'),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Информация о квартире',
                    style: TextStyle(fontSize: 24),
                  ),
                  _divider(),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: 'Цена', prefixText: '\$'),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Комнат'),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '/',
                        style: TextStyle(fontSize: 30),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Этаж'),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '/',
                        style: TextStyle(fontSize: 30),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Этажность'),
                        ),
                      )
                    ],
                  ),
                  FormField<String>(builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(labelText: "Ремонт"),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            value: _currentRepair ?? _repairs.first,
                            onChanged: (value) {
                              setState(() {
                                _currentRepair = value;
                              });
                            },
                            items: _repairs
                                .map<DropdownMenuItem<String>>(
                                    (value) => DropdownMenuItem(
                                          value: value,
                                          child: Text(value),
                                        ))
                                .toList()),
                      ),
                    );
                  }),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Площадь', suffixText: 'кв.м'),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Владелец',
                    style: TextStyle(fontSize: 24),
                  ),
                  _divider(),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Имя владельца'),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Номер владельца'),
                  ),
                  TextFormField(
                    maxLines: 4,
                    decoration: InputDecoration(labelText: 'Описание'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
