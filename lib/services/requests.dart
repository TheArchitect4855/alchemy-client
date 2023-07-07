import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:alchemy/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart';

const timeout = Duration(seconds: 20);
final debugUri = Uri(
    scheme: 'http',
    host: '10.0.2.2',
    port:
        8787); // 10.0.2.2 is "loopback on the host machine" for Android emulators
final liveUri = Uri(scheme: 'https', host: 'api.kurtisknodel.workers.dev');

class RequestsService {
  static final RequestsService instance = RequestsService();
  static final Encoding _encoding = Encoding.getByName('UTF-8')!;

  final Client _client;
  String? _authToken;
  String? _userAgent;

  RequestsService() : _client = Client();

  Future<O?> post<O>(String endpoint, Map<String, dynamic> body, O Function(Map<String, dynamic>) builder, { Map<String, dynamic>? urlParams }) async {
    try {
      final uri = _getUri(endpoint, urlParams);
      Logger.info(runtimeType, 'POST $uri');
      final response = await _client.post(uri, body: jsonEncode(body), encoding: _encoding, headers: await _getHeaders()).timeout(timeout);
      _validateResponse(response);
      if (response.body.isEmpty) return null;
      return builder(jsonDecode(response.body));
    } on ClientException catch (e) {
      throw RequestsServiceClientException(e);
    } on TimeoutException {
      throw RequestsServiceTimeoutException();
    }
  }

  Future<O?> postBinary<O>(String endpoint, Uint8List body, String mimeType, O Function(Map<String, dynamic>) builder, { Map<String, dynamic>? urlParams }) async {
    try {
      final uri = _getUri(endpoint, urlParams);
      Logger.info(runtimeType, 'POST $uri');
      
      final headers = await _getHeaders();
      headers['Content-Type'] = mimeType;

      final response = await _client.post(uri, body: body, headers: headers).timeout(timeout);
      _validateResponse(response);
      if (response.body.isEmpty) return null;
      return builder(jsonDecode(response.body));
    } on ClientException catch (e) {
      throw RequestsServiceClientException(e);
    } on TimeoutException {
      throw RequestsServiceTimeoutException();
    }
  }

  Future<O?> get<O>(String endpoint, O Function(Map<String, dynamic>) builder, { Map<String, dynamic>? urlParams }) async {
    try {
      final uri = _getUri(endpoint, urlParams);
      Logger.info(runtimeType, 'GET $uri');
      final response = await _client.get(uri, headers: await _getHeaders()).timeout(timeout);
      _validateResponse(response);
      if (response.body.isEmpty) return null;
      return builder(jsonDecode(response.body));
    } on ClientException catch (e) {
      throw RequestsServiceClientException(e);
    } on TimeoutException {
      throw RequestsServiceTimeoutException();
    }
  }

  Future<O?> put<O>(String endpoint, Map<String, dynamic> body, O Function(Map<String, dynamic>) builder, { Map<String, dynamic>? urlParams }) async {
    try {
      final uri = _getUri(endpoint, urlParams);
      Logger.info(runtimeType, 'PUT $uri');
      final response = await _client.put(uri, body: jsonEncode(body), encoding: _encoding, headers: await _getHeaders()).timeout(timeout);
      _validateResponse(response);
      if (response.body.isEmpty) return null;
      return builder(jsonDecode(response.body));
    } on ClientException catch (e) {
      throw RequestsServiceClientException(e);
    } on TimeoutException {
      throw RequestsServiceTimeoutException();
    }
  }

  Future<O?> delete<O>(String endpoint, O Function(Map<String, dynamic>) builder, { Map<String, dynamic>? urlParams }) async {
    try {
      final uri = _getUri(endpoint, urlParams);
      Logger.info(runtimeType, 'DELETE $uri');
      final response = await _client.delete(uri, headers: await _getHeaders()).timeout(timeout);
      _validateResponse(response);
      if (response.body.isEmpty) return null;
      return builder(jsonDecode(response.body));
    } on ClientException catch (e) {
      throw RequestsServiceClientException(e);
    } on TimeoutException {
      throw RequestsServiceTimeoutException();
    }
  }

  void setAuthToken(String token) {
    Logger.debug(runtimeType, 'Setting auth token to $token');
    _authToken = token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final userAgent = await _getUserAgent();
    final res = {
      'Content-Type': 'application/json',
      'User-Agent': userAgent,
    };

    if (_authToken != null) res['Authorization'] = 'Bearer $_authToken';
    return res;
  }

  Uri _getUri(String endpoint, Map<String, dynamic>? urlParams) {
      final Uri baseUri;
      if (kDebugMode) {
        baseUri = debugUri;
      } else {
        baseUri = liveUri;
      }

      return Uri(
        scheme: baseUri.scheme,
        host: baseUri.host,
        port: baseUri.port,
        path: endpoint,
        queryParameters: urlParams,
      );
  }

  Future<String> _getUserAgent() async {
    if (_userAgent != null) return _userAgent!;

    final packageInfo = await PackageInfo.fromPlatform();
    _userAgent = 'Alchemy App ${packageInfo.version} build ${packageInfo.buildNumber} on ${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
    Logger.info(runtimeType, 'User Agent: $_userAgent');
    return _userAgent!;
  }

  void _validateResponse(Response response) {
    Logger.info(runtimeType, '${response.statusCode} ${response.reasonPhrase}:\n${response.body}');
    if (response.statusCode == 200) return;
    throw RequestsServiceHttpException(response);
  }
}

abstract class RequestsServiceException implements Exception {
  final String message;
  final Exception? inner;

  RequestsServiceException(this.message, { this.inner });

  @override
  String toString() {
    var msg =
        'Requests Service Exception: ${message.trim().isEmpty ? 'no further information' : message}';
    if (inner != null) msg += '\n\tfrom $inner';
    return msg;
  }
}

class RequestsServiceClientException extends RequestsServiceException {
  RequestsServiceClientException(ClientException e) : super('client exception', inner: e);
}

class RequestsServiceHttpException extends RequestsServiceException {
  final String error;
  final int status;

  RequestsServiceHttpException(Response response) : error = response.body, status = response.statusCode, super('HTTP error: ${response.statusCode} ${response.reasonPhrase}: ${response.body}');
}

class RequestsServiceTimeoutException extends RequestsServiceException {
  RequestsServiceTimeoutException() : super('request timed out');
}
