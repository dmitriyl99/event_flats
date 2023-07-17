import 'dart:typed_data';

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

  List<Uint8List> _images = [];

  late int _currentDistrict = 0;
  int? _currentSubDistrict;
  String? _currentLayout;
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
  TextEditingController _publicPriceController = new TextEditingController();

  final ImagePicker _picker = ImagePicker();
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
          _currentSubDistrict,
          _landmarkController.text,
          _currentLayout,
          double.parse(_priceController.text.replaceAll(',', '')),
          _publicPriceController.text.isNotEmpty ? double.parse(_publicPriceController.text) : null,
          null,
          null,
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
      _currentSubDistrict = flat.subDistrictId;
      _currentRepair = flat.flatRepair;
      _currentLayout = flat.layout;
      _landmarkController.text = flat.landmark ?? '';
      _priceController.text = NumberFormattingHelper.format(flat.price);
      if (flat.publicPrice != null) {
        _publicPriceController.text = NumberFormattingHelper.format(flat.publicPrice!);
      }
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
                                dropdownColor: AppColors.darkBackground,
                                value: _currentDistrict,
                                isDense: true,
                                onChanged: (value) {
                                  setState(() {
                                    _currentDistrict = value!;
                                    _currentSubDistrict = null;
                                  });
                                  _landmarkController.text = '';
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
                  if (_districts.isNotEmpty && _districts
                      .where((element) => element['id'] == _currentDistrict)
                      .first['sub_districts'] !=
                      null)
                    FormField<int?>(
                      enabled: _districts.isNotEmpty,
                      builder: (FormFieldState<int?> state) {
                        var currentDistrictEntity = _districts
                            .where(
                                (element) => element['id'] == _currentDistrict)
                            .first;
                        var subDistricts =
                            currentDistrictEntity['sub_districts'] ?? [];

                        return InputDecorator(
                          decoration: InputDecoration(
                              labelText: 'Дополнительный район'),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              dropdownColor: AppColors.darkBackground,
                              value: _currentSubDistrict,
                              isDense: true,
                              onChanged: (value) {
                                setState(() {
                                  _currentSubDistrict = value;
                                });
                              },
                              items: subDistricts
                                  .map<DropdownMenuItem<int?>>((e) =>
                                  DropdownMenuItem<int?>(
                                      value: e['id'],
                                      child: Text(e['title'])))
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _landmarkController,
                        decoration: InputDecoration(labelText: 'Ориентир'),
                      ),
                    ),
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
                  TextFormField(
                    controller: _publicPriceController,
                    keyboardType: TextInputType.number,
                    decoration:
                    InputDecoration(labelText: 'Публичная цена', prefixText: '\$'),
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
                            dropdownColor: AppColors.darkBackground,
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
                  FormField<String?>(builder: (FormFieldState<String?> state) {
                    return InputDecorator(
                      decoration: InputDecoration(labelText: "Планировка"),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                            dropdownColor: AppColors.darkBackground,
                            value: _currentLayout,
                            onChanged: (value) {
                              setState(() {
                                _currentLayout = value;
                              });
                            },
                            items: [
                              DropdownMenuItem(value: 'Свердловская', child: Text('Свердловская')),
                              DropdownMenuItem(value: 'Французская', child: Text('Французская')),
                              DropdownMenuItem(value: 'Московская', child: Text('Московская')),
                              DropdownMenuItem(value: 'Хрущевская', child: Text('Хрущевская')),
                              DropdownMenuItem(value: 'Улучшенная', child: Text('Улучшенная')),
                              DropdownMenuItem(value: 'Другая', child: Text('Другая')),
                            ]),
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
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      Text(
                        'Изображение',
                        style: TextStyle(fontSize: 21),
                      ),
                      if (_images.isNotEmpty)
                        Column(
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                                height: 100,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: _images
                                      .map<Widget>((e) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Image.memory(e),
                                          ))
                                      .toList(),
                                ))
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
                                    source: ImageSource.camera,
                                    imageQuality: 60);
                                if (image != null) {
                                  setState(() async {
                                    _images.clear();
                                    _images.add(await image.readAsBytes());
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                child: Text('С камеры',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
                              )),
                          SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      AppColors.primaryColor)),
                              onPressed: () async {
                                final List<XFile>? images = await _picker
                                    .pickMultiImage(imageQuality: 60);
                                if (images != null) {
                                  setState(() {
                                    images.forEach((element) async {
                                      _images.add(await element.readAsBytes());
                                    });
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                child: Text('С устройства',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
                              ))
                        ],
                      )
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
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Добавить номер',
                          style: TextStyle(color: Colors.white),
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
