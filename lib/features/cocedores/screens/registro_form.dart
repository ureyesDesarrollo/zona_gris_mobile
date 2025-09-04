import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zona_gris_mobile/app/router_provider.dart';
import 'package:zona_gris_mobile/auth/providers/auth_provider.dart';
import 'package:zona_gris_mobile/features/cocedores/providers/cocedores_providers.dart';
import 'package:zona_gris_mobile/features/cocedores/providers/registro_provider.dart';
import 'package:zona_gris_mobile/shared/widgets/dialogs.dart';
import 'package:zona_gris_mobile/shared/widgets/session_timer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegistroCocedorScreen extends StatefulWidget {
  const RegistroCocedorScreen({super.key});

  @override
  State<RegistroCocedorScreen> createState() => _RegistroCocedorScreenState();
}

class _RegistroCocedorScreenState extends State<RegistroCocedorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _solidosController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _ntuController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();

  // Focus nodes para manejar el foco correctamente
  final FocusNode _solidosFocus = FocusNode();
  final FocusNode _phFocus = FocusNode();
  final FocusNode _ntuFocus = FocusNode();
  final FocusNode _observacionesFocus = FocusNode();

  String _muestraValue = 'Si';
  String _agitacionValue = 'Si';
  String _desengrasadorValue = 'Si';
  String _modoValue = 'operacion';

  // Colores basados en el tema de la app
  final Color primaryColor = const Color(0xFF3498DB);
  final Color primaryLight = const Color(0xFFEBF5FB);
  final Color darkGray = const Color(0xFF666666);
  final Color lightGray = const Color(0xFFF5F5F5);
  final Color errorColor = const Color(0xFFD32F2F);
  final Color warningColor = const Color(0xFFFFA000);
  final Color successColor = const Color(0xFF388E3C);

  // Definición de validaciones
  final List<Map<String, dynamic>> _validaciones = [
    {'id': 'ph', 'min': 3.0, 'max': 3.8, 'nombre': 'pH'},
    {'id': 'ntu', 'min': 60, 'max': 600, 'nombre': 'NTU'},
    {'id': 'solidos', 'min': 1.5, 'max': 2.8, 'nombre': '% Sólidos'},
    {'id': 'carga-cuero', 'min': 1, 'max': 20000, 'nombre': 'Carga de cuero'},
  ];

  // Mapa para rastrear advertencias de validación (fuera de rango)
  final Map<String, String?> _advertencias = {
    'ph': null,
    'ntu': null,
    'solidos': null,
    'carga-cuero': null,
  };
  @override
  void initState() {
    super.initState();

    final registroProvider = Provider.of<RegistroProvider>(
      context,
      listen: false,
    );
    final cocedorIdSeleccionado = Provider.of<CocedoresProvider>(
      context,
      listen: false,
    ).cocedorIdSeleccionado;

    if (cocedorIdSeleccionado == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    } else {
      Future.microtask(() async {
        await registroProvider.fetchCocedoresProcesos(cocedorIdSeleccionado);
        await registroProvider.fetchFlujosCocedores();
        await registroProvider.fetchFlujoCocedor(cocedorIdSeleccionado);
        await registroProvider.fetchTemperaturaCocedor();
      });
    }

    // Configurar listeners para los focus nodes
    _setupFocusListeners();

    // Poner foco en el campo de carga de cuero después de que la pantalla se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_solidosFocus);
    });
  }

  void _setupFocusListeners() {
    // Listener para el campo de sólidos
    _solidosFocus.addListener(() {
      setState(() {});
    });

    // Listener para el campo de pH
    _phFocus.addListener(() {
      setState(() {});
    });

    // Listener para el campo de NTU
    _ntuFocus.addListener(() {
      setState(() {});
    });

    // Listener para el campo de observaciones
    _observacionesFocus.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose de todos los controllers y focus nodes
    _solidosController.dispose();
    _phController.dispose();
    _ntuController.dispose();
    _observacionesController.dispose();

    _solidosFocus.dispose();
    _phFocus.dispose();
    _ntuFocus.dispose();
    _observacionesFocus.dispose();

    super.dispose();
  }

  // Función para verificar rangos (solo muestra advertencia, no error)
  String? _verificarRango(String value, String campoId) {
    final validacion = _validaciones.firstWhere(
      (v) => v['id'] == campoId,
      orElse: () => {},
    );

    if (validacion.isEmpty) return null;

    final num? min = validacion['min'];
    final num? max = validacion['max'];
    final String nombre = validacion['nombre'];

    try {
      final valorNumerico = double.parse(value.replaceAll(',', '.'));

      if (min != null && valorNumerico < min) {
        return '$nombre está por debajo del rango recomendado ($min - $max)';
      }

      if (max != null && valorNumerico > max) {
        return '$nombre está por encima del rango recomendado ($min - $max)';
      }
    } catch (e) {
      // No es un error crítico, solo mostramos advertencia de formato
      return 'Verifique el formato del valor ingresado';
    }

    return null;
  }

  // Validar todos los campos obligatorios
  bool _validarCamposObligatorios() {
    bool todosCompletos = true;

    // Validar que todos los campos tengan valor

    if (_solidosController.text.isEmpty) {
      todosCompletos = false;
    }

    if (_phController.text.isEmpty) {
      todosCompletos = false;
    }

    if (_ntuController.text.isEmpty) {
      todosCompletos = false;
    }

    // Verificar rangos para mostrar advertencias
    _advertencias['ph'] = _phController.text.isNotEmpty
        ? _verificarRango(_phController.text, 'ph')
        : null;

    _advertencias['ntu'] = _ntuController.text.isNotEmpty
        ? _verificarRango(_ntuController.text, 'ntu')
        : null;

    _advertencias['solidos'] = _solidosController.text.isNotEmpty
        ? _verificarRango(_solidosController.text, 'solidos')
        : null;

    setState(() {}); // Actualizar UI para mostrar advertencias

    return todosCompletos;
  }

  // Función para manejar la navegación entre campos
  void _manejarSiguienteCampo(FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final registroProvider = context.watch<RegistroProvider>();
    final datosCocedor = registroProvider.datosCocedor;
    final flujoCocedor = registroProvider.flujoCocedor;
    final temperaturaCocedor = registroProvider.temperaturaCocedor;

    // CORRECCIÓN: Verificar que temperaturaCocedor no sea null antes de acceder
    final temperaturaEntrada =
        (temperaturaCocedor.containsKey('Temperatura_entrada'))
        ? temperaturaCocedor['Temperatura_entrada'] is Map
              ? (temperaturaCocedor['Temperatura_entrada'] as Map)['valor']
              : null
        : null;

    final temperaturaSalida =
        (temperaturaCocedor.containsKey('Temperatura_salida'))
        ? temperaturaCocedor['Temperatura_salida'] is Map
              ? (temperaturaCocedor['Temperatura_salida'] as Map)['valor']
              : null
        : null;

    // CORRECCIÓN: Verificar que flujoCocedor no sea null antes de acceder
    final flujoValor = (flujoCocedor.containsKey('flujo'))
        ? flujoCocedor['flujo']
        : null;

    final flujoValido = (flujoCocedor.containsKey('isValid'))
        ? flujoCocedor['isValid']
        : false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.read<RouterProvider>().goTo(AppRoute.home);
        }
      },
      child: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.read<RouterProvider>().goTo(AppRoute.home);
                },
              ),
              actions: [
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SessionTimer(),
                ),
              ],
              title: const Text('Registro de Cocedor'),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            body: Container(
              color: isDark ? Colors.grey[900] : primaryLight.withValues(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header informativo con indicaciones
                          _buildHeader(),

                          const SizedBox(height: 24),

                          // Card de Contexto
                          _buildCard(
                            icon: Icons.description,
                            title: 'Información del Registro',
                            child: Column(
                              children: [
                                _buildReadOnlyField(
                                  label: 'Cocedor',
                                  value:
                                      '${datosCocedor['cocedor'] ?? 'N/A'}, ${datosCocedor['agrupacion'] ?? 'N/A'}',
                                  icon: FontAwesomeIcons.fire,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildReadOnlyField(
                                        label: 'Fecha y hora',
                                        value: DateTime.now()
                                            .toString()
                                            .substring(0, 16),
                                        icon: Icons.calendar_today,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildReadOnlyField(
                                        label: 'Operador',
                                        value: user?.usuarioNombre ?? 'N/A',
                                        icon: Icons.person,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Card de Parámetros
                          _buildCard(
                            icon: Icons.analytics,
                            title: 'Parámetros Técnicos',
                            child: Column(
                              children: [
                                _buildReadOnlyField(
                                  label: 'Flujo (LPM)',
                                  value: flujoValor?.toString() ?? 'N/A',
                                  icon: FontAwesomeIcons.droplet,
                                  isValid: flujoValido,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildReadOnlyField(
                                        label: 'Temperatura Entrada (°C)',
                                        value:
                                            temperaturaEntrada?.toString() ??
                                            'N/A',
                                        icon: FontAwesomeIcons.temperatureLow,
                                        // CORRECCIÓN: Verificación segura de isValid
                                        isValid:
                                            (temperaturaCocedor.containsKey(
                                                  'Temperatura_entrada',
                                                ) &&
                                                temperaturaCocedor['Temperatura_entrada']
                                                    is Map)
                                            ? (temperaturaCocedor['Temperatura_entrada']
                                                      as Map)['isValid'] ??
                                                  false
                                            : false,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildReadOnlyField(
                                        label: 'Temperatura Salida (°C)',
                                        value:
                                            temperaturaSalida?.toString() ??
                                            'N/A',
                                        icon: FontAwesomeIcons.temperatureLow,
                                        // CORRECCIÓN: Verificación segura de isValid
                                        isValid:
                                            (temperaturaCocedor.containsKey(
                                                  'Temperatura_salida',
                                                ) &&
                                                temperaturaCocedor['Temperatura_salida']
                                                    is Map)
                                            ? (temperaturaCocedor['Temperatura_salida']
                                                      as Map)['isValid'] ??
                                                  false
                                            : false,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildEditableField(
                                        controller: _solidosController,
                                        focusNode: _solidosFocus,
                                        label: '%Solidos *',
                                        icon: FontAwesomeIcons.percent,
                                        isDark: isDark,
                                        campoId: 'solidos',
                                        advertenciaText:
                                            _advertencias['solidos'],
                                        esRequerido: true,
                                        unidad: '%',
                                        nextFocus: _phFocus,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildEditableField(
                                        controller: _phController,
                                        focusNode: _phFocus,
                                        label: 'Nivel de pH *',
                                        icon: FontAwesomeIcons.flask,
                                        isDark: isDark,
                                        campoId: 'ph',
                                        advertenciaText: _advertencias['ph'],
                                        esRequerido: true,
                                        nextFocus: _ntuFocus,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildEditableField(
                                        controller: _ntuController,
                                        focusNode: _ntuFocus,
                                        label: 'Turbidez (NTU) *',
                                        icon: FontAwesomeIcons.vial,
                                        isDark: isDark,
                                        campoId: 'ntu',
                                        advertenciaText: _advertencias['ntu'],
                                        esRequerido: true,
                                        unidad: 'NTU',
                                        nextFocus: _observacionesFocus,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Card de Estado
                          _buildCard(
                            icon: Icons.settings,
                            title: 'Estado del Equipo',
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildRadioGroup(
                                        label: 'Muestra tomada',
                                        value: _muestraValue,
                                        options: const ['Si', 'No'],
                                        onChanged: (value) {
                                          setState(() {
                                            _muestraValue = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildToggleGroup(
                                        label: 'Agitación',
                                        value: _agitacionValue,
                                        options: const ['Si', 'No'],
                                        onChanged: (value) {
                                          setState(() {
                                            _agitacionValue = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildToggleGroup(
                                        label: 'Desengrasador',
                                        value: _desengrasadorValue,
                                        options: const ['Si', 'No'],
                                        onChanged: (value) {
                                          setState(() {
                                            _desengrasadorValue = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildRadioGroup(
                                        label: 'Modo operación',
                                        value: _modoValue,
                                        options: const [
                                          'operacion',
                                          'reinicio',
                                        ],
                                        labels: const ['Operación', 'Reinicio'],
                                        onChanged: (value) {
                                          setState(() {
                                            _modoValue = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Card de Observaciones
                          _buildCard(
                            icon: Icons.notes,
                            title: 'Observaciones y Notas',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Observaciones',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: darkGray,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(
                                      color: _observacionesFocus.hasFocus
                                          ? primaryColor
                                          : primaryColor.withOpacity(0.3),
                                      width: _observacionesFocus.hasFocus
                                          ? 1.5
                                          : 1,
                                    ),
                                    boxShadow: _observacionesFocus.hasFocus
                                        ? [
                                            BoxShadow(
                                              color: primaryColor.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: TextFormField(
                                    controller: _observacionesController,
                                    focusNode: _observacionesFocus,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Registre cualquier observación relevante...',
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.grey[800]
                                          : Colors.white,
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                    maxLines: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Botones de acción
                          _buildActionButtons(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: primaryColor, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Complete todos los campos obligatorios (*)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Los valores fuera de rango se marcarán como advertencia pero podrán guardarse',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Rangos recomendados: pH (3.0 - 3.8), NTU (60 - 600), % Sólidos (1.5 - 2.8), Carga de cuero (1 - 20000)',
            style: TextStyle(
              fontSize: 12,
              color: darkGray,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: primaryColor.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: darkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    bool isValid = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGray,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: lightGray,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: isValid ? Colors.grey.shade300 : errorColor,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(color: darkGray, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioGroup({
    required String label,
    required String value,
    required List<String> options,
    List<String>? labels,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGray,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: lightGray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return RadioListTile<String>(
                title: Text(
                  labels != null && labels.length > index
                      ? labels[index]
                      : option,
                  style: TextStyle(color: darkGray, fontSize: 15),
                ),
                value: option,
                groupValue: value,
                onChanged: onChanged,
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: primaryColor,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleGroup({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGray,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: lightGray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: options.map((option) {
              final isSelected = value == option;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? Colors.white : darkGray,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Provider.of<RouterProvider>(
              context,
              listen: false,
            ).goTo(AppRoute.home),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: BorderSide(color: primaryColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Guardar Registro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required bool isDark,
    required String campoId,
    required String? advertenciaText,
    required bool esRequerido,
    String? unidad,
    FocusNode? nextFocus, // FocusNode para el siguiente campo
  }) {
    final tieneAdvertencia = advertenciaText != null;
    final tieneValor = controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: darkGray,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: tieneAdvertencia
                  ? warningColor
                  : focusNode.hasFocus
                  ? primaryColor
                  : Colors.grey.shade300,
              width: tieneAdvertencia || focusNode.hasFocus ? 1.5 : 1,
            ),
            boxShadow: focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.white,
                  contentPadding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    unidad != null ? 48 : 16,
                    16,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(icon, color: primaryColor),
                  ),
                  // Solo mostrar error si el campo es requerido y está vacío
                  errorText: esRequerido && controller.text.isEmpty
                      ? 'Este campo es obligatorio'
                      : null,
                  errorStyle: TextStyle(color: errorColor, fontSize: 12),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                maxLength: 4,

                textInputAction: nextFocus != null
                    ? TextInputAction.next
                    : TextInputAction.done,
                onChanged: (value) {
                  // Validación en tiempo real para advertencias de rango
                  if (value.isNotEmpty) {
                    final advertencia = _verificarRango(value, campoId);
                    setState(() {
                      _advertencias[campoId] = advertencia;
                    });
                  } else {
                    setState(() {
                      _advertencias[campoId] = null;
                    });
                  }
                },
                onFieldSubmitted: nextFocus != null
                    ? (_) => _manejarSiguienteCampo(focusNode, nextFocus)
                    : null,
              ),
              // Indicador de unidad (si se proporciona)
              if (unidad != null)
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      unidad,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              // Indicador de estado (check o advertencia)
              if (tieneValor)
                Positioned(
                  right: unidad != null ? 50 : 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Icon(
                      tieneAdvertencia
                          ? Icons.warning_amber
                          : Icons.check_circle,
                      color: tieneAdvertencia ? warningColor : successColor,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Mostrar advertencia de rango (si existe) debajo del campo
        if (advertenciaText != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: warningColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    advertenciaText,
                    style: TextStyle(color: warningColor, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Método para obtener todos los valores del formulario con validaciones
  Map<String, dynamic> _obtenerValoresParaAPI() {
    final cocedoresProvider = Provider.of<CocedoresProvider>(
      context,
      listen: false,
    );
    final registroProvider = Provider.of<RegistroProvider>(
      context,
      listen: false,
    );

    final datosCocedor = registroProvider.datosCocedor;
    final flujoCocedor = registroProvider.flujoCocedor;
    final temperaturaCocedor = registroProvider.temperaturaCocedor;

    // Obtener el ID del cocedor para las validaciones
    final cocedorId = cocedoresProvider.cocedorIdSeleccionado;
    final relacionId = datosCocedor['relacion_id'];
    final flujoKey = 'Flujo_cocedor_$cocedorId';

    return {
      // Información básica del registro
      'relacion_id': relacionId,
      'fecha_registro': DateTime.now().toIso8601String(),
      'usuario_id': Provider.of<AuthProvider>(
        context,
        listen: false,
      ).user?.userId,
      'operador': Provider.of<AuthProvider>(
        context,
        listen: false,
      ).user?.usuarioNombre,
      'responsable_tipo': 'OPERADOR',
      'tipo_registro': _modoValue,
      // Parámetros técnicos (valores editables)
      'solidos': double.tryParse(_solidosController.text) ?? 0.0,
      'ph': double.tryParse(_phController.text) ?? 0.0,
      'ntu': double.tryParse(_ntuController.text) ?? 0.0,

      // Parámetros automáticos (de los providers) con validaciones
      'flujo': flujoCocedor['flujo'] ?? 0.0,
      'flujo_configuracion': registroProvider.flujoConfig[flujoKey] ?? [0, 0],
      'flujo_valido': flujoCocedor['isValid'] ?? false,

      'temperatura_entrada':
          temperaturaCocedor.containsKey('Temperatura_entrada')
          ? temperaturaCocedor['Temperatura_entrada']['valor']
          : 0.0,
      'temperatura_entrada_configuracion':
          registroProvider.temperaturaConfig['Temperatura_entrada'] ?? [0, 0],
      'temperatura_entrada_valida':
          temperaturaCocedor.containsKey('Temperatura_entrada')
          ? temperaturaCocedor['Temperatura_entrada']['isValid']
          : false,

      'temperatura_salida': temperaturaCocedor.containsKey('Temperatura_salida')
          ? temperaturaCocedor['Temperatura_salida']['valor']
          : 0.0,
      'temperatura_salida_configuracion':
          registroProvider.temperaturaConfig['Temperatura_salida'] ?? [0, 0],
      'temperatura_salida_valida':
          temperaturaCocedor.containsKey('Temperatura_salida')
          ? temperaturaCocedor['Temperatura_salida']['isValid']
          : false,

      // Estado del equipo
      'muestra_tomada': _muestraValue,
      'agitacion': _agitacionValue,
      'desengrasador': _desengrasadorValue,
      'modo_operacion': _modoValue,

      // Observaciones
      'observaciones': _observacionesController.text.isEmpty
          ? 'N/A'
          : _observacionesController.text,

      // Metadata adicional
      'cocedor_nombre': datosCocedor['cocedor'] ?? 'Desconocido',
      'agrupacion': datosCocedor['agrupacion'] ?? 'Desconocida',

      // Validaciones completas
      'validaciones_completas': _obtenerEstadoValidacionesCompleto(
        registroProvider,
        cocedorId,
      ),
    };
  }

  // Método para obtener el estado completo de todas las validaciones
  Map<String, dynamic> _obtenerEstadoValidacionesCompleto(
    RegistroProvider registroProvider,
    String? cocedorId,
  ) {
    final flujoKey = 'Flujo_cocedor_${cocedorId ?? 0}';
    final flujoConfig = registroProvider.flujoConfig[flujoKey] ?? [0, 0];
    final temperaturaConfig = registroProvider.temperaturaConfig;

    final flujoCocedor = registroProvider.flujoCocedor;
    final temperaturaCocedor = registroProvider.temperaturaCocedor;

    return {
      // Validaciones de campos editables
      'campos_editables': {
        'solidos': {
          'valor': double.tryParse(_solidosController.text) ?? 0.0,
          'valido': _advertencias['solidos'] == null,
          'advertencia': _advertencias['solidos'],
          'rango_recomendado': [1.5, 2.8],
        },
        'ph': {
          'valor': double.tryParse(_phController.text) ?? 0.0,
          'valido': _advertencias['ph'] == null,
          'advertencia': _advertencias['ph'],
          'rango_recomendado': [3.0, 3.8],
        },
        'ntu': {
          'valor': double.tryParse(_ntuController.text) ?? 0.0,
          'valido': _advertencias['ntu'] == null,
          'advertencia': _advertencias['ntu'],
          'rango_recomendado': [60, 600],
        },
      },

      // Validaciones de flujo
      'flujo': {
        'valor': flujoCocedor['flujo'] ?? 0.0,
        'valido': flujoCocedor['isValid'] ?? false,
        'rango_permitido': flujoConfig,
        'configuracion_key': flujoKey,
      },

      // Validaciones de temperatura
      'temperatura': {
        'entrada': {
          'valor': temperaturaCocedor.containsKey('Temperatura_entrada')
              ? temperaturaCocedor['Temperatura_entrada']['valor']
              : 0.0,
          'valido': temperaturaCocedor.containsKey('Temperatura_entrada')
              ? temperaturaCocedor['Temperatura_entrada']['isValid']
              : false,
          'rango_permitido': temperaturaConfig['Temperatura_entrada'] ?? [0, 0],
        },
        'salida': {
          'valor': temperaturaCocedor.containsKey('Temperatura_salida')
              ? temperaturaCocedor['Temperatura_salida']['valor']
              : 0.0,
          'valido': temperaturaCocedor.containsKey('Temperatura_salida')
              ? temperaturaCocedor['Temperatura_salida']['isValid']
              : false,
          'rango_permitido': temperaturaConfig['Temperatura_salida'] ?? [0, 0],
        },
      },

      // Estado general de validación
      'todo_valido': _esRegistroCompletamenteValido(),
    };
  }

  // Método para verificar si todo el registro es válido
  bool _esRegistroCompletamenteValido() {
    final registroProvider = Provider.of<RegistroProvider>(
      context,
      listen: false,
    );
    final flujoCocedor = registroProvider.flujoCocedor;
    final temperaturaCocedor = registroProvider.temperaturaCocedor;

    // Verificar campos editables
    final camposEditablesValidos = _advertencias.values.every(
      (advertencia) => advertencia == null,
    );

    // Verificar que todos los campos tengan valor
    final camposCompletos =
        _solidosController.text.isNotEmpty &&
        _phController.text.isNotEmpty &&
        _ntuController.text.isNotEmpty;

    // Verificar flujo
    final flujoValido = flujoCocedor['isValid'] ?? false;

    // Verificar temperaturas
    final temperaturaEntradaValida =
        temperaturaCocedor.containsKey('Temperatura_entrada')
        ? temperaturaCocedor['Temperatura_entrada']['isValid']
        : false;
    final temperaturaSalidaValida =
        temperaturaCocedor.containsKey('Temperatura_salida')
        ? temperaturaCocedor['Temperatura_salida']['isValid']
        : false;

    return camposEditablesValidos &&
        camposCompletos &&
        flujoValido &&
        temperaturaEntradaValida &&
        temperaturaSalidaValida;
  }

  // Método modificado _submitForm para enviar a la API
  void _submitForm() async {
    if (double.tryParse(_ntuController.text)!.toDouble() > 1000) {
      mostrarSnackbarError(
        context,
        'El campo NTU debe tener un valor menor o igual a 1000',
      );
      return;
    }
    FocusScope.of(context).unfocus();
    if (_validarCamposObligatorios()) {
      // Mostrar diálogo de confirmación antes de guardar
      final confirmado = await mostrarDialogoConfirmacion(
        context: context,
        title: 'Guardar registro',
        message: '¿Estás seguro de que deseas guardar este registro?',
      );

      if (confirmado && mounted) {
        try {
          // Obtener los valores del formulario
          final valores = _obtenerValoresParaAPI();

          // Mostrar indicador de carga
          mostrarSnackbarCargando(context, 'Enviando datos...');

          // Enviar a la API a través del provider
          final registroProvider = Provider.of<RegistroProvider>(
            context,
            listen: false,
          );
          final success = await registroProvider.enviarRegistroCocedor(valores);

          if (valores['validaciones_completas']['todo_valido'] == false) {
            final alertaSuccess = await registroProvider.enviarAlertaCocedor(
              valores,
            );
            if (alertaSuccess && mounted) {
              mostrarSnackbarExito(context, 'Alerta enviada correctamente');
            }
          }

          if (success && mounted) {
            // Éxito
            final mensaje = 'Registro guardado correctamente';
            mostrarSnackbarExito(context, mensaje);
            Provider.of<RouterProvider>(
              context,
              listen: false,
            ).goTo(AppRoute.home);
          } else if (mounted) {
            // Error
            mostrarSnackbarError(context, 'Error al guardar el registro');
          }
        } catch (e) {
          if (mounted) {
            mostrarSnackbarError(context, 'Error: ${e.toString()}');
          }
        }
      }
    } else {
      // Mostrar mensaje de error por campos obligatorios
      mostrarSnackbarError(context, 'Complete todos los campos obligatorios');

      // Desplazar hasta el primer error
      Scrollable.ensureVisible(
        _formKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}
