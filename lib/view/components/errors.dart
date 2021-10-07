import 'package:event_flats/view/resources/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildNoInternetError({VoidCallback? onRefresh}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.wifi_off, size: 42),
        SizedBox(
          height: 20,
        ),
        Text(
          'Севрер недоступен. Или проверьте ваше интернет-соединение',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 21),
        ),
        if (onRefresh != null) _buildOnRefreshButton(onRefresh)
      ],
    ),
  );
}

Widget buildDefaultError({VoidCallback? onRefresh}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '🧐',
          style: TextStyle(fontSize: 42),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          'Что-то пошло не так...',
          style: TextStyle(fontSize: 21),
        ),
        if (onRefresh != null) _buildOnRefreshButton(onRefresh)
      ],
    ),
  );
}

Widget buildServerError({VoidCallback? onRefresh}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.xmark_octagon,
          color: Colors.red,
          size: 42,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          'Oops.. Ошибка сервера',
          style: TextStyle(fontSize: 21),
        ),
        if (onRefresh != null) _buildOnRefreshButton(onRefresh)
      ],
    ),
  );
}

Widget _buildOnRefreshButton(VoidCallback onRefresh) {
  return Column(
    children: [
      SizedBox(
        height: 20,
      ),
      ElevatedButton.icon(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(AppColors.primaryColor)),
          onPressed: onRefresh,
          icon: Icon(
            Icons.refresh,
            size: 32,
            color: Colors.black,
          ),
          label: Text(
            'Обновить',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ))
    ],
  );
}
