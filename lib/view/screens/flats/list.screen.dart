import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/view/components/flats_list.component.dart';
import 'package:event_flats/view/viewmodels/filter.viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'filter.screen.dart';

class FlatsListScreen extends StatefulWidget {
  final FlatsRepository _flatsRepository;
  final AuthenticationService _authenticationService;

  const FlatsListScreen(this._flatsRepository, this._authenticationService,
      {Key? key})
      : super(key: key);

  @override
  State<FlatsListScreen> createState() => _FlatsListScreenState();
}

class _FlatsListScreenState extends State<FlatsListScreen> {
  FilterViewModel? _filter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: () async {
                var filter = await Navigator.of(context).pushNamed(
                    FilterScreen.route,
                    arguments: {'currentFilter': _filter});
                if (filter == null) return;
                setState(() {
                  this._filter = filter as FilterViewModel;
                });
              },
              icon: Image.asset('assets/filter_white.png'),
              iconSize: 32,
            ),
          )
        ],
        title: Text('Event Flats'),
        centerTitle: true,
      ),
      body: FlatsListComponent(
          widget._flatsRepository.getFlats(filter: _filter),
          widget._flatsRepository,
          widget._authenticationService),
    );
  }
}
