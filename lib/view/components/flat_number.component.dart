import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FlatPhoneNumberComponent extends StatelessWidget {
  String? initialValue;
  FlatPhoneNumberComponent(Key key, this._onPhoneDelete, {String? initialValue})
      : super(key: key) {
    _textEditingController = new TextEditingController();
    if (initialValue != null) _textEditingController.text = initialValue;
  }

  final Function _onPhoneDelete;
  late TextEditingController _textEditingController;

  String getPhone() {
    return _textEditingController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Expanded(
        child: TextFormField(
          controller: _textEditingController,
          keyboardType: TextInputType.phone,
        ),
      ),
      IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          _onPhoneDelete();
        },
        color: Colors.red,
      )
    ]);
    ;
  }
}
