import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class Flat {
  late String id;
  final String address;
  final int districtId;
  final int? landmarkId;
  final double price;
  final int floor;
  final int numberOfFloors;
  final int numberOfRooms;
  final String flatRepair;
  final double? area;
  final String landmark;
  final String? description;
  final String? ownerName;
  final List<String>? phones;
  final bool isFavorite;
  final String creatorName;
  final int creatorId;
  final DateTime createdAt;
  File? image;

  Flat(
      this.id,
      this.address,
      this.districtId,
      this.landmarkId,
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
      this.phones,
      this.creatorId,
      this.creatorName,
      {this.ownerName,
      this.image});

  Flat.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        address = json['address'],
        districtId = json['district_id'],
        landmarkId = json['landmark_id'],
        price = json['price'] is int
            ? (json['price'] as int).toDouble()
            : json['price'],
        floor = json['floor'],
        numberOfFloors = json['floors_number'],
        numberOfRooms = json['rooms_number'],
        flatRepair = json['repair'],
        area = json['area'] != null
            ? json['area'] is int
                ? (json['area'] as int).toDouble()
                : json['area']
            : null,
        landmark = json['landmark'],
        description = json['note'],
        ownerName = json['owner_name'],
        phones = json['phones'], // TODO: as array
        isFavorite = json['is_favorite'],
        creatorId = json['creator_id'],
        creatorName = json['creator_name'],
        createdAt = DateTime.parse(
          json['createdAt'],
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'district_id': districtId,
        'landmark': landmarkId ?? landmark,
        'area': area,
        'note': description,
        'repair': flatRepair,
        'floor': floor,
        'floor_number': numberOfFloors,
        'rooms_number': numberOfRooms,
        'owner_name': ownerName,
        'phones': phones,
        'price': price
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
