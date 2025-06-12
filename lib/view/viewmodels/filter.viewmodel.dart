class FilterViewModel {
  final int? district;
  final int? subDistrict;
  final int? roomsStart;
  final int? roomsEnd;
  final int? floorsStart;
  final int? floorsEnd;
  final double? priceFrom;
  final double? priceTo;
  final String? repair;
  final String? layout;
  final double? area;
  final bool? hasMorgage;
  final bool sortPriceDown;
  final bool sortPriceUp;
  final bool sortDistrict;
  final bool sortDate;
  final bool? favorite;
  final bool? personal;
  final int? creatorId;

  FilterViewModel(
      {this.district,
      this.subDistrict,
      this.priceFrom,
      this.priceTo,
      this.repair,
      this.layout,
      this.area,
      this.hasMorgage,
      this.roomsStart,
      this.roomsEnd,
      this.floorsStart,
      this.floorsEnd,
      this.favorite,
      this.personal,
      this.creatorId,
      this.sortPriceDown = false,
      this.sortPriceUp = false,
      this.sortDistrict = false,
      this.sortDate = false});

  Map<String, dynamic> toMap() {
    String sortString = '';
    if (sortPriceDown) {
      sortString += 'price:desc;';
    }
    if (sortPriceUp) {
      sortString += 'price:asc;';
    }
    if (sortDistrict) {
      sortString += 'district:asc;';
    }
    if (sortDate) {
      sortString += 'created_at:desc;';
    }
    String _hasMorgage = '';
    if (hasMorgage != null) {
      _hasMorgage = hasMorgage == true ? '1' : '0';
    }
    return {
      'district': district,
      'sub_district': subDistrict,
      'repair': repair,
      'layout': layout,
      'area': area,
      'has_morgage': _hasMorgage,
      'is_favorite': favorite,
      'personal': personal,
      'creator_id': creatorId,
      'rooms_start': roomsStart,
      'rooms_end': roomsEnd,
      'floor_start': floorsStart,
      'floor_end': floorsEnd,
      'price_start': priceFrom,
      'price_end': priceTo,
      'order_by': sortString
    };
  }
}
