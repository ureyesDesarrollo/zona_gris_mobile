import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zona_gris_mobile/core/networtk/api_client.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _userId;
  User? get user => _user;
  String? get userId => _userId;
  bool get isLoggedIn => _user != null;

  Future<void> login(String username, String password) async {
    try {
      final response = await ApiClient.post('login', {
        'usuario': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userId = data['user_id'];
        notifyListeners();
      } else if (response.statusCode == 401) {
        final error = jsonDecode(response.body)['error'];
        throw Exception(error ?? 'No autorizado');
      } else {
        throw Exception('Error de autenticación');
      }
    } catch (e) {
      debugPrint('Error al iniciar sesión: $e');
      throw Exception(e.toString().split(':').last);
    }
  }

  Future<void> getProfile() async {
    try {
      final response = await ApiClient.get('perfil/$_userId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data);
        notifyListeners();
      } else {
        throw Exception('Error al obtener el perfil');
      }
    } catch (e) {
      throw Exception(e.toString().split(':').last);
    }
  }

  void logout() {
    _user = null;
    _userId = null;
    notifyListeners();
  }
}
