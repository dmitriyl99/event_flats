import 'package:event_flats/models/dto/flat.dart';
import 'package:event_flats/models/flat.dart';
import 'package:event_flats/view/viewmodels/filter.viewmodel.dart';

abstract class FlatsRepository {
  Future<List<Flat>> getFlats({FilterViewModel? filter, int page = 1});
  Future<void> createFlat(FlatDto flat);
  Future<void> updateFlat(FlatDto flat);
  Future<Flat?> getById(int id);
  Future<void> removeById(int id);
  Future<void> toggleFavorite(int id);
  Future<void> sellFlat(int id);
}
