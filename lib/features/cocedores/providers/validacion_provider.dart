import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zona_gris_mobile/core/networtk/api_client.dart';

class ValidacionProvider extends ChangeNotifier {
  Map<String, dynamic> _registroPendiente = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic> get registroPendiente => _registroPendiente;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setters
  void setRegistroPendiente(Map<String, dynamic> registroPendiente) {
    _registroPendiente = registroPendiente;
    notifyListeners();
  }

  void setErrorMessage(String? errorMessage) {
    _errorMessage = errorMessage;
    notifyListeners();
  }

  Future<bool> enviarValidacion(Map<String, dynamic> datosValidacion) async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await ApiClient.post(
        'zonagris/funciones/cocedores/validar-supervisor',
        datosValidacion,
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error en enviarValidacion: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRegistroPendienteValidacion(String cocedorId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await ApiClient.get(
        'zonagris/funciones/cocedores/obtener-detalle-cocedor-proceso/$cocedorId',
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)[0];
        setRegistroPendiente(data);
      } else {
        setRegistroPendiente({});
        debugPrint('Error en fetchCocedoresProcesos: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en fetchCocedoresProcesos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
