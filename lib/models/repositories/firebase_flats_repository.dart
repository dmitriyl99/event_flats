import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/view/viewmodels/filter.viewmodel.dart';

class FireabaseFlatsRepository extends FlatsRepository {
  @override
  Future<void> createFlat(Flat flat) async {
    await FirebaseFirestore.instance.collection('flats').add(flat.toJson());
  }

  @override
  Future<List<Flat>> getFlats() async {
    var snapshot = await FirebaseFirestore.instance.collection('flats').get();

    List<Flat> flats = [];
    snapshot.docs.forEach((element) {
      flats.add(Flat.fromJson(element.data()));
    });

    return flats;
  }

  Stream<QuerySnapshot> getFlatsStream({FilterViewModel? filter}) {
    if (filter == null)
      return FirebaseFirestore.instance.collection('flats').snapshots();
    var query = FirebaseFirestore.instance
        .collection('flats')
        .where('price', isGreaterThanOrEqualTo: filter.priceFrom)
        .where('price', isLessThanOrEqualTo: filter.priceTo);
    if (filter.district != null) {
      query = query.where('address', isEqualTo: filter.district);
    }
    if (filter.repair != null) {
      query = query.where('flatRepair', isEqualTo: filter.repair);
    }
    if (filter.rooms != null) {
      query = query.where('numberOfRooms', isEqualTo: filter.rooms);
    }
    if (filter.sortPriceDown) {
      query = query.orderBy('price', descending: true);
    }
    if (filter.sortPriceUp) {
      query = query.orderBy('price');
    }
    if (filter.sortDistrict) {
      query = query.orderBy('address');
    }
    if (filter.sortDate) {
      query = query.orderBy('createdAt', descending: true);
    }
    return query.snapshots();
  }

  @override
  Future<void> updateFlat(Flat flat) async {
    await FirebaseFirestore.instance
        .collection('flats')
        .doc(flat.id)
        .update(flat.toJson());
  }

  @override
  Future<Flat?> getById(String id) async {
    var result =
        await FirebaseFirestore.instance.collection('flats').doc(id).get();
    if (result.exists) {
      var flat = Flat.fromJson(result.data()!);
      flat.id = result.id;
      return flat;
    }
    return null;
  }

  @override
  Future<void> removeById(String id) async {
    await FirebaseFirestore.instance.collection('flats').doc(id).delete();
  }

  @override
  Future<void> toggleFavorite(String id) async {
    var flat = await getById(id);
    if (flat == null) return;
    await FirebaseFirestore.instance
        .collection('flats')
        .doc(id)
        .update({'isFavorite': !flat.isFavorite});
  }
}
