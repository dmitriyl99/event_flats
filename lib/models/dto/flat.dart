import 'dart:typed_data';

class FlatDto {
  final int? id;
  final int districtId;
  final int? subDistrictId;
  final String? landmark;
  final String? layout;
  final double price;
  final double? publicPrice;
  final String? hashTag1;
  final String? hashTag2;
  final int roomsNumber;
  final int floor;
  final int floorsNumber;
  final String repair;
  final double area;
  final String note;
  final List<String> phones;
  final List<Uint8List>? images;
  final String? ownerName;

  FlatDto(
      this.districtId,
      this.subDistrictId,
      this.landmark,
      this.layout,
      this.price,
      this.publicPrice,
      this.hashTag1,
      this.hashTag2,
      this.roomsNumber,
      this.floor,
      this.floorsNumber,
      this.repair,
      this.area,
      this.note,
      this.phones,
      this.images,
      this.ownerName,
      {this.id});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'district_id': districtId,
        'sub_district_id': subDistrictId,
        'landmark': landmark,
        'layout': layout,
        'area': area,
        'note': note,
        'repair': repair,
        'floor': floor,
        'floors_number': floorsNumber,
        'rooms_number': roomsNumber,
        'owner_name': ownerName,
        'phones': phones,
        'price': price,
        'public_price': publicPrice,
        'hashtag_1': hashTag1,
        'hashtag_2': hashTag2,
      };
}
