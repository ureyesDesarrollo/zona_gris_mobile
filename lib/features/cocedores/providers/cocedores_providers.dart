import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zona_gris_mobile/core/networtk/api_client.dart';

class CocedoresProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cocedores = [];
  bool _isLoading = false;
  String? _cocedorIdSeleccionado;

  List<Map<String, dynamic>> get cocedores => _cocedores;

  bool get isLoading => _isLoading;

  String? get cocedorIdSeleccionado => _cocedorIdSeleccionado;

  void setCocedores(List<Map<String, dynamic>> cocedores) {
    _cocedores = cocedores;
    notifyListeners();
  }

  void setCocedorId(String cocedorId) {
    _cocedorIdSeleccionado = cocedorId;
    notifyListeners();
  }

  Future<void> fetchCocedores() async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await ApiClient.get('zonagris/funciones/cocedores/estado');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // Convirtiendo seguro la lista
        final List<Map<String, dynamic>> cocedores =
            List<Map<String, dynamic>>.from(
              data.map((item) => Map<String, dynamic>.from(item)),
            );
        setCocedores(cocedores);
      }
    } catch (e) {
      debugPrint('Error en fetchCocedores: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
