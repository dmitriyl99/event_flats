import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:event_flats/models/flat.dart';

import '../helpers/number_formatting.dart';

class TelegramService {
  Future<void> sendMessageToChannel(Flat flat) async {

    String text =
        "${flat.numberOfRooms}/${flat.floor}/${flat.numberOfFloors} ${flat.subDistrict}\n"
        "Состояние: ${flat.flatRepair} ${flat.area}кв.м\n"
        "Ор-р: ${flat.landmark}\n"
        "Цена: ${NumberFormattingHelper.format(flat.publicPrice ?? flat.price)}\n"
        "Тел: +998998078071\n"
        "#${flat.numberOfRooms}ком";
    List<Map<String, dynamic>> media = [];
    for (var photo
        in flat.photos.where((element) => element['watermarked'] == 1)) {
      media.add({
        "type": 'photo',
        "media": photo['url'],
      });
    }
    var payload = {"chat_id": -1001813277591, "text": text};
    var apiPath = 'sendMessage';
    if (media.isNotEmpty) {
      media[0]['caption'] = text;
      payload = {"chat_id": -1001813277591, "media": jsonEncode(media)};
      apiPath = 'sendMediaGroup';
    }

    String botToken = '6365499924:AAHL0ZX4TWTnx_3ZFDmhpm-ePmqUcYLP098';
    print("https://api.telegram.org/bot$botToken/${apiPath}");
    try {
      final response = await Dio().post(
          "https://api.telegram.org/bot$botToken/${apiPath}",
          data: payload,
          options: Options(responseType: ResponseType.json));
    } on DioException catch (error) {
      print(error.response!.data.toString());
    }
  }
}
