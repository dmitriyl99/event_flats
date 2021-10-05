import 'dart:io';

import 'package:event_flats/helpers/number_formatting.dart';
import 'package:event_flats/helpers/string.dart';
import 'package:event_flats/models/dto/flat.dart';
import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/services/districts.dart';
import 'package:event_flats/services/repairs.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  List<Map<String, dynamic>> _districts = [];
  List<String> _repairs = getRepairs();

  List<String> _phones = [];
  List<File> _images = [];

  late int _currentDistrict = 1;
  int? _currentLandmark;
  late String _currentRepair = _repairs.first;
  TextEditingController _landmarkController = new TextEditingController();
  TextEditingController _priceController = new TextEditingController();
  TextEditingController _roomsController = new TextEditingController();
  TextEditingController _floorController = new TextEditingController();
  TextEditingController _numberOfFloorsController = new TextEditingController();
  TextEditingController _areaController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _ownerNameController = new TextEditingController();
  TextEditingController _ownerPhoneController = new TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _currentImage;
  late FocusNode _floorFocusNode;

  @override
  void initState() {
    super.initState();

    _floorFocusNode = new FocusNode();

    _roomsController.addListener(() {
      if (_roomsController.text.isNotEmpty) {
        _floorFocusNode.requestFocus();
      }
    });

    getDistricts().then((value) {
      Future.delayed(Duration.zero, () {
        setState(() {
          _districts = value;
          if (value.isNotEmpty) {
            _currentDistrict = value.first['id'];
          }
        });
      });
    });
  }

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
    if (int.tryParse(value) == null) return 'Укажите число';
    if (_numberOfFloorsController.text.isNotEmpty) {
      var numberOfFloors = int.tryParse(_numberOfFloorsController.text);
      if (numberOfFloors == null) return null;
      if (int.tryParse(value)! > numberOfFloors) return 'Этаж больше этажности';
    }
    return null;
  }

  String? _validateNumberOfFloors(String? value) {
    if (value == null || value.isEmpty) return 'Укажите кол-во этажей';
    return null;
  }

  String? _validateArea(String? value) {
    if (value == null || value.isEmpty) return 'Укажите площадь';
    if (value.isNotEmpty && !isNumeric(value)) return 'Укажите число';
    return null;
  }

  String? _validateOwnerPhone(String? value) {
    if (value == null || value.isEmpty) return 'Укажите номер владельца';
    return null;
  }

  void _onSave(int id, DateTime createdAt) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      var flat = FlatDto(
          _currentDistrict,
          _currentLandmark,
          _landmarkController.text,
          double.parse(_priceController.text),
          int.parse(_roomsController.text),
          int.parse(_floorController.text),
          int.parse(_numberOfFloorsController.text),
          _currentRepair,
          double.parse(_areaController.text),
          _descriptionController.text,
          _phones,
          _images,
          _ownerNameController.text);
      await widget._flatsRepository.updateFlat(flat);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop(true);
    }
  }

  bool _currentDistrictHasLandmarks() {
    if (_districts.isEmpty) return false;
    return _districts[_currentDistrict]['landmarks'].length > 0;
  }

  @override
  Widget build(BuildContext context) {
    final flat = ModalRoute.of(context)!.settings.arguments as Flat;
    if (!_loaded) {
      _currentDistrict = flat.districtId;
      _currentLandmark = flat.landmarkId;
      _currentRepair = flat.flatRepair;
      _landmarkController.text = flat.landmark;
      _priceController.text = NumberFormattingHelper.format(flat.price);
      _roomsController.text = flat.numberOfRooms.toString();
      _floorController.text = flat.floor.toString();
      _numberOfFloorsController.text = flat.numberOfFloors.toString();
      if (flat.area != null) {
        _areaController.text = flat.area!.toStringAsFixed(0);
      }
      _descriptionController.text = flat.description ?? '';
      _ownerNameController.text = flat.ownerName ?? '';
      _loaded = true;
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
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
                  FormField<int>(
                      enabled: _districts.isNotEmpty,
                      builder: (FormFieldState<int> state) {
                        return InputDecorator(
                          decoration: InputDecoration(labelText: "Район"),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                                value: _currentDistrict,
                                isDense: true,
                                onChanged: (value) {
                                  setState(() {
                                    _currentDistrict = value!;
                                  });
                                },
                                items: _districts
                                    .map<DropdownMenuItem<int>>(
                                        (value) => DropdownMenuItem(
                                              value: value['id'],
                                              child: Text(value['title']),
                                            ))
                                    .toList()),
                          ),
                        );
                      }),
                  Visibility(
                    visible: _currentDistrictHasLandmarks(),
                    child: FormField<int>(builder: (FormFieldState<int> state) {
                      return InputDecorator(
                        decoration: InputDecoration(labelText: "Ориентир"),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                              value: _currentLandmark,
                              isDense: true,
                              onChanged: (value) {
                                setState(() {
                                  _currentLandmark = value!;
                                });
                              },
                              items: _districts[_currentDistrict]['lanndmarks']
                                  .map<DropdownMenuItem<int>>(
                                      (value) => DropdownMenuItem(
                                            value: value['id'],
                                            child: Text(value['title']),
                                          ))
                                  .toList()),
                        ),
                      );
                    }),
                  ),
                  Visibility(
                    visible: !_currentDistrictHasLandmarks(),
                    child: TextFormField(
                      controller: _landmarkController,
                      decoration: InputDecoration(labelText: 'Ориентир'),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Информация о квартире',
                    style: TextStyle(fontSize: 24),
                  ),
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
                          focusNode: _floorFocusNode,
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
                            value: _currentRepair,
                            onChanged: (value) {
                              setState(() {
                                _currentRepair = value!;
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
                    'Изображение',
                    style: TextStyle(fontSize: 21),
                  ),
                  if (_currentImage == null)
                    FutureBuilder(
                      future: flat.photo,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Container();
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        }
                        return Image.network(snapshot.data as String);
                      },
                    ),
                  if (_currentImage != null)
                    Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Image.file(_currentImage!)
                      ],
                    ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  AppColors.primaryColor)),
                          onPressed: () async {
                            final XFile? image = await _picker.pickImage(
                                source: ImageSource.camera);
                            if (image != null) {
                              print(image.path);
                              setState(() {
                                _currentImage = File(image.path);
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            child: Text('С камеры',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black)),
                          )),
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  AppColors.primaryColor)),
                          onPressed: () async {
                            final XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery);
                            if (image != null) {
                              print(image.path);
                              setState(() {
                                _currentImage = File(image.path);
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            child: Text('С устройства',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black)),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Владелец',
                    style: TextStyle(fontSize: 24),
                  ),
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
