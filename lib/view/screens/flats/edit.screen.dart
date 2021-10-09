import 'dart:io';

import 'package:event_flats/helpers/number_formatting.dart';
import 'package:event_flats/helpers/string.dart';
import 'package:event_flats/models/dto/flat.dart';
import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/services/districts.dart';
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:event_flats/services/exceptions/no_internet.dart';
import 'package:event_flats/services/exceptions/server_error_exception.dart';
import 'package:event_flats/services/exceptions/validation_exception.dart';
import 'package:event_flats/services/repairs.dart';
import 'package:event_flats/view/components/dialogs.dart';
import 'package:event_flats/view/components/flat_number.component.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../login.screen.dart';

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

  List<File> _images = [];

  late int _currentDistrict = 0;
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
  List<FlatPhoneNumberComponent> _phoneFields = [];
  int _phonesIndex = 0;

  final ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();

    getDistricts().then((value) {
      Future.delayed(Duration.zero, () {
        setState(() {
          _districts = value;
          if (value.isNotEmpty) {
            if (_currentDistrict == 0) _currentDistrict = value.first['id'];
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
    var phones = _phoneFields
        .map<String>((e) => e.getPhone())
        .toList()
        .where((element) => element.isNotEmpty);
    if (value == null && phones.isNotEmpty) return null;
    if (value != null && value.isEmpty && phones.isNotEmpty) return null;
    if (value == null && phones.isEmpty) return 'Укажите номер владельца';
    if (value != null && value.isEmpty && phones.isEmpty)
      return 'Укажите номер владельца';
    return null;
  }

  void _onSave(int id, DateTime createdAt) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      List<String> phones = [];
      if (_ownerPhoneController.text.isNotEmpty)
        phones.add(_ownerPhoneController.text);
      phones.addAll(_phoneFields
          .map<String>((e) => e.getPhone())
          .toList()
          .where((element) => element.isNotEmpty)
          .toList());
      var flat = FlatDto(
          _currentDistrict,
          _currentLandmark,
          _landmarkController.text,
          double.parse(_priceController.text.replaceAll(',', '')),
          int.parse(_roomsController.text),
          int.parse(_floorController.text),
          int.parse(_numberOfFloorsController.text),
          _currentRepair,
          double.parse(_areaController.text),
          _descriptionController.text,
          phones,
          _images,
          _ownerNameController.text,
          id: id);
      try {
        await widget._flatsRepository.updateFlat(flat);
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
      } on ValidationException {
        showDialog(
            context: context,
            builder: (context) => buildValidationError(context));
        return;
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
      Navigator.of(context).pop(true);
    }
  }

  void _deletePhone(int index) {
    setState(() {
      _phoneFields
          .removeWhere((element) => element.key == Key(index.toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final flat = ModalRoute.of(context)!.settings.arguments as Flat;
    if (!_loaded) {
      _currentDistrict = flat.districtId;
      _currentLandmark = flat.landmarkId;
      _currentRepair = flat.flatRepair;
      _landmarkController.text = flat.landmark ?? '';
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
      _ownerPhoneController.text = flat.phones![0].toString();
      if (flat.phones != null && flat.phones!.length > 1) {
        var phones = flat.phones!;
        for (int i = 1; i < phones.length; i++) {
          FlatPhoneNumberComponent element =
              FlatPhoneNumberComponent(Key(i.toString()), () {
            _deletePhone(i);
          }, initialValue: phones[i]);
          _phoneFields.add(element);
          _phonesIndex = i;
        }
      }
    }
    var landmarks = [];
    if (_districts.isNotEmpty)
      landmarks = _districts
          .where((element) => element['id'] == _currentDistrict)
          .first['landmarks'];

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
              controller: _scrollController,
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
                                  _landmarkController.text = '';
                                  _currentLandmark = null;
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
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _landmarkController,
                        decoration: InputDecoration(labelText: 'Ориентир'),
                      ),
                    ),
                    if (landmarks.length > 0)
                      PopupMenuButton(
                        icon: Icon(Icons.arrow_drop_down),
                        onSelected: (value) {
                          _landmarkController.text = landmarks
                              .where((l) => l['id'] == value)
                              .first['title'];
                          setState(() {
                            _currentLandmark = value! as int;
                          });
                        },
                        itemBuilder: (context) {
                          return landmarks
                              .map<PopupMenuItem>((l) => PopupMenuItem(
                                  child: Text(l['title']), value: l['id']))
                              .toList();
                        },
                      )
                  ]),
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
                  ..._phoneFields,
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                AppColors.primaryColor)),
                        onPressed: () {
                          var currentIndex = _phonesIndex;
                          setState(() {
                            FlatPhoneNumberComponent element =
                                FlatPhoneNumberComponent(
                                    Key(currentIndex.toString()), () {
                              _deletePhone(currentIndex);
                            });
                            _phoneFields.add(element);
                          });
                          _phonesIndex++;
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent + 30,
                              duration: Duration(seconds: 1),
                              curve: Curves.fastOutSlowIn);
                        },
                        icon: Icon(Icons.add, color: Colors.black),
                        label: Text(
                          'Добавить номер',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
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
