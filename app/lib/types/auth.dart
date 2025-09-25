import 'dart:io';

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String phoneNumber;
  final String role;
  final File? profileImage;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.profileImage,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'name': name,
        'phoneNumber': phoneNumber,
        'role': role,
        'profileImage': profileImage?.path,
      };
}

class AuthResponse {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;
  final String role;

  AuthResponse({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        userId: json['userId'],
        name: json['name'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
        profileImageUrl: json['profileImageUrl'],
        role: json['role'],
      );
}
