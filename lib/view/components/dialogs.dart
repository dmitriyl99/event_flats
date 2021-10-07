import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AlertDialog buildNoInternetDialog(BuildContext context) {
  return AlertDialog(
      title: Text('Ошибка соединения'),
      content: Container(
        height: 100,
        child: Column(
          children: [
            Icon(
              Icons.wifi_off,
              size: 48,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Проверьте, включён ли интернет',
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Ок', style: TextStyle(fontSize: 16)),
        )
      ]);
}

AlertDialog buildAuthorizationErrorDialog(
    BuildContext context, AuthenticationFailed ex) {
  return AlertDialog(
      title: Text('Ошибка авторизации'),
      content: Container(
        height: 100,
        child: Column(
          children: [
            Icon(
              Icons.person_off,
              size: 48,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              ex.getMessage(),
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Ок', style: TextStyle(fontSize: 16)),
        )
      ]);
}

AlertDialog buildServerErrorDialog(BuildContext context) {
  return AlertDialog(
      title: Text('Ошибка авторизации'),
      content: Container(
        height: 100,
        child: Column(
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Ошибка сервера',
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Ок', style: TextStyle(fontSize: 16)),
        )
      ]);
}
