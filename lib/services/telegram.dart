import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:event_flats/models/flat.dart';

import '../helpers/number_formatting.dart';

class TelegramService {
  Future<void> sendMessageToChannel(Flat flat) async {
    String textAddress = "${flat.address + (flat.subDistrict ?? '')}";
    if (flat.hashTag1 != null) {
      textAddress = "${flat.hashTag1} квартал";
    }

    String text =
        "#${textAddress}\nОриентир: ${flat.landmark ?? ''}\n#${flat
        .hashTag2 ?? (flat.numberOfRooms.toString() + 'комнатная')} "
        "${flat.area} кв.м\n${flat.floor} этаж\n${flat
        .numberOfFloors}-этажный\n"
        "${NumberFormattingHelper.format(flat.publicPrice ?? flat.price)}\$ стартовая цена";
    List<Map<String, dynamic>> media = [];
    for (var photo in flat.photos) {
      media.add({
        "type": 'photo',
        "media": photo['url'],
      });
    }
    var payload = {
      "chat_id": -1001813277591,
      "text": text
    };
    var apiPath = 'sendMessage';
    if (media.isNotEmpty) {
      media[0]['caption'] = text;
      payload = {
        "chat_id": -1001813277591,
        "media": jsonEncode(media)
      };
      apiPath = 'sendMediaGroup';
    }

    String botToken = '6365499924:AAHL0ZX4TWTnx_3ZFDmhpm-ePmqUcYLP098';
    print("https://api.telegram.org/bot$botToken/${apiPath}");
    try {
      final response = await Dio().post(
          "https://api.telegram.org/bot$botToken/${apiPath}", data: payload,
          options: Options(responseType: ResponseType.json));
    } on DioException catch (error) {
      print(error.response!.data.toString());
    }
  }
}
