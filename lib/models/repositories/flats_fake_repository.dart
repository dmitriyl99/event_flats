import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';

class FakeFlatsRepository extends FlatsRepository {
  List<Flat> _flats = [
    Flat('Яккасарай', 20000, 4, 5, 2, 'Чистый', DateTime.now(), false, 48.3,
        "Lorem ipsum, dolor sit amet", 'Ашхабад', '+998909879930',
        ownerName: 'Дмитрий'),
    Flat('Яккасарай', 20000, 4, 5, 2, 'Чистый', DateTime.now(), false, 48.3,
        "Lorem ipsum, dolor sit amet", 'Ашхабад', '+998909879930',
        ownerName: 'Дмитрий'),
    Flat('Яккасарай', 30000, 4, 5, 2, 'Чистый', DateTime.now(), false, 48.3,
        "Lorem ipsum, dolor sit amet", 'Ашхабад', '+998909879930',
        ownerName: 'Дмитрий'),
    Flat('Яккасарай', 20000, 4, 5, 2, 'Чистый', DateTime.now(), true, 48.3,
        "Lorem ipsum, dolor sit amet", 'Ашхабад', '+998909879930',
        ownerName: 'Дмитрий'),
    Flat('Яккасарай', 20000, 4, 5, 2, 'Чистый', DateTime.now(), false, 48.3,
        "Lorem ipsum, dolor sit amet", 'Ашхабад', '+998909879930',
        ownerName: 'Дмитрий'),
    Flat('Яккасарай', 20000, 4, 5, 2, 'Чистый', DateTime.now(), true, 48.3,
        "Lorem ipsum, dolor sit amet", 'Ашхабад', '+998909879930',
        ownerName: 'Дмитрий'),
    Flat('Яккасарай', 20000, 4, 5, 2, 'Чистый', DateTime.now(), false, 48.3,
        "Lorem ipsum, dolor sit amet", 'Ашхабад', '+998909879930',
        ownerName: 'Дмитрий')
  ];

  @override
  Future<List<Flat>> getFlats() async {
    await Future.delayed(Duration(seconds: 1));
    return _flats;
  }

  @override
  Future<void> createFlat(Flat flat) async {
    await Future.delayed(Duration(seconds: 1));
    _flats.add(flat);
  }

  @override
  Future<void> updateFlat(Flat flat) {
    // TODO: implement updateFlat
    throw UnimplementedError();
  }
}
