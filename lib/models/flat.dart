class Flat {
  late int id;
  final String address;
  final String? subDistrict;
  final int districtId;
  final int? subDistrictId;
  final double price;
  final double? publicPrice;
  final int floor;
  final String? layout;
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
  final String? hashTag1;
  final String? hashTag2;
  final List<Map<String, dynamic>> photos;

  Flat(
      this.id,
      this.address,
      this.subDistrict,
      this.districtId,
      this.subDistrictId,
      this.price,
      this.publicPrice,
      this.hashTag1,
      this.hashTag2,
      this.floor,
      this.layout,
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
      this.photos,
      {this.ownerName});

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
        publicPrice = json['public_price'] != null ? (json['public_price'] as int).toDouble() : null,
        hashTag1 = json['hashtag_1'],
        hashTag2 = json['hashtag_2'],
        numberOfFloors = json['floors_number'],
        numberOfRooms = json['rooms_number'],
        flatRepair = json['repair'],
        area = json['area'] != null
            ? json['area'] is int
                ? (json['area'] as int).toDouble()
                : json['area']
            : null,
        layout = json['layout'],
        sold = json['sold'] == 1,
        landmark = json['landmark'],
        description = json['note'],
        ownerName = json['owner_name'],
        phones = List<String>.from(json['owner_phones']), // TODO: as array
        isFavorite = json['is_favorite'],
        creatorId = json['creator_id'],
        creatorName = json['creator_name'],
        photos = json['photos'] != null ? json['photos'].map<Map<String, dynamic>>((e) => {'url': e['image_url'], 'watermarked': e['watermarked']}).toList<Map<String, dynamic>>() : <String>[],
        createdAt = DateTime.parse(
          json['created_at'],
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'district_id': districtId,
        'sub_district_id': subDistrictId,
        'landmark': landmark,
        'layout': layout,
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
}
