import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:firebase_database/firebase_database.dart';

class FireabaseFlatsRepository extends FlatsRepository {
  @override
  Future<void> createFlat(Flat flat) async {
    await FirebaseDatabase.instance
        .reference()
        .child('flats')
        .push()
        .set(flat.toJson());
  }

  @override
  Future<List<Flat>> getFlats() async {
    var snapshot =
        await FirebaseDatabase.instance.reference().child('flats').get();

    List<Flat> flats = [];

    snapshot.value.forEach((id, flat) {
      var flatModel = Flat.fromJson(Map<String, dynamic>.from(flat));
      flatModel.id = id;
      flats.add(flatModel);
    });

    return flats;
  }

  @override
  Future<void> updateFlat(Flat flat) async {
    await FirebaseDatabase.instance
        .reference()
        .child('flats')
        .child(flat.id)
        .set(flat.toJson());
  }
}
