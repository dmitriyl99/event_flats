import 'package:flutter/material.dart';

class FlatsFavoritesListScreen extends StatefulWidget {
  const FlatsFavoritesListScreen({Key? key}) : super(key: key);

  @override
  _FlatsFavoritesListScreenState createState() =>
      _FlatsFavoritesListScreenState();
}

class _FlatsFavoritesListScreenState extends State<FlatsFavoritesListScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Icon(Icons.favorite),
      ),
    );
  }
}
