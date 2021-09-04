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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      body: ListView(children: [
        Card(
          elevation: 4,
          child: ListTile(
            leading: Icon(Icons.home),
            onTap: () {},
            title: Text('Яккасарай 1-2'),
            subtitle: Text('13000'),
            trailing: Text('2-4-5'),
          ),
        ),
        Card(
          elevation: 4,
          child: ListTile(
            leading: Icon(Icons.home),
            onTap: () {},
            title: Text('Яккасарай 1-2'),
            subtitle: Text('13000'),
            trailing: Text('2-4-5'),
          ),
        ),
        Card(
          elevation: 4,
          child: ListTile(
            leading: Icon(Icons.home),
            onTap: () {},
            title: Text('Яккасарай 1-2'),
            subtitle: Text('13000'),
            trailing: Text('2-4-5'),
          ),
        ),
        Card(
          elevation: 4,
          child: ListTile(
            leading: Icon(Icons.home),
            onTap: () {},
            title: Text('Яккасарай 1-2'),
            subtitle: Text('13000'),
            trailing: Text('2-4-5'),
          ),
        ),
        Card(
          elevation: 4,
          child: ListTile(
            leading: Icon(Icons.home),
            onTap: () {},
            title: Text('Яккасарай 1-2'),
            subtitle: Text('13000'),
            trailing: Text('2-4-5'),
          ),
        ),
        Card(
          elevation: 4,
          child: ListTile(
            leading: Icon(Icons.home),
            onTap: () {},
            title: Text('Яккасарай 1-2'),
            subtitle: Text('13000'),
            trailing: Text('2-4-5'),
          ),
        ),
      ]),
    );
  }
}
