import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:event_flats/services/exceptions/forbidden_exception.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AlertDialog buildNoInternetDialog(BuildContext context) {
  return AlertDialog(
      title: Text(
        'Ошибка соединения',
        textAlign: TextAlign.center,
      ),
      content: Container(
        height: 140,
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
              'Нет связи с сервером. Проверьте, включён ли интернет',
              textAlign: TextAlign.center,
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
      title: Text('Ошибка авторизации', textAlign: TextAlign.center),
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
            Text(ex.getMessage(),
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center)
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
      title: Text('Ошибка сервера', textAlign: TextAlign.center),
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
            Text('Opps..',
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center)
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

AlertDialog buildValidationError(BuildContext context) {
  return AlertDialog(
      title: Text('Ошибка валидации', textAlign: TextAlign.center),
      content: Container(
        height: 150,
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
            ),
            SizedBox(
              height: 20,
            ),
            Text('Проверьте, все ли поля заполнены правильно',
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center)
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

AlertDialog buildForbiddenError(BuildContext context, ForbiddenException ex) {
  return AlertDialog(
      title: Text('Ошибка авторизации', textAlign: TextAlign.center),
      content: Container(
        height: 150,
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
            ),
            SizedBox(
              height: 20,
            ),
            Text(ex.message,
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center)
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
