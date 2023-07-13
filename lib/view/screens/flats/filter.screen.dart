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
  late int _currentDistrict = 0;
  int? _currentSubDistrict;
  late String _currentRepair = _repairs[0];
  List<Map<String, dynamic>> _districts = [
    {'id': 0, 'title': 'Все районы'}
  ];
  List<String> _repairs = ['Все ремонты', ...getRepairs()];
  bool _firstLoaded = false;

  double? _priceFrom;
  double? _priceTo;
  int? _roomsFrom;
  int? _roomsTo;
  int? _floorsFrom;
  int? _floorsTo;

  bool _nameSort = false;
  bool _priceUpSort = false;
  bool _priceDownSort = false;
  bool _dateSort = false;
  FilterViewModel? _currentFilter;

  TextEditingController _fromPriceController = new TextEditingController();
  TextEditingController _toPriceController = new TextEditingController();
  TextEditingController _floorController = new TextEditingController();
  TextEditingController _fromRoomsController = new TextEditingController();
  TextEditingController _toRoomsController = new TextEditingController();
  TextEditingController _fromFloorsController = new TextEditingController();
  TextEditingController _toFloorsController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _fromPriceController.addListener(() {
      _priceFrom = double.tryParse(_fromPriceController.text);
    });
    _toPriceController.addListener(() {
      _priceTo = double.tryParse(_toPriceController.text);
    });

    _fromRoomsController.addListener(() {
      _roomsFrom = int.tryParse(_fromRoomsController.text);
    });
    _toRoomsController.addListener(() {
      _roomsTo = int.tryParse(_toRoomsController.text);
    });

    _fromFloorsController.addListener(() {
      _floorsFrom = int.tryParse(_fromFloorsController.text);
    });
    _toFloorsController.addListener(() {
      _floorsTo = int.tryParse(_toFloorsController.text);
    });

    getDistricts().then((value) {
      Future.delayed(Duration.zero, () {
        if (mounted)
          setState(() {
            _districts += value;
            if (_currentFilter != null) {
              _currentDistrict = _currentFilter?.district ?? 0;
            }
          });
      });
    });
  }

  @override
  void dispose() {
    _fromPriceController.dispose();
    _toPriceController.dispose();
    _floorController.dispose();
    _fromRoomsController.dispose();
    _toRoomsController.dispose();
    _fromFloorsController.dispose();
    _toFloorsController.dispose();
    super.dispose();
  }

  Widget _districtFilter() {
    return FormField<int>(
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
                      _currentSubDistrict = null;
                    });
                  },
                  items: _districts
                      .map<DropdownMenuItem<int>>((value) => DropdownMenuItem(
                            value: value['id'],
                            child: Text(value['title']),
                          ))
                      .toList()),
            ),
          );
        });
  }

  Widget _subDistrictFilter() {
    return FormField<int?>(
        enabled: _districts.isNotEmpty,
        builder: (FormFieldState<int?> state) {
          var currentDistrictEntity = _districts
              .where(
                  (element) => element['id'] == _currentDistrict)
              .first;
          var subDistricts =
              currentDistrictEntity['sub_districts'] ?? [];
          return InputDecorator(
            decoration: InputDecoration(labelText: "Доп район"),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
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
                      .toList()),
            ),
          );
        }
    );
  }

  Widget _roomsFilter() {
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
            child: TextFormField(
              controller: _fromRoomsController,
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
              controller: _toRoomsController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'До'),
            ),
          ),
        ]);
  }

  Widget _floorsFilter() {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Этаж:',
            style: TextStyle(fontSize: 21),
          ),
          SizedBox(
            width: 24,
          ),
          Expanded(
            child: TextFormField(
              controller: _fromFloorsController,
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
              controller: _toFloorsController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'До'),
            ),
          ),
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
                        _priceUpSort = false;
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
                        _priceDownSort = false;
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

  Widget _resetButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(AppColors.primaryColor)),
            onPressed: () {
              setState(() {
                _currentDistrict = 0;
                _currentSubDistrict = null;
                _fromPriceController.text = '';
                _toPriceController.text = '';
                _fromRoomsController.text = '';
                _toRoomsController.text = '';
                _fromFloorsController.text = '';
                _toFloorsController.text = '';
                _currentRepair = _repairs[0];
                _dateSort = false;
                _priceDownSort = false;
                _priceUpSort = false;
                _nameSort = false;
              });
            },
            child: Text(
              'Сбросить',
              style: TextStyle(fontSize: 18, color: Colors.white),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    FilterViewModel? currentFilter = args['currentFilter'];
    this._currentFilter = currentFilter;

    if (!_firstLoaded) {
      if (currentFilter != null) {
        if (_districts.length > 1) {
          _currentDistrict = currentFilter.district ?? 0;
          _currentSubDistrict = currentFilter.subDistrict;
        }
        _currentRepair = currentFilter.repair ?? _repairs[0];
        _fromPriceController.text =
            currentFilter.priceFrom?.toStringAsFixed(0) ?? '';
        _toPriceController.text =
            currentFilter.priceTo?.toStringAsFixed(0) ?? '';
        _fromRoomsController.text = currentFilter.roomsStart?.toString() ?? '';
        _toRoomsController.text = currentFilter.roomsEnd?.toString() ?? '';
        _fromFloorsController.text =
            currentFilter.floorsStart?.toString() ?? '';
        _toFloorsController.text = currentFilter.floorsEnd?.toString() ?? '';
        _dateSort = currentFilter.sortDate;
        _priceUpSort = currentFilter.sortPriceUp;
        _priceDownSort = currentFilter.sortPriceDown;
        _nameSort = currentFilter.sortDistrict;
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
                    district: _currentDistrict == 0 ? null : _currentDistrict,
                    subDistrict: _currentSubDistrict,
                    roomsStart: _roomsFrom,
                    roomsEnd: _roomsTo,
                    priceFrom: _priceFrom,
                    priceTo: _priceTo,
                    repair:
                        _currentRepair == _repairs[0] ? null : _currentRepair,
                    floorsStart: _floorsFrom,
                    floorsEnd: _floorsTo,
                    sortPriceDown: _priceDownSort,
                    sortPriceUp: _priceUpSort,
                    sortDistrict: _nameSort,
                    sortDate: _dateSort,
                    favorite: currentFilter?.favorite,
                    personal: currentFilter?.personal);
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
              if (_districts.isNotEmpty && _districts
                  .where((element) => element['id'] == _currentDistrict)
                  .first['sub_districts'] !=
                  null)
                _subDistrictFilter(),
              if (_districts.isNotEmpty && _districts
                  .where((element) => element['id'] == _currentDistrict)
                  .first['sub_districts'] !=
                  null)
                SizedBox(
                  height: 32,
                ),
              _roomsFilter(),
              SizedBox(
                height: 32,
              ),
              _floorsFilter(),
              SizedBox(
                height: 32,
              ),
              _priceFilter(),
              _repairFilter(),
              SizedBox(
                height: 32,
              ),
              _sortFilter(),
              SizedBox(
                height: 32,
              ),
              _resetButton()
            ],
          ),
        ),
      ),
    );
  }
}
