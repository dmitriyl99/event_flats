import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FlatPhoneNumberComponent extends StatelessWidget {
  FlatPhoneNumberComponent(Key key, this._onPhoneDelete) : super(key: key);

  final Function _onPhoneDelete;
  TextEditingController _textEditingController = new TextEditingController();

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
