import 'dart:convert';
import 'dart:async';
import 'dart:io';
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
  String? _refreshToken;
  DateTime? _tokenExpiry;

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
        _refreshToken = result.refreshToken;
        _tokenExpiry = result.accessTokenExpirationDateTime;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  void logout() {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
  }

  Future<bool> _refreshIfNeeded() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
      DateTime.now().isBefore(
        _tokenExpiry!.subtract(const Duration(hours: 3)),
      )) {
      return true;
    }

    if (_refreshToken == null) return false;

    try {
      final clientId = dotenv.env['UID'] ?? '';
      final clientSecret = dotenv.env['SECRET'] ?? '';

      final result = await _appAuth.token(
        TokenRequest(
          clientId,
          _redirectUrl,
          clientSecret: clientSecret,
          refreshToken: _refreshToken,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: _authorizationEndpoint,
            tokenEndpoint: _tokenEndpoint,
          ),
          scopes: ['public'],
        ),
      );

      if (result != null) {
        _accessToken = result.accessToken;
        _refreshToken = result.refreshToken ?? _refreshToken;
        _tokenExpiry = result.accessTokenExpirationDateTime;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return false;
    }
  }

  Future<User?> getUser(String login) async {
    if (_accessToken == null) {
      debugPrint('No access token');
      return null;
    }

    final tokenValid = await _refreshIfNeeded();
    if (!tokenValid) {
      debugPrint('Token expired and could not refresh');
      return null;
    }

    try {
      final userResponse = await http.get(
        Uri.parse('$_baseUrl/users/$login'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      ).timeout(const Duration(seconds: 10));

      if (userResponse.statusCode == 404) return null;
      if (userResponse.statusCode != 200) {
        debugPrint('Error: ${userResponse.statusCode}');
        return null;
      }

      final userJson = jsonDecode(userResponse.body);
      User user = User.fromJson(userJson);

      final coalitionResponse = await http.get(
        Uri.parse('$_baseUrl/users/$login/coalitions?cursus_id=21'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      ).timeout(const Duration(seconds: 10));

      final coalitionUserResponse = await http.get(
        Uri.parse('$_baseUrl/coalitions_users?filter[user_id]=${userJson['id']}'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      ).timeout(const Duration(seconds: 10));

      if (coalitionResponse.statusCode == 200) {
        final coalitionJson = jsonDecode(coalitionResponse.body) as List;
        if (coalitionJson.isNotEmpty) {
          final coalitionData = coalitionJson.first;

          int personalScore = 0;
          String personalRank = '-';
          if (coalitionUserResponse.statusCode == 200) {
            final coalitionUserJson =
                jsonDecode(coalitionUserResponse.body) as List;
            if (coalitionUserJson.isNotEmpty) {
              personalScore = coalitionUserJson.first['score'] ?? 0;
              personalRank = '${coalitionUserJson.first['rank']}';
            }
          }

          user = User(
            login: user.login,
            email: user.email,
            displayName: user.displayName,
            imageUrl: user.imageUrl,
            location: user.location,
            wallet: user.wallet,
            correctionPoints: user.correctionPoints,
            score: personalScore,
            rank: personalRank,
            level: user.level,
            skills: user.skills,
            projects: user.projects,
            coalition: Coalition.fromJson(coalitionData),
          );
        }
      }
      return user;
    } on SocketException {
      debugPrint('No internet connection');
      return null;
    } on TimeoutException {
      debugPrint('Request timed out');
      return null;
    } catch (e) {
      debugPrint('Get user error: $e');
      return null;
    }
  }

  String? get accessToken => _accessToken;
}