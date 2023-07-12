import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class Flat {
  late int id;
  final String address;
  final String? subDistrict;
  final int districtId;
  final int? subDistrictId;
  final double price;
  final int floor;
  final int numberOfFloors;
  final int numberOfRooms;
  final String flatRepair;
  final bool sold;
  final double? area;
  final String? landmark;
  final String? description;
  final String? ownerName;
  final List<String>? phones;
  bool isFavorite;
  final String creatorName;
  final int creatorId;
  final DateTime createdAt;
  File? image;

  Flat(
      this.id,
      this.address,
      this.subDistrict,
      this.districtId,
      this.subDistrictId,
      this.price,
      this.floor,
      this.numberOfFloors,
      this.numberOfRooms,
      this.flatRepair,
      this.createdAt,
      this.isFavorite,
      this.area,
      this.sold,
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
        subDistrict = json['sub_district'],
        districtId = json['district_id'],
        subDistrictId = json['sub_district_id'],
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
        sold = json['sold'] == 1,
        landmark = json['landmark'],
        description = json['note'],
        ownerName = json['owner_name'],
        phones = List<String>.from(json['owner_phones']), // TODO: as array
        isFavorite = json['is_favorite'],
        creatorId = json['creator_id'],
        creatorName = json['creator_name'],
        createdAt = DateTime.parse(
          json['created_at'],
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'district_id': districtId,
        'sub_district_id': subDistrictId,
        'landmark': landmark,
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

  Future<List<Future<String>>> get photos async {
    var files = await FirebaseStorage.instance
        .ref()
        .child('flats')
        .child(this.id.toString() + '/')
        .listAll();
    List<Future<String>> downloadUrls = [];
    files.items.forEach((element) {
      downloadUrls.add(element.getDownloadURL());
    });
    return downloadUrls;
  }
}
