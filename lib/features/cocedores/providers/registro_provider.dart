import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:zona_gris_mobile/core/networtk/api_client.dart';

class RegistroProvider extends ChangeNotifier {
  Map<String, dynamic> flujoConfig = {
    'Flujo_cocedor_1': [140, 170],
    'Flujo_cocedor_2': [140, 170],
    'Flujo_cocedor_3': [140, 170],
    'Flujo_cocedor_4': [140, 170],
    'Flujo_cocedor_5': [140, 170],
    'Flujo_cocedor_6': [150, 190],
    'Flujo_cocedor_7': [150, 190],
  };

  Map<String, dynamic> temperaturaConfig = {
    'Temperatura_entrada': [56, 70],
    'Temperatura_salida': [55, 60],
  };

  Map<String, dynamic> _datosCocedor = {};
  Map<String, dynamic> _flujosCocedores = {};
  Map<String, dynamic> _flujoCocedor = {};
  Map<String, dynamic> _temperaturaCocedor = {};

  Map<String, dynamic> get datosCocedor => _datosCocedor;
  Map<String, dynamic> get flujosCocedores => _flujosCocedores;
  Map<String, dynamic> get flujoCocedor => _flujoCocedor;
  Map<String, dynamic> get temperaturaCocedor => _temperaturaCocedor;

  void setDatosCocedor(Map<String, dynamic> datos) {
    _datosCocedor = datos;
    notifyListeners();
  }

  void setFlujoCocedor(Map<String, dynamic> flujo) {
    _flujoCocedor = flujo;
    notifyListeners();
  }

  void setFlujosCocedores(Map<String, dynamic> flujos) {
    _flujosCocedores = flujos;
    notifyListeners();
  }

  void setTemperaturaCocedor(Map<String, dynamic> temperatura) {
    _temperaturaCocedor = temperatura;
    notifyListeners();
  }

  //Funcion para obtener los datos del cocedor
  Future<void> fetchCocedoresProcesos(String cocedorId) async {
    try {
      final res = await ApiClient.get(
        'zonagris/funciones/cocedores/obtener-cocedores-proceso-by-id/$cocedorId',
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setDatosCocedor(data);
      } else {
        setDatosCocedor({});
        debugPrint('Error en fetchCocedoresProcesos: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en fetchCocedoresProcesos: $e');
    }
  }

  //Funcion para obtener los flujos de los cocedores
  Future<void> fetchFlujosCocedores() async {
    try {
      final res = await ApiClient.get(
        'zonagris/funciones/cocedores/obtener-flujo',
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)[0];
        debugPrint('Flujos de cocedores: $data');
        setFlujosCocedores(data);
      } else {
        setFlujosCocedores({});
        debugPrint('Error en fetchFlujosCocedores: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en fetchFlujosCocedores: $e');
    }
  }

  Future<void> fetchFlujoCocedor(String cocedorId) async {
    try {
      final flujoKey = 'Flujo_cocedor_$cocedorId';
      final flujoPermitido = flujoConfig[flujoKey];
      final flujoStr = _flujosCocedores[flujoKey]?.toString();
      final flujoActual = int.tryParse(flujoStr ?? '0') ?? 0;

      int min = flujoPermitido[0];
      int max = flujoPermitido[1];

      final isValid = flujoActual >= min && flujoActual <= max;

      setFlujoCocedor({
        'flujo': flujoActual,
        'permitido': flujoPermitido,
        'isValid': isValid,
      });
    } catch (e) {
      debugPrint('Error en fetchFlujoCocedor: $e');
    }
  }

  Future<void> fetchTemperaturaCocedor() async {
    try {
      final res = await ApiClient.get(
        'zonagris/funciones/cocedores/obtener-temperatura',
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)[0];
        debugPrint('Temperatura de cocedor: $data');
        final entrada =
            int.tryParse(data['COCEDORES_TEMPERATURA_DE_ENTRADA']) ?? 0;
        final salida =
            int.tryParse(data['COCEDORES_TEMPERATURA_DE_SALIDA']) ?? 0;

        final temperaturas = {
          'Temperatura_entrada': {
            'valor': entrada,
            'isValid':
                (entrada > temperaturaConfig['Temperatura_entrada'][0] &&
                entrada < temperaturaConfig['Temperatura_entrada'][1]),
          },
          'Temperatura_salida': {
            'valor': salida,
            'isValid':
                (salida > temperaturaConfig['Temperatura_salida'][0] &&
                salida < temperaturaConfig['Temperatura_salida'][1]),
          },
        };

        debugPrint('Temperaturas: $temperaturas');
        setTemperaturaCocedor(temperaturas);
      } else {
        setTemperaturaCocedor({});
        debugPrint('Error en fetchTemperaturaCocedor: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en fetchTemperaturaCocedor: $e');
    }
  }

  Future<bool> enviarRegistroCocedor(Map<String, dynamic> valores) async {
    try {
      final payload = {
        "relacion_id": valores["relacion_id"] ?? 0,
        "fecha_hora":
            valores["fecha_registro"] ?? DateTime.now().toIso8601String(),
        "usuario_id": valores["usuario_id"] ?? 0,
        "responsable_tipo": valores["responsable_tipo"] ?? "OPERADOR",
        "tipo_registro": valores["tipo_registro"] ?? "operacion",
        "param_agua": valores["flujo"] ?? 0.0,
        "param_temp_entrada": valores["temperatura_entrada"] ?? 0.0,
        "param_temp_salida": valores["temperatura_salida"] ?? 0.0,
        "param_solidos": valores["solidos"] ?? 0.0,
        "param_ph": valores["ph"] ?? 0.0,
        "param_ntu": valores["ntu"] ?? 0.0,
        "peso_consumido": valores["carga_cuero"] ?? 0.0,
        "muestra_tomada":
            (valores["muestra_tomada"] ?? "").toString().toLowerCase() == "si",
        "observaciones": valores["observaciones"] ?? "",
        "agitacion": valores["agitacion"] ?? "No",
        "desengrasador": valores["desengrasador"] ?? "No",
      };

      log('📤 Payload registro cocedor: ${jsonEncode(payload)}');

      final res = await ApiClient.post(
        "zonagris/funciones/cocedores/registro-horario",
        payload,
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error al enviar registro de cocedor: $e');
      return false;
    }
  }

  String _nombreCampoLegible(String clave) {
    const nombres = {
      "solidos": "% Sólidos",
      "ph": "pH",
      "ntu": "NTU",
      "carga_cuero": "Carga de Cuero",
      "flujo": "Flujo de Agua",
      "temperatura_entrada": "Temperatura de Entrada",
      "temperatura_salida": "Temperatura de Salida",
    };
    return nombres[clave] ?? clave;
  }

  Future<bool> enviarAlertaCocedor(Map<String, dynamic> valores) async {
    try {
      final validaciones = valores["validaciones_completas"] ?? {};
      final campos = validaciones["campos_editables"] ?? {};
      final cocedor = valores["cocedor_nombre"] ?? "Desconocido";
      final responsable = valores["operador"] ?? "Desconocido";

      final List<Map<String, String>> facts = [];

      campos.forEach((key, campo) {
        if (campo["valido"] == false) {
          facts.add({"titulo": "Cocedor", "valor": cocedor});
          facts.add({"titulo": "Parámetro", "valor": _nombreCampoLegible(key)});
          facts.add({"titulo": "Valor", "valor": campo["valor"].toString()});
          facts.add({
            "titulo": "Rango",
            "valor":
                "${campo["rango_recomendado"][0]} - ${campo["rango_recomendado"][1]}",
          });
          facts.add({"titulo": "Responsable", "valor": responsable});
        }
      });

      if (facts.isEmpty) {
        debugPrint("✅ No se generó alerta: todos los parámetros válidos.");
        return false;
      }

      final payload = {
        "titulo": "🚨 Parámetros fuera o cerca del rango permitido",
        "fecha": DateTime.now().toString().substring(0, 16),
        "facts": facts,
      };

      log("📤 Payload alerta cocedor: ${jsonEncode(payload)}");

      final res = await ApiClient.post("alertas/enviar", payload);

      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error al enviar alerta: $e');
      return false;
    }
  }

  void reset() {
    _datosCocedor = {};
    _flujoCocedor = {};
    _flujosCocedores = {};
    _temperaturaCocedor = {};
    notifyListeners();
  }
}
