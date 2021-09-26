class FilterViewModel {
  final String? district;
  final int? roomsFrom;
  final int? roomsTo;
  final double priceFrom;
  final double priceTo;
  final String? repair;
  final bool sortPriceDown;
  final bool sortPriceUp;
  final bool sortDistrict;
  final bool sortDate;

  FilterViewModel(this.district, this.roomsFrom, this.roomsTo, this.priceFrom,
      this.priceTo, this.repair,
      {this.sortPriceDown = false,
      this.sortPriceUp = false,
      this.sortDistrict = false,
      this.sortDate = false});
}
