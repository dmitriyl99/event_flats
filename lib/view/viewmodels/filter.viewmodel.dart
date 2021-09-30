class FilterViewModel {
  final String? district;
  final int? rooms;
  final double? priceFrom;
  final double? priceTo;
  final String? repair;
  final double? area;
  final int? floor;
  final bool sortPriceDown;
  final bool sortPriceUp;
  final bool sortDistrict;
  final bool sortDate;

  FilterViewModel(
      {this.district,
      this.rooms,
      this.priceFrom,
      this.priceTo,
      this.floor,
      this.repair,
      this.area,
      this.sortPriceDown = false,
      this.sortPriceUp = false,
      this.sortDistrict = false,
      this.sortDate = false});
}
