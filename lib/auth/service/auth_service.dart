// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:library_app/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class User {
  final int id;
  final String email;
  final String name;
  final String? role;
  final String? phoneNumber;
  final bool? isEmailConfirmed;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.role,
    this.phoneNumber,
    this.isEmailConfirmed,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      phoneNumber: json['phoneNumber'],
      isEmailConfirmed: json['isEmailConfirmed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'isEmailConfirmed': isEmailConfirmed,
    };
  }
}

class AuthService extends ChangeNotifier {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  late SharedPreferences _prefs;
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _checkAuthStatus();
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/authentication/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'name': name,
              if (phoneNumber != null && phoneNumber.isNotEmpty)
                'phoneNumber': phoneNumber,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Parse the response to extract user data
        try {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse is Map<String, dynamic>) {
            // Registration successful - store user info if needed
            final userData = jsonResponse['user'];
            if (userData != null && userData is Map<String, dynamic>) {
              // User registered successfully, they'll need to verify email and then login
              _setLoading(false);
              return true;
            }
          }
        } catch (parseError) {
          // If parsing fails, still return true since status code was 200/201
          _setLoading(false);
          return true;
        }
        _setLoading(false);
        return true;
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          final error = errorResponse['message'] ?? 'Registration failed';
          _setError(error);
        } catch (e) {
          _setError('Registration failed: ${response.statusCode}');
        }
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Registration error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/authentication/log-in'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'rememberMe': rememberMe,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save tokens
        await _prefs.setString(_accessTokenKey, data['accessToken']);
        await _prefs.setString(_refreshTokenKey, data['refreshToken']);

        // Save user
        _currentUser = User.fromJson(data['user']);
        await _prefs.setString(_userKey, jsonEncode(data['user']));

        _isAuthenticated = true;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Login failed';
        _setError(error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      final token = _prefs.getString(_accessTokenKey);
      if (token != null) {
        await http
            .post(
              Uri.parse('${ApiConfig.baseUrl}/authentication/log-out'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 30));
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      await _prefs.remove(_accessTokenKey);
      await _prefs.remove(_refreshTokenKey);
      await _prefs.remove(_userKey);

      _currentUser = null;
      _isAuthenticated = false;
      _setLoading(false);
      notifyListeners();
    }
  }

  // Get current user
  Future<bool> getCurrentUser() async {
    try {
      final token = _prefs.getString(_accessTokenKey);
      if (token == null) return false;

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/authentication/me'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data['user']);
        await _prefs.setString(_userKey, jsonEncode(data['user']));
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        // Token expired, try refresh
        return await _refreshAccessToken();
      }

      return false;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return false;
    }
  }

  // Refresh token
  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = _prefs.getString(_refreshTokenKey);
      if (refreshToken == null) {
        _isAuthenticated = false;
        return false;
      }

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/authentication/refresh'),
            headers: {'Authorization': 'Bearer $refreshToken'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _prefs.setString(_accessTokenKey, data['accessToken']);
        return true;
      } else {
        _isAuthenticated = false;
        await logout();
        return false;
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
      _isAuthenticated = false;
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final token = _prefs.getString(_accessTokenKey);
      if (token == null) throw Exception('No access token');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/authentication/change-password'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _setLoading(false);
        return true;
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'Password change failed';
        _setError(error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Password change error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Request password reset OTP
  Future<bool> requestPasswordResetOtp(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/authentication/request-reset-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _setLoading(false);
        return true;
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Request failed';
        _setError(error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Verify reset OTP
  Future<bool> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/authentication/verify-reset-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _setLoading(false);
        return true;
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'Verification failed';
        _setError(error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Verification error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/authentication/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'otp': otp,
              'newPassword': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _setLoading(false);
        return true;
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Reset failed';
        _setError(error);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Reset error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Check if token is expired
  bool _isAccessTokenExpired() {
    final token = _prefs.getString(_accessTokenKey);
    if (token == null) return true;
    return JwtDecoder.isExpired(token);
  }

  // Check auth status on app start
  Future<void> _checkAuthStatus() async {
    final token = _prefs.getString(_accessTokenKey);

    if (token == null) {
      _isAuthenticated = false;
      notifyListeners();
      return;
    }

    if (_isAccessTokenExpired()) {
      // Try to refresh
      await _refreshAccessToken();
    } else {
      // Token valid, get user data
      await getCurrentUser();
    }
  }

  // Get auth header
  Map<String, String> getAuthHeaders() {
    final token = _prefs.getString(_accessTokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
