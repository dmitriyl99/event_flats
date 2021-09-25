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
    var snapshot = await FirebaseDatabase.instance
        .reference()
        .child('flats')
        .orderByChild('isFavorite')
        .get();

    List<Flat> flats = [];
    if (snapshot.value != null)
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

  @override
  Future<Flat?> getById(String id) async {
    var result = await FirebaseDatabase.instance
        .reference()
        .child('flats')
        .child(id)
        .once();
    if (result.exists) {
      var flat = Flat.fromJson(Map<String, dynamic>.from(result.value));
      flat.id = result.key!;
      return flat;
    }
    return null;
  }

  @override
  Future<void> removeById(String id) async {
    await FirebaseDatabase.instance
        .reference()
        .child('flats')
        .child(id)
        .remove();
  }

  @override
  Future<void> toggleFavorite(String id) async {
    var flat = await getById(id);
    if (flat == null) return;
    await FirebaseDatabase.instance
        .reference()
        .child('flats')
        .child(id)
        .update({'isFavorite': !flat.isFavorite});
  }
}
