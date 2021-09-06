enum FlatRepairType {
  Clean,
}

class Flat {
  late String id;
  final String name;
  final int floor;
  final int numberOfFloors;
  final int numberOfRooms;
  final FlatRepairType flatRepairType;

  Flat(this.name, this.floor, this.numberOfFloors, this.numberOfRooms,
      this.flatRepairType);
}
