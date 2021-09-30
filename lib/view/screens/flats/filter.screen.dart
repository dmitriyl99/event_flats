import 'package:event_flats/services/districts.dart';
import 'package:event_flats/services/repairs.dart';
import 'package:event_flats/view/resources/colors.dart';
import 'package:event_flats/view/viewmodels/filter.viewmodel.dart';
import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  static const String route = '/flats/filter';

  const FilterScreen({Key? key}) : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late String _currentDistrict = _districts[0];
  late String _currentRepair = _repairs[0];
  List<String> _districts = ['Все районы', ...getDistricts()];
  List<String> _repairs = ['Все ремонты', ...getRepairs()];
  List<String> _roomsList = ['Все', '1', '2', '3', '4', '5', '6', '7'];
  late String _rooms = _roomsList[0];
  bool _firstLoaded = false;

  double? _priceFrom;
  double? _priceTo;

  bool _nameSort = false;
  bool _priceUpSort = false;
  bool _priceDownSort = false;
  bool _dateSort = false;

  TextEditingController _fromPriceController = new TextEditingController();
  TextEditingController _toPriceController = new TextEditingController();
  TextEditingController _floorController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _fromPriceController.addListener(() {
      _priceFrom = double.tryParse(_fromPriceController.text);
      if (_fromPriceController.text.isEmpty) return;
      setState(() {
        _nameSort = false;
        _dateSort = false;
      });
    });
    _toPriceController.addListener(() {
      _priceTo = double.tryParse(_toPriceController.text);
      if (_toPriceController.text.isEmpty) return;
      setState(() {
        _nameSort = false;
        _dateSort = false;
      });
    });
  }

  @override
  void dispose() {
    _fromPriceController.dispose();
    _toPriceController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  Widget _districtFilter() {
    return FormField<String>(builder: (FormFieldState<String> state) {
      return InputDecorator(
        decoration: InputDecoration(labelText: "Район"),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
              value: _currentDistrict,
              isDense: true,
              onChanged: (value) {
                setState(() {
                  _currentDistrict = value!;
                  _nameSort = false;
                });
              },
              items: _districts
                  .map<DropdownMenuItem<String>>((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList()),
        ),
      );
    });
  }

  Widget _roomsFloorFilter() {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Комнат:',
            style: TextStyle(fontSize: 21),
          ),
          SizedBox(
            width: 24,
          ),
          Expanded(
            child: FormField<String>(builder: (FormFieldState<String> state) {
              return InputDecorator(
                decoration: InputDecoration(),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                      value: _rooms,
                      isDense: true,
                      onChanged: (value) {
                        setState(() {
                          _rooms = value!;
                        });
                      },
                      items: _roomsList
                          .map<DropdownMenuItem<String>>(
                              (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ))
                          .toList()),
                ),
              );
            }),
          ),
          SizedBox(
            width: 24,
          ),
          Text(
            'Этаж:',
            style: TextStyle(fontSize: 21),
          ),
          SizedBox(
            width: 24,
          ),
          Expanded(
            child: TextField(
              controller: _floorController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
          )
        ]);
  }

  Widget _priceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Цена за квартиру у.е:',
          style: TextStyle(fontSize: 21),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextFormField(
                controller: _fromPriceController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'От'),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              '-',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextFormField(
                controller: _toPriceController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'До'),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget _repairFilter() {
    return FormField<String>(builder: (FormFieldState<String> state) {
      return InputDecorator(
        decoration: InputDecoration(labelText: "Ремонт"),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
              value: _currentRepair,
              isDense: true,
              onChanged: (value) {
                setState(() {
                  _currentRepair = value!;
                });
              },
              items: _repairs
                  .map<DropdownMenuItem<String>>((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList()),
        ),
      );
    });
  }

  Widget _sortFilter() {
    var textStyle = TextStyle(fontSize: 18);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Сортировать по:', style: TextStyle(fontSize: 18)),
        SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                FilterChip(
                    showCheckmark: false,
                    selectedColor: AppColors.primaryColor,
                    label: Text('Самые дорогие', style: textStyle),
                    selected: _priceDownSort,
                    onSelected: (bool value) {
                      setState(() {
                        _priceDownSort = value;
                      });
                    }),
                FilterChip(
                    showCheckmark: false,
                    selectedColor: AppColors.primaryColor,
                    label: Text('Районам', style: textStyle),
                    selected: _nameSort,
                    onSelected: (bool value) {
                      setState(() {
                        _nameSort = value;
                        _fromPriceController.text = '';
                        _toPriceController.text = '';
                        _currentDistrict = _districts[0];
                      });
                    }),
              ],
            ),
            SizedBox(
              width: 30,
            ),
            Column(
              children: [
                FilterChip(
                    showCheckmark: false,
                    selectedColor: AppColors.primaryColor,
                    label: Text('Самые дешёвые', style: textStyle),
                    selected: _priceUpSort,
                    onSelected: (bool value) {
                      setState(() {
                        _priceUpSort = value;
                      });
                    }),
                FilterChip(
                    showCheckmark: false,
                    selectedColor: AppColors.primaryColor,
                    label: Text('Самые новые', style: textStyle),
                    selected: _dateSort,
                    onSelected: (bool value) {
                      setState(() {
                        _dateSort = value;
                        _fromPriceController.text = '';
                        _toPriceController.text = '';
                      });
                    }),
              ],
            )
          ],
        ),
        Wrap(
          spacing: 30.0,
          children: [],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    FilterViewModel? currentFilter = args['currentFilter'];

    if (!_firstLoaded) {
      if (currentFilter != null) {
        _currentDistrict = currentFilter.district ?? _districts[0];
        _currentRepair = currentFilter.repair ?? _repairs[0];
        _fromPriceController.text = currentFilter.priceFrom != null
            ? currentFilter.priceFrom!.toStringAsFixed(0)
            : '';
        _toPriceController.text = currentFilter.priceTo != null
            ? currentFilter.priceTo!.toStringAsFixed(0)
            : '';
        _rooms = currentFilter.rooms != null
            ? currentFilter.rooms.toString()
            : _roomsList[0];
        _dateSort = currentFilter.sortDate;
        _priceUpSort = currentFilter.sortPriceUp;
        _priceDownSort = currentFilter.sortPriceDown;
        _nameSort = currentFilter.sortDistrict;
        _floorController.text =
            currentFilter.floor != null ? currentFilter.floor.toString() : '';
      }
      _firstLoaded = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Фильтр'),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.check),
              iconSize: 32,
              onPressed: () {
                var viewModel = FilterViewModel(
                    district: _currentDistrict == _districts[0]
                        ? null
                        : _currentDistrict,
                    rooms: _rooms == _roomsList[0] ? null : int.parse(_rooms),
                    priceFrom: _priceFrom,
                    priceTo: _priceTo,
                    repair:
                        _currentRepair == _repairs[0] ? null : _currentRepair,
                    floor: int.tryParse(_floorController.text),
                    sortPriceDown: _priceDownSort,
                    sortPriceUp: _priceUpSort,
                    sortDistrict: _nameSort,
                    sortDate: _dateSort);
                Navigator.of(context).pop(viewModel);
              },
            ),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _districtFilter(),
              SizedBox(
                height: 32,
              ),
              _roomsFloorFilter(),
              SizedBox(
                height: 32,
              ),
              _priceFilter(),
              _repairFilter(),
              SizedBox(
                height: 32,
              ),
              _sortFilter()
            ],
          ),
        ),
      ),
    );
  }
}
