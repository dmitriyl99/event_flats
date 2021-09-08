class Flat {
  late String id;
  final String name;
  final double price;
  final int floor;
  final int numberOfFloors;
  final int numberOfRooms;
  final String flatRepair;
  final bool isFavorite;
  final DateTime createdAt;

  Flat(this.name, this.price, this.floor, this.numberOfFloors,
      this.numberOfRooms, this.flatRepair, this.createdAt, this.isFavorite);
}
