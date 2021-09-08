import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';

class FakeFlatsRepository extends FlatsRepository {
  @override
  Future<List<Flat>> getFlats() async {
    return <Flat>[
      Flat('Яккасарай', 20000, 4, 5, 2, 'Чистый', DateTime.now(), false),
      Flat('Яккасарай', 20000, 4, 5, 2, 'Чистый', DateTime.now(), false),
      Flat('Яккасарай', 30000, 4, 5, 2, 'Чистый', DateTime.now(), false),
      Flat('Яккасарай', 20000, 4, 5, 2, 'Чистый', DateTime.now(), true),
      Flat('Яккасарай', 20000, 4, 5, 2, 'Чистый', DateTime.now(), false),
      Flat('Яккасарай', 20000, 4, 5, 2, 'Чистый', DateTime.now(), true),
      Flat('Яккасарай', 20000, 4, 5, 2, 'Чистый', DateTime.now(), false)
    ];
  }
}
