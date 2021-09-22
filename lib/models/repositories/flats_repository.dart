import 'package:event_flats/models/flat.dart';

abstract class FlatsRepository {
  Future<List<Flat>> getFlats();
  Future<void> createFlat(Flat flat);
  Future<void> updateFlat(Flat flat);
}
