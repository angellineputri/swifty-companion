import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  static const String _authorizationEndpoint =
      'https://api.intra.42.fr/oauth/authorize';
  static const String _tokenEndpoint =
      'https://api.intra.42.fr/oauth/token';
  static const String _redirectUrl =
      'com.swiftycompanion://callback';
  static const String _baseUrl = 'https://api.intra.42.fr/v2';

  String? _accessToken;

  Future<bool> login() async {
    try {
      final clientId = dotenv.env['UID'] ?? '';
      final clientSecret = dotenv.env['SECRET'] ?? '';

      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          _redirectUrl,
          clientSecret: clientSecret,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: _authorizationEndpoint,
            tokenEndpoint: _tokenEndpoint,
          ),
          scopes: ['public'],
        ),
      );

      if (result != null) {
        _accessToken = result.accessToken;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<User?> getUser(String login) async {
    if (_accessToken == null) {
      debugPrint('No access token');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$login'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return User.fromJson(json);
      } else if (response.statusCode == 404) {
        debugPrint('User not found: $login');
        return null;
      } else {
        debugPrint('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Get user error: $e');
      return null;
    }
  }

  String? get accessToken => _accessToken;
}