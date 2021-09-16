class Flat {
  late String id;
  final String address;
  final double price;
  final int floor;
  final int numberOfFloors;
  final int numberOfRooms;
  final String flatRepair;
  final double area;
  final String landmark;
  final String description;
  final String? ownerName;
  final String ownerPhone;
  final bool isFavorite;
  final DateTime createdAt;

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
      {this.ownerName});
}
