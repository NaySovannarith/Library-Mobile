// lib/models/auth_models.dart
import 'dart:convert';

class User {
  final int id;
  final String email;
  final String name;
  final String? role;
  final String? phoneNumber;
  final bool? isEmailConfirmed;
  final Address? address;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.role,
    this.phoneNumber,
    this.isEmailConfirmed,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isEmailConfirmed: json['isEmailConfirmed'] as bool?,
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
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
      'address': address?.toJson(),
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? role,
    String? phoneNumber,
    bool? isEmailConfirmed,
    Address? address,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailConfirmed: isEmailConfirmed ?? this.isEmailConfirmed,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role)';
  }
}

class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;

  Address({this.street, this.city, this.state, this.zipCode, this.country});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }

  @override
  String toString() {
    return 'Address(street: $street, city: $city, state: $state)';
  }
}

class AuthResponse {
  final String message;
  final User user;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.message,
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String? phoneNumber;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'rememberMe': rememberMe};
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'currentPassword': currentPassword, 'newPassword': newPassword};
  }
}

class PasswordResetRequest {
  final String email;
  final String? otp;
  final String? newPassword;

  PasswordResetRequest({required this.email, this.otp, this.newPassword});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      if (otp != null) 'otp': otp,
      if (newPassword != null) 'newPassword': newPassword,
    };
  }
}

class ApiResponse<T> {
  final String message;
  final T? data;
  final bool success;

  ApiResponse({required this.message, this.data, this.success = true});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse(
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : null,
      success: json['success'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(message: $message, data: $data, success: $success)';
  }
}

class TokenData {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  TokenData({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isExpiringSoon =>
      DateTime.now().add(const Duration(minutes: 2)).isAfter(expiresAt);

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  @override
  String toString() {
    return 'TokenData(accessToken: ${accessToken.substring(0, 10)}..., expiresAt: $expiresAt)';
  }
}
