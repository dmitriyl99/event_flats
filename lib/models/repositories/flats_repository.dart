import 'package:event_flats/models/flat.dart';
import 'package:event_flats/view/viewmodels/filter.viewmodel.dart';

abstract class FlatsRepository {
  Future<List<Flat>> getFlats({FilterViewModel? filter});
  Future<void> createFlat(Flat flat);
  Future<void> updateFlat(Flat flat);
  Future<Flat?> getById(String id);
  Future<void> removeById(String id);
  Future<void> toggleFavorite(String id);
}
