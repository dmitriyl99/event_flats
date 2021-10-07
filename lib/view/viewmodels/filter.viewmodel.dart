class FilterViewModel {
  final String? district;
  final int? rooms;
  final int? roomsStart;
  final int? roomsEnd;
  final double? priceFrom;
  final double? priceTo;
  final String? repair;
  final double? area;
  final int? floor;
  final bool sortPriceDown;
  final bool sortPriceUp;
  final bool sortDistrict;
  final bool sortDate;
  final bool? favorite;
  final bool? personal;

  FilterViewModel(
      {this.district,
      this.rooms,
      this.priceFrom,
      this.priceTo,
      this.floor,
      this.repair,
      this.area,
      this.roomsStart,
      this.roomsEnd,
      this.favorite,
      this.personal,
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
    return {
      'district': district,
      'repair': repair,
      'area': area,
      'floor': floor,
      'is_favorite': favorite,
      'personal': personal,
      'rooms_start': roomsStart,
      'rooms_end': roomsEnd,
      'price_start': priceFrom,
      'price_end': priceTo,
      'order_by': sortString
    };
  }
}
