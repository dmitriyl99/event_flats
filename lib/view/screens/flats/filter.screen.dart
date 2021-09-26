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
  List<String> _fromRooms = ['От', '1', '2', '3', '4', '5', '6', '7'];
  List<String> _toRooms = ['До', '1', '2', '3', '4', '5', '6', '7'];
  late String _roomStart = _fromRooms[0];
  late String _roomEnd = _toRooms[0];
  bool _firstLoaded = false;
  RangeValues _priceValues = RangeValues(0, 100000);
  bool _nameSort = false;
  bool _priceUpSort = false;
  bool _priceDownSort = false;
  bool _dateSort = false;

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

  Widget _roomsFilter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Комнат:',
          style: TextStyle(fontSize: 21),
        ),
        SizedBox(
          width: 50,
        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child:
                    FormField<String>(builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                          value: _roomStart,
                          isDense: true,
                          onChanged: (value) {
                            setState(() {
                              _roomStart = value!;
                            });
                          },
                          items: _fromRooms
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
                width: 20,
              ),
              Expanded(
                child:
                    FormField<String>(builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                          value: _roomEnd,
                          isDense: true,
                          onChanged: (value) {
                            setState(() {
                              _roomEnd = value!;
                            });
                          },
                          items: _toRooms
                              .map<DropdownMenuItem<String>>(
                                  (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ))
                              .toList()),
                    ),
                  );
                }),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _priceFilter(double flatMaxPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Цена за квартиру у.е: ${_priceValues.start.toStringAsFixed(0)} - ${_priceValues.end.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 21),
        ),
        SizedBox(
          height: 16,
        ),
        RangeSlider(
            activeColor: AppColors.primaryColor,
            divisions: flatMaxPrice ~/ 100,
            min: 0,
            max: flatMaxPrice,
            values: _priceValues,
            onChanged: (values) {
              setState(() {
                _priceValues = values;
              });
            })
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
    double maxPrice = args['maxPrice'];
    if (!_firstLoaded) {
      _priceValues = RangeValues(0, maxPrice);
      _firstLoaded = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Фильтр'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.check),
              iconSize: 32,
              onPressed: () {
                var viewModel = FilterViewModel(
                    _currentDistrict == _districts[0] ? null : _currentDistrict,
                    _roomStart == _fromRooms[0] ? null : int.parse(_roomStart),
                    _roomEnd == _toRooms[0] ? null : int.parse(_roomEnd),
                    _priceValues.start,
                    _priceValues.end,
                    _currentRepair == _repairs[0] ? null : _currentRepair,
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
              _roomsFilter(),
              SizedBox(
                height: 32,
              ),
              _priceFilter(maxPrice),
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
