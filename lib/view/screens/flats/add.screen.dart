import 'package:event_flats/helpers/string.dart';
import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// ignore: must_be_immutable
class AddFlatScreen extends StatefulWidget {
  static String route = '/flats/add';

  final FlatsRepository _flatsRepository;

  AddFlatScreen(this._flatsRepository, {Key? key}) : super(key: key);

  @override
  State<AddFlatScreen> createState() => _AddFlatScreenState();
}

class _AddFlatScreenState extends State<AddFlatScreen> {
  GlobalKey<FormState> _formKey = new GlobalKey();
  bool _isLoading = false;
  bool _isAdditionalInfo = false;

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
  TextEditingController _landmarkController = new TextEditingController();
  TextEditingController _priceController = new TextEditingController();
  TextEditingController _roomsController = new TextEditingController();
  TextEditingController _floorController = new TextEditingController();
  TextEditingController _numberOfFloorsController = new TextEditingController();
  TextEditingController _areaController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _ownerNameController = new TextEditingController();
  TextEditingController _ownerPhoneController = new TextEditingController();

  @override
  void dispose() {
    _landmarkController.dispose();
    _priceController.dispose();
    _roomsController.dispose();
    _floorController.dispose();
    _numberOfFloorsController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    super.dispose();
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Укажите цену';
    return null;
  }

  String? _validateRooms(String? value) {
    if (value == null || value.isEmpty) return 'Укажите кол-во комнат';
    return null;
  }

  String? _validateFloors(String? value) {
    if (value == null || value.isEmpty) return 'Укажите этаж';
    return null;
  }

  String? _validateNumberOfFloors(String? value) {
    if (value == null || value.isEmpty) return 'Укажите кол-во этажей';
    return null;
  }

  String? _validateArea(String? value) {
    if (value != null && !isNumeric(value)) return 'Укажите число';
    return null;
  }

  String? _validateOwnerPhone(String? value) {
    if (value == null || value.isEmpty) return 'Укажите номер владельца';
    return null;
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await widget._flatsRepository.createFlat(Flat(
          _currentDistrict!,
          double.parse(_priceController.text),
          int.parse(_floorController.text),
          int.parse(_numberOfFloorsController.text),
          int.parse(_roomsController.text),
          _currentRepair!,
          DateTime.now(),
          false,
          double.parse(_areaController.text),
          _descriptionController.text,
          _landmarkController.text,
          _ownerPhoneController.text,
          ownerName: _ownerNameController.text));
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    var maskFormatter = new MaskTextInputFormatter(
        mask: '+### ## ###-##-##', filter: {"#": RegExp(r'[0-9]')});
    return Scaffold(
        appBar: AppBar(
          title: Text('Добавить квартиру'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32.0,
                          height: 32.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.0,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ],
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.check,
                        size: 32,
                      ),
                      onPressed: _onSave),
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
                  Visibility(
                      visible: _isAdditionalInfo,
                      child: TextFormField(
                        controller: _landmarkController,
                        decoration: InputDecoration(labelText: 'Ориентир'),
                      )),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Информация о квартире',
                    style: TextStyle(fontSize: 24),
                  ),
                  _divider(),
                  TextFormField(
                    validator: _validatePrice,
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: 'Цена', prefixText: '\$'),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: TextFormField(
                          validator: _validateRooms,
                          controller: _roomsController,
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
                          validator: _validateFloors,
                          controller: _floorController,
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
                          validator: _validateNumberOfFloors,
                          controller: _numberOfFloorsController,
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
                  Visibility(
                    visible: _isAdditionalInfo,
                    child: TextFormField(
                      validator: _validateArea,
                      controller: _areaController,
                      decoration: InputDecoration(
                          labelText: 'Площадь', suffixText: 'кв.м'),
                    ),
                  ),
                  Visibility(
                    visible: _isAdditionalInfo,
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(labelText: 'Описание'),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Владелец',
                    style: TextStyle(fontSize: 24),
                  ),
                  _divider(),
                  Visibility(
                    visible: _isAdditionalInfo,
                    child: TextFormField(
                      controller: _ownerNameController,
                      decoration: InputDecoration(labelText: 'Имя владельца'),
                    ),
                  ),
                  TextFormField(
                    inputFormatters: [maskFormatter],
                    validator: _validateOwnerPhone,
                    controller: _ownerPhoneController,
                    decoration: InputDecoration(labelText: 'Номер владельца'),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Visibility(
                    visible: !_isAdditionalInfo,
                    child: Center(
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isAdditionalInfo = true;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Дополнительно',
                              style: TextStyle(fontSize: 18),
                            ),
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
