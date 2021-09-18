import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:firebase_database/firebase_database.dart';

class FireabaseFlatsRepository extends FlatsRepository {
  @override
  Future<void> createFlat(Flat flat) {
    // TODO: implement createFlat
    throw UnimplementedError();
  }

  @override
  Future<List<Flat>> getFlats() async {
    var snapshot =
        await FirebaseDatabase.instance.reference().child('flats').get();

    List<Flat> flats = [];

    snapshot.value.forEach((id, flat) {
      flats.add(Flat.fromJson(Map<String, dynamic>.from(flat)));
    });

    return flats;
  }
}
