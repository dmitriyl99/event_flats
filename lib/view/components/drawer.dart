import 'package:event_flats/services/authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer(this._authenticationService, {Key? key}) : super(key: key);
  final AuthenticationService _authenticationService;

  void _onLogout(BuildContext context) async {
    await _authenticationService.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var user = _authenticationService.getUser()!;
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
                  user.displayName,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                Text(user.email, style: TextStyle(color: Colors.black54))
              ],
            ),
          ),
          if (user.isAdmin)
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
              _onLogout(context);
            },
          ),
        ],
      ),
    );
  }
}
