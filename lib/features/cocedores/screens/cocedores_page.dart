import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zona_gris_mobile/app/router_provider.dart';
import 'package:zona_gris_mobile/auth/providers/auth_provider.dart';
import 'package:zona_gris_mobile/features/cocedores/providers/cocedores_providers.dart';
import 'package:zona_gris_mobile/shared/widgets/session_timer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CocedorSelectionScreen extends StatefulWidget {
  const CocedorSelectionScreen({super.key});

  @override
  State<CocedorSelectionScreen> createState() => _CocedorSelectionScreenState();
}

class _CocedorSelectionScreenState extends State<CocedorSelectionScreen> {
  final Color primaryColor = const Color(0xFF3498DB);
  final Color primaryDarkColor = const Color(0xFF1A5D8E);
  final Color accentColor = const Color(0xFF4FC3F7);
  final Color surfaceColor = const Color(0xFFF8F9FA);
  final Color errorColor = const Color(0xFFD32F2F);
  final Color warningColor = const Color(0xFFFFA000);
  final Color successColor = const Color(0xFF388E3C);
  final Color disabledColor = const Color(0xFF9E9E9E);
  final Color maintenanceColor = const Color(0xFFF57C00);
  final Color firstTimeColor = const Color(0xFF9C27B0);
  final Color supervisorColor = const Color(
    0xFF7B1FA2,
  ); // Color para supervisor
  String? _cocedorSeleccionadoId;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      final cocedoresProvider = Provider.of<CocedoresProvider>(
        context,
        listen: false,
      );
      cocedoresProvider.fetchCocedores();
    });
  }

  Future<void> _refreshCocedores() async {
    try {
      final cocedoresProvider = Provider.of<CocedoresProvider>(
        context,
        listen: false,
      );
      await cocedoresProvider.fetchCocedores();

      if (_cocedorSeleccionadoId != null) {
        final cocedores = cocedoresProvider.cocedores;
        final cocedorExists = cocedores.any(
          (c) => c['cocedor_id'] == _cocedorSeleccionadoId,
        );

        if (!cocedorExists) {
          setState(() {
            _cocedorSeleccionadoId = null;
          });
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $error'),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  List<Map<String, dynamic>> procesarYReducirMateriales(String materialesStr) {
    if (materialesStr.isEmpty) return [];

    final List<Map<String, dynamic>> materiales = materialesStr.split(',').map((
      e,
    ) {
      final partes = e.trim().split('(');
      final nombre = partes[0].trim();
      final cantidadStr = partes.length > 1
          ? partes[1].replaceAll(')', '').replaceAll('kg', '').trim()
          : '0';
      final cantidad = double.tryParse(cantidadStr) ?? 0.0;

      return {'nombre': nombre, 'cantidad': cantidad};
    }).toList();

    final Map<String, double> acumulados = {};

    for (var m in materiales) {
      final nombre = m['nombre'];
      final cantidad = m['cantidad'];

      acumulados[nombre] = (acumulados[nombre] ?? 0) + cantidad;
    }

    return acumulados.entries
        .map((e) => {'nombre': e.key, 'cantidad': e.value})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final cocedoresProvider = context.watch<CocedoresProvider>();
    final cocedores = cocedoresProvider.cocedores;
    final isLoading = cocedoresProvider.isLoading;

    // Obtener el perfil del usuario
    final userProfile = auth.user?.perfil ?? 'operador zona gris';
    final bool esSupervisor =
        userProfile == 'admin' || userProfile == 'supervisor extraccion';

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
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () {
                  context.read<RouterProvider>().goTo(AppRoute.home);
                },
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SessionTimer(),
                ),
              ],
              title: Text(
                esSupervisor ? 'Validar Cocedores' : 'Seleccionar Cocedor',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
              ),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
            ),
            body: isLoading && cocedores.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF3498DB),
                          ),
                          strokeWidth: 4,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Cargando cocedores...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    color: isDark ? Colors.grey[900] : surfaceColor,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08),
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  color: primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  esSupervisor
                                      ? 'Valide cocedores para permitir su uso en registros'
                                      : 'Seleccione un cocedor para continuar con el registro',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _refreshCocedores,
                            color: primaryColor,
                            backgroundColor: surfaceColor,
                            strokeWidth: 3,
                            displacement: 40,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  if (isLoading && cocedores.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 20,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    primaryColor,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            'Actualizando cocedores...',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 20,
                                          mainAxisSpacing: 20,
                                          childAspectRatio: 1.0,
                                        ),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: cocedores.length,
                                    itemBuilder: (context, index) {
                                      final cocedor = cocedores[index];
                                      final bool seleccionado =
                                          _cocedorSeleccionadoId ==
                                          cocedor['cocedor_id'];
                                      final bool activo =
                                          cocedor['estatus'] == 'ACTIVO';
                                      final bool enMantenimiento =
                                          cocedor['estatus'] == 'MANTENIMIENTO';
                                      final dynamic validadoSupervisorValue =
                                          cocedor['supervisor_validado'];
                                      final bool validadoSupervisor =
                                          validadoSupervisorValue == '1' ||
                                          validadoSupervisorValue == true;
                                      final String? fechaRegistro =
                                          cocedor['fecha_registro']?.toString();
                                      final bool esPrimerRegistro =
                                          fechaRegistro == null ||
                                          fechaRegistro.isEmpty;

                                      // Lógica invertida para supervisor
                                      final bool puedeSeleccionar;
                                      if (esSupervisor) {
                                        // Supervisor puede seleccionar cocedores ACTIVOS que NO estén validados
                                        puedeSeleccionar =
                                            activo &&
                                            !validadoSupervisor &&
                                            !esPrimerRegistro;
                                      } else {
                                        // Operador normal: puede seleccionar cocedores ACTIVOS que estén validados o sean primer registro
                                        puedeSeleccionar =
                                            activo &&
                                            (esPrimerRegistro ||
                                                validadoSupervisor);
                                      }

                                      return _buildCocedorCard(
                                        cocedor: cocedor,
                                        seleccionado: seleccionado,
                                        activo: activo,
                                        enMantenimiento: enMantenimiento,
                                        validadoSupervisor: validadoSupervisor,
                                        esPrimerRegistro: esPrimerRegistro,
                                        puedeSeleccionar: puedeSeleccionar,
                                        esSupervisor: esSupervisor,
                                        onTap: puedeSeleccionar
                                            ? () {
                                                setState(() {
                                                  _cocedorSeleccionadoId =
                                                      cocedor['cocedor_id'];
                                                });
                                              }
                                            : null,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: primaryColor.withValues(
                                          alpha: 0.2,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline_rounded,
                                              color: primaryColor,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Información de estados',
                                              style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        if (esSupervisor) ...[
                                          _buildStatusInfoRow(
                                            'ACTIVO sin validar',
                                            'Disponible para validación',
                                            supervisorColor,
                                            Icons.verified_user,
                                          ),
                                          _buildStatusInfoRow(
                                            'ACTIVO y Validado',
                                            'Ya validado previamente',
                                            successColor,
                                            Icons.check_circle,
                                          ),
                                        ] else ...[
                                          _buildStatusInfoRow(
                                            'ACTIVO (Primer registro)',
                                            'Disponible para selección',
                                            firstTimeColor,
                                            Icons.stars_rounded,
                                          ),
                                          _buildStatusInfoRow(
                                            'ACTIVO y Validado',
                                            'Disponible para selección',
                                            successColor,
                                            Icons.check_circle,
                                          ),
                                          _buildStatusInfoRow(
                                            'ACTIVO sin validar',
                                            'Esperando validación de supervisor',
                                            warningColor,
                                            Icons.pending,
                                          ),
                                        ],
                                        _buildStatusInfoRow(
                                          'MANTENIMIENTO',
                                          'No disponible temporalmente',
                                          maintenanceColor,
                                          Icons.build,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _cocedorSeleccionadoId != null
                                          ? () {
                                              final cocedorSeleccionado =
                                                  cocedores.firstWhere(
                                                    (c) =>
                                                        c['cocedor_id'] ==
                                                        _cocedorSeleccionadoId,
                                                  );
                                              final cocedorId =
                                                  cocedorSeleccionado['cocedor_id'];
                                              cocedoresProvider.setCocedorId(
                                                cocedorId,
                                              );

                                              if (esSupervisor) {
                                                // Para supervisor, ir a pantalla de validación
                                                Provider.of<RouterProvider>(
                                                  context,
                                                  listen: false,
                                                ).goTo(
                                                  AppRoute.validacionCocedor,
                                                );
                                              } else {
                                                // Para operador, ir a pantalla de registro normal
                                                Provider.of<RouterProvider>(
                                                  context,
                                                  listen: false,
                                                ).goTo(
                                                  AppRoute.registroCocedor,
                                                );
                                              }
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _cocedorSeleccionadoId != null
                                            ? primaryColor
                                            : Colors.grey.shade400,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 2,
                                        shadowColor: primaryColor.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                      child: Text(
                                        esSupervisor
                                            ? 'Continuar a Validación'
                                            : 'Continuar al Registro',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusInfoRow(
    String title,
    String description,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCocedorCard({
    required Map<String, dynamic> cocedor,
    required bool seleccionado,
    required bool activo,
    required bool enMantenimiento,
    required bool validadoSupervisor,
    required bool esPrimerRegistro,
    required bool puedeSeleccionar,
    required bool esSupervisor,
    required VoidCallback? onTap,
  }) {
    final materialesOb = cocedor['materiales'] ?? '';
    final materiales = procesarYReducirMateriales(materialesOb);
    final nombreMateriales = materiales
        .map((m) => m['nombre'])
        .toSet()
        .toList();

    final Color cardColor = puedeSeleccionar
        ? Colors.white
        : Colors.grey.shade100.withValues(alpha: 0.7);
    final Color borderColor = seleccionado
        ? primaryColor
        : !puedeSeleccionar
        ? disabledColor.withValues(alpha: 0.4)
        : Colors.grey.shade200;
    final Color textColor = puedeSeleccionar ? Colors.black87 : disabledColor;

    Color estadoColor;
    String estadoText = cocedor['estatus'];

    if (enMantenimiento) {
      estadoColor = maintenanceColor;
    } else if (esPrimerRegistro) {
      estadoColor = firstTimeColor;
      estadoText = 'PRIMER REGISTRO';
    } else if (validadoSupervisor) {
      estadoColor = successColor;
      estadoText = esSupervisor ? 'YA VALIDADO' : 'VALIDADO';
    } else if (activo && !validadoSupervisor) {
      estadoColor = esSupervisor ? supervisorColor : warningColor;
      estadoText = esSupervisor ? 'POR VALIDAR' : 'SIN VALIDAR';
    } else {
      estadoColor = disabledColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: seleccionado
                  ? primaryColor.withValues(alpha: 0.2)
                  : Colors.grey.withValues(
                      alpha: puedeSeleccionar ? 0.1 : 0.05,
                    ),
              blurRadius: seleccionado ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: borderColor,
            width: seleccionado ? 2.0 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(
                            alpha: puedeSeleccionar ? 0.1 : 0.05,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          FontAwesomeIcons.fire,
                          size: 22,
                          color: puedeSeleccionar
                              ? primaryColor
                              : disabledColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: estadoColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          estadoText,
                          style: TextStyle(
                            color: estadoColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cocedor['nombre'],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Procesos: ${cocedor['procesos'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (activo && !esPrimerRegistro) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: validadoSupervisor
                            ? successColor.withValues(alpha: 0.1)
                            : (esSupervisor
                                  ? supervisorColor.withValues(alpha: 0.1)
                                  : warningColor.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: validadoSupervisor
                              ? successColor.withValues(alpha: 0.3)
                              : (esSupervisor
                                    ? supervisorColor.withValues(alpha: 0.3)
                                    : warningColor.withValues(alpha: 0.3)),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            validadoSupervisor
                                ? Icons.verified_rounded
                                : (esSupervisor
                                      ? Icons.verified_user
                                      : Icons.pending_rounded),
                            size: 16,
                            color: validadoSupervisor
                                ? successColor
                                : (esSupervisor
                                      ? supervisorColor
                                      : warningColor),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            validadoSupervisor
                                ? 'Validado'
                                : (esSupervisor ? 'Por validar' : 'Pendiente'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: validadoSupervisor
                                  ? successColor
                                  : (esSupervisor
                                        ? supervisorColor
                                        : warningColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (esPrimerRegistro) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: firstTimeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: firstTimeColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            size: 16,
                            color: firstTimeColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Primer registro',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: firstTimeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (nombreMateriales.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: nombreMateriales.map((nombre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(
                              alpha: puedeSeleccionar ? 0.08 : 0.04,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            nombre,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: puedeSeleccionar
                                  ? primaryDarkColor
                                  : disabledColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const Spacer(),
                  if (!esPrimerRegistro) ...[
                    Text(
                      'Último registro: ${cocedor['fecha_registro'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (seleccionado) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        esSupervisor ? 'PARA VALIDAR' : 'SELECCIONADO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ] else if (enMantenimiento) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: maintenanceColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'EN MANTENIMIENTO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: maintenanceColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ] else if (activo &&
                      !validadoSupervisor &&
                      !esPrimerRegistro &&
                      !esSupervisor) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: warningColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PENDIENTE DE VALIDACIÓN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: warningColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ] else if (activo && validadoSupervisor && esSupervisor) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: successColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'YA VALIDADO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: successColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!puedeSeleccionar)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withValues(alpha: 0.03),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
