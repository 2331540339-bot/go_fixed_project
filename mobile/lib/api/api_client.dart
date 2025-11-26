import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient(this._client, this._sp);
  final http.Client _client;
  final SharedPreferences _sp;

  static Future<ApiClient> create() async {
    final sp = await SharedPreferences.getInstance();
    return ApiClient(http.Client(), sp);
  }

  String? get token => _sp.getString('token');

  Future<http.Response> get(String url) {
    return _client.get(Uri.parse(url), headers: _headers());
  }

  Future<http.Response> post(String url, {Object? body}) {
    return _client.post(Uri.parse(url), headers: _headers(), body: body);
  }

  Map<String, String> _headers() => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}
