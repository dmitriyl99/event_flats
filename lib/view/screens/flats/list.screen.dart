import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlatsListScreen extends StatelessWidget {
  static const String route = '/flats';
  const FlatsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: IconButton(onPressed: () {}, icon: Icon(Icons.sort)),
          )
        ],
        title: Text('Event Flats'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xff21B5E1),
        onPressed: () {},
        label: Text(
          'Добавить',
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: ListView(children: [
        Card(
          elevation: 4,
          child: ListTile(
            leading: Image.asset(
              'assets/house.png',
              height: 30,
            ),
            onTap: () {},
            title: Text(
              'Яккасарай 1-2',
              style: TextStyle(fontSize: 18),
            ),
            subtitle: Text('2-4-5'),
            trailing: Column(
              children: [
                Text(
                  'Евро ремонт',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '13.09.2021',
                  style: TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
        ),
        Card(
          elevation: 4,
          child: ListTile(
            leading: Image.asset(
              'assets/house.png',
              height: 30,
            ),
            onTap: () {},
            title: Text(
              'Яккасарай 1-2',
              style: TextStyle(fontSize: 18),
            ),
            subtitle: Text('2-4-5'),
            trailing: Column(
              children: [
                Text(
                  'Евро ремонт',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '13.09.2021',
                  style: TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
        ),
        Card(
          elevation: 4,
          child: ListTile(
            leading: Image.asset(
              'assets/house.png',
              height: 30,
            ),
            onTap: () {},
            title: Text(
              'Яккасарай 1-2',
              style: TextStyle(fontSize: 18),
            ),
            subtitle: Text('2-4-5'),
            trailing: Column(
              children: [
                Text(
                  'Евро ремонт',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '13.09.2021',
                  style: TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
        ),
        Card(
          elevation: 4,
          child: ListTile(
            leading: Image.asset(
              'assets/house.png',
              height: 30,
            ),
            onTap: () {},
            title: Text(
              'Яккасарай 1-2',
              style: TextStyle(fontSize: 18),
            ),
            subtitle: Text('2-4-5'),
            trailing: Column(
              children: [
                Text(
                  'Евро ремонт',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '13.09.2021',
                  style: TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
        ),
        Card(
          elevation: 4,
          child: ListTile(
            leading: Image.asset(
              'assets/house.png',
              height: 30,
            ),
            onTap: () {},
            title: Text(
              'Яккасарай 1-2',
              style: TextStyle(fontSize: 18),
            ),
            subtitle: Text('2-4-5'),
            trailing: Column(
              children: [
                Text(
                  'Евро ремонт',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '13.09.2021',
                  style: TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
