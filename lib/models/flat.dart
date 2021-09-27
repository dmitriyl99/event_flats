import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class Flat {
  late String id;
  final String address;
  final double price;
  final int floor;
  final int numberOfFloors;
  final int numberOfRooms;
  final String flatRepair;
  final double? area;
  final String landmark;
  final String? description;
  final String? ownerName;
  final String ownerPhone;
  final bool isFavorite;
  final DateTime createdAt;
  File? image;

  Flat(
      this.address,
      this.price,
      this.floor,
      this.numberOfFloors,
      this.numberOfRooms,
      this.flatRepair,
      this.createdAt,
      this.isFavorite,
      this.area,
      this.description,
      this.landmark,
      this.ownerPhone,
      {this.ownerName,
      this.image});

  Flat.fromJson(Map<String, dynamic> json)
      : address = json['address'],
        price = json['price'] is int
            ? (json['price'] as int).toDouble()
            : json['price'],
        floor = json['floor'],
        numberOfFloors = json['numberOfFloors'],
        numberOfRooms = json['numberOfRooms'],
        flatRepair = json['flatRepair'],
        area = json['area'] != null
            ? json['area'] is int
                ? (json['area'] as int).toDouble()
                : json['area']
            : null,
        landmark = json['landmark'],
        description = json['description'],
        ownerName = json['ownerName'],
        ownerPhone = json['ownerPhone'],
        isFavorite = json['isFavorite'],
        createdAt = DateTime.parse(
          json['createdAt'],
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'address': address,
        'price': price,
        'floor': floor,
        'numberOfFloors': numberOfFloors,
        'numberOfRooms': numberOfRooms,
        'flatRepair': flatRepair,
        'area': area,
        'landmark': landmark,
        'description': description,
        'ownerName': ownerName,
        'ownerPhone': ownerPhone,
        'isFavorite': isFavorite,
        'createdAt': createdAt.toString(),
      };

  Future<String> get photo async {
    var downloadUrl = await FirebaseStorage.instance
        .ref()
        .child('flats')
        .child(this.id)
        .getDownloadURL();
    return downloadUrl;
  }
}
