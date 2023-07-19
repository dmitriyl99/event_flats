import 'package:dio/dio.dart';
import 'package:event_flats/models/flat.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TelegramService {
  Future<void> sendMessageToChannel(Flat flat) async {
    var files = await FirebaseStorage.instance
        .ref()
        .child('flats')
        .child(flat.id.toString() + '/')
        .listAll();
    List<String> downloadUrls = [];
    for (var element in files.items) {
      downloadUrls.add(await element.getDownloadURL());
    }
    Map<String, dynamic> payload = {
      "number_of_rooms": flat.numberOfRooms,
      "floor": flat.floor,
      "number_of_floors": flat.numberOfFloors,
      "sub_district": flat.subDistrict,
      "repair": flat.flatRepair,
      "area": flat.area,
      "landmark": flat.landmark,
      "description": flat.description,
      "price": flat.publicPrice?.toInt() ?? flat.price.toInt(),
      "photos": downloadUrls
    };
    print(payload);
    Dio _httpClient = new Dio(BaseOptions(
        baseUrl: 'http://164.92.88.167:8100',
        responseType: ResponseType.json,
        headers: {'Accept': 'application/json'}));
    await _httpClient.post('', data: payload);
  }
}
