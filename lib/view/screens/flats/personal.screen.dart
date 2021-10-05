import 'package:flutter/material.dart';

class FlatsPersonalListScreen extends StatefulWidget {
  const FlatsPersonalListScreen({Key? key}) : super(key: key);

  @override
  _FlatsPersonalListScreenState createState() =>
      _FlatsPersonalListScreenState();
}

class _FlatsPersonalListScreenState extends State<FlatsPersonalListScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Icon(Icons.person),
      ),
    );
  }
}
