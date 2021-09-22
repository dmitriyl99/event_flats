import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EditFlatScreen extends StatefulWidget {
  static String route = '/flats/edit';

  final FlatsRepository _flatsRepository;

  EditFlatScreen(this._flatsRepository, {Key? key}) : super(key: key);

  @override
  State<EditFlatScreen> createState() => _EditFlatScreenState();
}

class _EditFlatScreenState extends State<EditFlatScreen> {
  GlobalKey<FormState> _formKey = new GlobalKey();
  bool _isLoading = false;

  bool _loaded = false;

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

  String? _validateLandmark(String? value) {
    if (value == null || value.isEmpty) return 'Укажите ориентир';
    return null;
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
    if (value == null || value.isEmpty) return 'Укажите площадь';
    return null;
  }

  String? _validateOwnerPhone(String? value) {
    if (value == null || value.isEmpty) return 'Укажите номер владельца';
    return null;
  }

  void _onSave(String id, DateTime createdAt) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      var flat = Flat(
          _currentDistrict!,
          double.parse(_priceController.text),
          int.parse(_floorController.text),
          int.parse(_numberOfFloorsController.text),
          int.parse(_roomsController.text),
          _currentRepair!,
          createdAt,
          false,
          double.parse(_areaController.text),
          _descriptionController.text,
          _landmarkController.text,
          _ownerPhoneController.text,
          ownerName: _ownerNameController.text);
      flat.id = id;
      await widget._flatsRepository.updateFlat(flat);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flat = ModalRoute.of(context)!.settings.arguments as Flat;
    if (!_loaded) {
      _currentDistrict = flat.address;
      _currentRepair = flat.flatRepair;
      _landmarkController.text = flat.landmark;
      _priceController.text = flat.price.toString();
      _roomsController.text = flat.numberOfRooms.toString();
      _floorController.text = flat.floor.toString();
      _numberOfFloorsController.text = flat.numberOfFloors.toString();
      _areaController.text = flat.area.toString();
      _descriptionController.text = flat.description ?? '';
      _ownerNameController.text = flat.ownerName ?? '';
      _ownerPhoneController.text = flat.ownerPhone;
      _loaded = true;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Редактировать квартиру'),
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
                      onPressed: () async {
                        _onSave(flat.id, flat.createdAt);
                      }),
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
                    validator: _validateLandmark,
                    controller: _landmarkController,
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
                  TextFormField(
                    validator: _validateArea,
                    controller: _areaController,
                    decoration: InputDecoration(
                        labelText: 'Площадь', suffixText: 'кв.м'),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(labelText: 'Описание'),
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
                    controller: _ownerNameController,
                    decoration: InputDecoration(labelText: 'Имя владельца'),
                  ),
                  TextFormField(
                    validator: _validateOwnerPhone,
                    controller: _ownerPhoneController,
                    decoration: InputDecoration(labelText: 'Номер владельца'),
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
