import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:event_flats/events/flat_created.dart';
import 'package:event_flats/events/flat_updated.dart';
import 'package:event_flats/events/service.dart';
import 'package:event_flats/models/dto/flat.dart';
import 'package:event_flats/models/flat.dart';
import 'package:event_flats/models/repositories/flats_repository.dart';
import 'package:event_flats/models/user.dart';
import 'package:event_flats/services/authentication.dart';
import 'package:event_flats/services/exceptions/authentication_failed.dart';
import 'package:event_flats/services/exceptions/forbidden_exception.dart';
import 'package:event_flats/services/exceptions/no_internet.dart';
import 'package:event_flats/services/exceptions/server_error_exception.dart';
import 'package:event_flats/services/exceptions/user_empty.dart';
import 'package:event_flats/services/exceptions/validation_exception.dart';
import 'package:event_flats/view/viewmodels/filter.viewmodel.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../services/api_settings.dart';

class ApiFlatsRepository extends FlatsRepository {
  final Dio _httpClient = new Dio(BaseOptions(
      baseUrl: '${ApiSettings.host}/api/v1/flats',
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'}));
  final AuthenticationService _authenticationService;

  ApiFlatsRepository(this._authenticationService);

  @override
  Future<void> createFlat(FlatDto flat) async {
    var payload = flat.toJson();

    Response<dynamic> response;
    try {
      response = await _httpClient.post('',
          data: payload, options: _authorizationOptions());
    } on DioError catch (err) {
      if (err.response == null) throw new NoInternetException();
      var response = err.response!;
      if (response.statusCode == 422)
        throw new ValidationException(
            Map<String, dynamic>.from(err.response!.data));
      if (response.statusCode == 500) throw new ServerErrorException();
      if (response.statusCode == 401) throw new AuthenticationFailed();
      throw err;
    }
    var data = response.data['data'] as Map<String, dynamic>;
    Flat createdFlat = Flat.fromJson(data);
    EventService.bus.fire(FlatCreated(createdFlat));
    if (flat.bytesImages == null) return;
    flat.bytesImages!.forEach((file) async {
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var fileName = "$timestamp.jpeg";
      var result = await FirebaseStorage.instance
          .ref()
          .child('flats')
          .child('/${createdFlat.id}/$fileName')
          .putData(file);
    });
  }

  @override
  Future<Flat?> getById(int id) async {
    Response<dynamic> response;
    try {
      response =
          await _httpClient.get('/$id', options: _authorizationOptions());
    } on DioError catch (error) {
      if (error.response == null) throw new NoInternetException();
      var response = error.response!;
      if (response.statusCode == 500) throw new ServerErrorException();
      if (response.statusCode == 401) throw new AuthenticationFailed();

      throw error;
    }
    return Flat.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<Flat>> getFlats({FilterViewModel? filter, int page = 1}) async {
    Map<String, dynamic> parameters = {'page': page};
    if (filter != null) {
      parameters.addAll(filter.toMap());
    }
    Response<dynamic> response;
    try {
      response = await _httpClient.get('',
          queryParameters: parameters, options: _authorizationOptions());
    } on DioError catch (error) {
      log(error.toString());
      if (error.response == null) throw new NoInternetException();
      var response = error.response!;
      if (response.statusCode == 500) throw new ServerErrorException();
      if (response.statusCode == 401) throw new AuthenticationFailed();

      throw error;
    }
    if (response.statusCode == 500) throw new ServerErrorException();
    var data = response.data['data'];
    return data.map<Flat>((e) => Flat.fromJson(e)).toList();
  }

  @override
  Future<void> removeById(int id) async {
    try {
      await _httpClient.delete('/$id', options: _authorizationOptions());
    } on DioError catch (error) {
      if (error.response == null) throw new NoInternetException();
      var response = error.response!;
      if (response.statusCode == 500) throw new ServerErrorException();
      if (response.statusCode == 403)
        throw new ForbiddenException(message: response.data['error'] as String);
      if (response.statusCode == 401) throw new AuthenticationFailed();

      throw error;
    }
    await FirebaseStorage.instance.ref().child('flats').child('/$id/').delete();
  }

  @override
  Future<void> toggleFavorite(int id) async {
    try {
      await _httpClient.patch('/$id/favorite',
          options: _authorizationOptions());
    } on DioError catch (error) {
      if (error.response == null) throw new NoInternetException();
      var response = error.response!;
      if (response.statusCode == 500) throw new ServerErrorException();
      if (response.statusCode == 401) throw new AuthenticationFailed();
    }
  }

  @override
  Future<void> updateFlat(FlatDto flat) async {
    var payload = flat.toJson();
    try {
      await _httpClient.put('/${flat.id}',
          data: payload, options: _authorizationOptions());
    } on DioError catch (error) {
      if (error.response == null) throw new NoInternetException();
      var response = error.response!;
      if (response.statusCode == 422)
        throw new ValidationException(Map<String, dynamic>.from(response.data));
      if (response.statusCode == 500) throw new ServerErrorException();
      if (response.statusCode == 403)
        throw new ForbiddenException(message: response.data['error'] as String);
      if (response.statusCode == 401) throw new AuthenticationFailed();
      throw error;
    }
    EventService.bus.fire(FlatUpdated());
  }

  @override
  Future<void> sellFlat(int id) async {
    try {
      await _httpClient.patch('/$id/sell', options: _authorizationOptions());
    } on DioError catch (error) {
      if (error.response == null) throw new NoInternetException();
      var response = error.response!;
      if (response.statusCode == 422)
        throw new ValidationException(Map<String, dynamic>.from(response.data));
      if (response.statusCode == 500) throw new ServerErrorException();
      if (response.statusCode == 403)
        throw new ForbiddenException(message: response.data['error'] as String);
      if (response.statusCode == 401) throw new AuthenticationFailed();
      log("Error while selling flat $id", error: error);
      log(error.response.toString());
      throw error;
    }
    EventService.bus.fire(FlatUpdated());
  }

  User _getUser() {
    var user = _authenticationService.getUser();
    if (user == null) throw new UnauthorizedUserException();
    return user;
  }

  Options _authorizationOptions() {
    var user = _getUser();
    return Options(headers: {'Authorization': 'Bearer ${user.accessToken}'});
  }
}
