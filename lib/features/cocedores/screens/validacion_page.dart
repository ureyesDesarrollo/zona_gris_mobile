import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zona_gris_mobile/app/router_provider.dart';
import 'package:zona_gris_mobile/auth/providers/auth_provider.dart';
import 'package:zona_gris_mobile/features/cocedores/providers/cocedores_providers.dart';
import 'package:zona_gris_mobile/features/cocedores/providers/validacion_provider.dart';
import 'package:zona_gris_mobile/shared/widgets/dialogs.dart';
import 'package:zona_gris_mobile/shared/widgets/session_timer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ValidacionCocedorScreen extends StatefulWidget {
  const ValidacionCocedorScreen({super.key});

  @override
  State<ValidacionCocedorScreen> createState() =>
      _ValidacionCocedorScreenState();
}

class _ValidacionCocedorScreenState extends State<ValidacionCocedorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _observacionesController =
      TextEditingController();

  // Focus nodes
  final FocusNode _observacionesFocus = FocusNode();
  final FocusNode _validacionFocus = FocusNode();

  // Colores
  final Color primaryColor = const Color(0xFF3498DB);
  final Color primaryLight = const Color(0xFFEBF5FB);
  final Color darkGray = const Color(0xFF666666);
  final Color lightGray = const Color(0xFFF5F5F5);
  final Color errorColor = const Color(0xFFD32F2F);
  final Color warningColor = const Color(0xFFFFA000);
  final Color successColor = const Color(0xFF388E3C);
  final Color infoColor = const Color(0xFF1976D2);

  // Datos del registro a validar
  Map<String, dynamic> _registro = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Ejecutar después del primer build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosRegistro();
    });

    _observacionesFocus.addListener(() {
      setState(() {});
    });
  }

  Future<void> _cargarDatosRegistro() async {
    try {
      final validacionProvider = Provider.of<ValidacionProvider>(
        context,
        listen: false,
      );
      final cocedorId = Provider.of<CocedoresProvider>(
        context,
        listen: false,
      ).cocedorIdSeleccionado;

      if (cocedorId == null) {
        // También después del frame para evitar navegar durante build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context);
        });
        return;
      }

      await validacionProvider.fetchRegistroPendienteValidacion(cocedorId);

      if (!mounted) return;

      // Lee del provider y aplica al estado local UNA sola vez
      final data = validacionProvider.registroPendiente;
      setState(() {
        _registro = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      mostrarSnackbarError(context, 'Error al cargar el registro: $e');
    }
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _observacionesFocus.dispose();
    _validacionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_registro.isEmpty) {
      return _buildEmptyState();
    }

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
              title: const Text('Validación de Cocedor'),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            body: Container(
              color: isDark
                  ? Colors.grey[900]
                  : primaryLight.withValues(alpha: 0.3),
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
                          // Header informativo
                          _buildHeader(),

                          const SizedBox(height: 24),

                          // Card de Información del Registro
                          _buildCard(
                            icon: Icons.description,
                            title: 'Información del Registro',
                            child: Column(
                              children: [
                                _buildReadOnlyField(
                                  label: 'Cocedor',
                                  value:
                                      '${_registro['cocedor']}, ${_registro['agrupacion']}',
                                  icon: FontAwesomeIcons.fire,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildReadOnlyField(
                                        label: 'Fecha registro',
                                        value: _registro['fecha_hora'] ?? 'N/A',

                                        icon: Icons.calendar_today,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildReadOnlyField(
                                        label: 'Operador',
                                        value:
                                            _registro['responsable'] ?? 'N/A',
                                        icon: Icons.person,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildReadOnlyField(
                                  label: 'Modo operación',
                                  value: _getModoOperacionLabel(
                                    _registro['tipo_registro'],
                                  ),
                                  icon: Icons.settings,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Card de Parámetros Técnicos
                          _buildCard(
                            icon: Icons.analytics,
                            title: 'Parámetros Técnicos Registrados',
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildParametroField(
                                        label: '% Sólidos',
                                        value:
                                            _registro['param_solidos']
                                                ?.toString() ??
                                            'N/A',
                                        icon: FontAwesomeIcons.percent,
                                        valido:
                                            _registro['validaciones_completas']?['campos_editables']?['solidos']?['valido'] ??
                                            false,
                                        advertencia:
                                            _registro['validaciones_completas']?['campos_editables']?['solidos']?['advertencia'],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildParametroField(
                                        label: 'Nivel de pH',
                                        value:
                                            _registro['param_ph']?.toString() ??
                                            'N/A',
                                        icon: FontAwesomeIcons.flask,
                                        valido:
                                            _registro['validaciones_completas']?['campos_editables']?['ph']?['valido'] ??
                                            false,
                                        advertencia:
                                            _registro['validaciones_completas']?['campos_editables']?['ph']?['advertencia'],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildParametroField(
                                        label: 'Turbidez (NTU)',
                                        value:
                                            _registro['param_ntu']
                                                ?.toString() ??
                                            'N/A',
                                        icon: FontAwesomeIcons.vial,
                                        valido:
                                            _registro['validaciones_completas']?['campos_editables']?['ntu']?['valido'] ??
                                            false,
                                        advertencia:
                                            _registro['validaciones_completas']?['campos_editables']?['ntu']?['advertencia'],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildReadOnlyField(
                                        label: 'Flujo (LPM)',
                                        value:
                                            _registro['param_agua']
                                                ?.toString() ??
                                            'N/A',
                                        icon: FontAwesomeIcons.droplet,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildReadOnlyField(
                                        label: 'Temp. Entrada (°C)',
                                        value:
                                            _registro['param_temp_entrada']
                                                ?.toString() ??
                                            'N/A',
                                        icon: FontAwesomeIcons.temperatureLow,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildReadOnlyField(
                                        label: 'Temp. Salida (°C)',
                                        value:
                                            _registro['param_temp_salida']
                                                ?.toString() ??
                                            'N/A',
                                        icon: FontAwesomeIcons.temperatureLow,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Card de Estado del Equipo
                          _buildCard(
                            icon: Icons.settings,
                            title: 'Estado del Equipo Registrado',
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildReadOnlyField(
                                        label: 'Observaciones por operador',
                                        value:
                                            _registro['observaciones'] ?? 'N/A',
                                        icon: Icons.check_circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Card de Validación del Supervisor
                          _buildCard(
                            icon: Icons.verified_user,
                            title: 'Validación del Supervisor',
                            child: Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Observaciones del supervisor',
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
                                              : primaryColor.withValues(
                                                  alpha: 0.3,
                                                ),
                                          width: _observacionesFocus.hasFocus
                                              ? 1.5
                                              : 1,
                                        ),
                                        boxShadow: _observacionesFocus.hasFocus
                                            ? [
                                                BoxShadow(
                                                  color: primaryColor
                                                      .withValues(alpha: 0.1),
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
                                              'Ingrese sus observaciones sobre la validación...',
                                          border: InputBorder.none,
                                          filled: true,
                                          fillColor: isDark
                                              ? Colors.grey[800]
                                              : Colors.white,
                                          contentPadding: const EdgeInsets.all(
                                            16,
                                          ),
                                        ),
                                        maxLines: 4,
                                      ),
                                    ),
                                  ],
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

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validación de Cocedor'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Cargando registro...',
              style: TextStyle(fontSize: 18, color: darkGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validación de Cocedor'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: errorColor),
            const SizedBox(height: 20),
            Text(
              'No se encontró registro para validar',
              style: TextStyle(
                fontSize: 18,
                color: darkGray,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'El registro puede haber sido ya validado o no existe',
              style: TextStyle(fontSize: 14, color: darkGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Provider.of<RouterProvider>(
                  context,
                  listen: false,
                ).goTo(AppRoute.home);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Volver al Inicio',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: infoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: infoColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: infoColor, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Validación de Registro de Cocedor',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Revise los parámetros registrados y determine si el registro es válido',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Supervisor: ${Provider.of<AuthProvider>(context, listen: false).user?.usuarioNombre ?? 'N/A'}',
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
            border: Border.all(color: Colors.grey.shade300),
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

  Widget _buildParametroField({
    required String label,
    required String value,
    required IconData icon,
    required bool valido,
    String? advertencia,
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
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: darkGray,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (advertencia != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        advertencia,
                        style: TextStyle(
                          color: warningColor,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                valido ? Icons.check_circle : Icons.warning,
                color: valido ? successColor : warningColor,
                size: 20,
              ),
            ],
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
            onPressed: _submitValidacion,
            style: ElevatedButton.styleFrom(
              backgroundColor: successColor,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              'Validar Registro',
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

  String _getModoOperacionLabel(String? modo) {
    switch (modo) {
      case 'operacion':
        return 'Operación';
      case 'reinicio':
        return 'Reinicio';
      default:
        return modo ?? 'N/A';
    }
  }

  void _submitValidacion() async {
    if (_observacionesController.text.isEmpty) {
      mostrarSnackbarError(context, 'Por favor, ingrese observaciones.');
      return;
    }

    if (_observacionesController.text.length < 15) {
      mostrarSnackbarError(
        context,
        'Por favor, ingrese al menos 15 caracteres.',
      );
      return;
    }
    final confirmado = await mostrarDialogoConfirmacion(
      context: context,
      title: 'Confirmar Validación',
      message: '¿Está seguro de validar este registro?',
    );

    if (confirmado && mounted) {
      try {
        final validacionProvider = Provider.of<ValidacionProvider>(
          context,
          listen: false,
        );

        // Preparar datos para la validación
        final datosValidacion = {
          'detalle_id': _registro['detalle_id'],
          'id': Provider.of<AuthProvider>(context, listen: false).user?.userId,
          'observaciones': _observacionesController.text,
        };

        mostrarSnackbarCargando(context, 'Procesando validación...');

        final success = await validacionProvider.enviarValidacion(
          datosValidacion,
        );

        if (success && mounted) {
          final mensaje = 'Registro validado correctamente';

          mostrarSnackbarExito(context, mensaje);

          // Redirigir a home después de 2 segundos
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Provider.of<RouterProvider>(
                context,
                listen: false,
              ).goTo(AppRoute.home);
            }
          });
        } else if (mounted) {
          mostrarSnackbarError(context, 'Error al procesar la validación');
        }
      } catch (e) {
        if (mounted) {
          mostrarSnackbarError(context, 'Error: ${e.toString()}');
        }
      }
    }
  }
}
