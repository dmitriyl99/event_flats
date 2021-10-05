import 'package:dio/dio.dart';
import 'package:event_flats/events/flat_created.dart';
import 'package:event_flats/events/service.dart';
import 'package:event_flats/models/dto/flat.dart';
import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/models/user.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/services/exceptions/forbidden_exception.dart';
import 'package:event_flats/services/exceptions/server_error_exception.dart';
import 'package:event_flats/services/exceptions/user_empty.dart';
import 'package:event_flats/services/exceptions/validation_exception.dart';
import 'package:event_flats/view/viewmodels/filter.viewmodel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ApiFlatsRepository extends FlatsRepository {
  final Dio _httpClient = new Dio(BaseOptions(
      baseUrl: 'http://localhost:8000/api/v1/flats',
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'}));
  final AuthenticationService _authenticationService;

  ApiFlatsRepository(this._authenticationService);

  @override
  Future<void> createFlat(FlatDto flat) async {
    var payload = flat.toJson();
    Response<dynamic> response;
    try {
      response = await _httpClient.post('/',
          data: payload, options: await _authorizationOptions());
    } on DioError catch (err) {
      if (err.response!.statusCode == 422)
        throw new ValidationException(
            Map<String, dynamic>.from(err.response!.data));
      if (err.response!.statusCode == 500) throw new ServerErrorException();
      throw err;
    }
    var data = response.data['data'] as Map<String, dynamic>;
    Flat createdFlat = Flat.fromJson(data);
    EventService.bus.fire(FlatCreated(createdFlat));
    if (flat.images != null) return;
    flat.images!.forEach((file) async {
      var compressedFile =
          await FlutterImageCompress.compressWithFile(file.absolute.path);
      var fileExtension = file.path.split('.').last;
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var fileName = "$timestamp.$fileExtension";
      if (compressedFile != null)
        await FirebaseStorage.instance
            .ref()
            .child('flats')
            .child('/${createdFlat.id}/$fileName')
            .putData(compressedFile);
    });
  }

  @override
  Future<Flat?> getById(int id) async {
    var response =
        await _httpClient.get('/$id', options: await _authorizationOptions());
    return Flat.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<Flat>> getFlats({FilterViewModel? filter}) async {
    Map<String, dynamic>? parameters = filter?.toMap();
    var response = await _httpClient.get('/',
        queryParameters: parameters, options: await _authorizationOptions());
    if (response.statusCode == 500) throw new ServerErrorException();
    var data = response.data['data'];
    return data.map<Flat>((e) => Flat.fromJson(e)).toList();
  }

  @override
  Future<void> removeById(int id) async {
    var response = await _httpClient.delete('/$id',
        options: await _authorizationOptions());
    if (response.statusCode == 500) throw new ServerErrorException();
    if (response.statusCode == 403)
      throw new ForbiddenException(message: response.data['error'] as String);
  }

  @override
  Future<void> toggleFavorite(int id) async {
    var response = await _httpClient.patch('/$id/favorite',
        options: await _authorizationOptions());
    if (response.statusCode == 500) throw new ServerErrorException();
  }

  @override
  Future<void> updateFlat(FlatDto flat) async {
    var payload = flat.toJson();
    var response = await _httpClient.post('/',
        data: payload, options: await _authorizationOptions());
    if (response.statusCode == 422)
      throw new ValidationException(Map<String, dynamic>.from(response.data));
    if (response.statusCode == 500) throw new ServerErrorException();
    if (response.statusCode == 403)
      throw new ForbiddenException(message: response.data['error'] as String);
  }

  Future<User> _getUser() async {
    var user = _authenticationService.getUser();
    if (user == null) throw new UnauthorizedUserException();
    return user;
  }

  Future<Options> _authorizationOptions() async {
    var user = await _getUser();
    return Options(headers: {'Authorization': 'Bearer ${user.accessToken}'});
  }
}
