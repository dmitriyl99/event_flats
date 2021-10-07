import 'package:event_flats/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer(this._user, {Key? key}) : super(key: key);
  final User _user;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xff00d6d1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user.displayName,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                Text(_user.email, style: TextStyle(color: Colors.black54))
              ],
            ),
          ),
          if (_user.isAdmin)
            ListTile(
              leading: Icon(CupertinoIcons.person_2_fill),
              title: const Text('Сотрудники'),
              onTap: () {},
            ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: const Text('Выход'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}
