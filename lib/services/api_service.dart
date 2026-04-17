import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  static const String _authorizationEndpoint =
      'https://api.intra.42.fr/oauth/authorize';
  static const String _tokenEndpoint =
      'https://api.intra.42.fr/oauth/token';
  static const String _redirectUrl =
      'com.swiftycompanion://callback';

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

  String? get accessToken => _accessToken;
}