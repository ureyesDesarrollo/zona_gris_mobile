class User {
  String userId;
  String usuario;
  String usuarioNombre;
  String perfil;
  Map<String, List<Permiso>> permisos;

  User({
    required this.userId,
    required this.usuario,
    required this.usuarioNombre,
    required this.perfil,
    required this.permisos,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      usuario: json['usuario'],
      usuarioNombre: json['usuario_nombre'],
      perfil: json['perfil'].toString().toLowerCase(),
      permisos: (json['permisos'] as Map<String, dynamic>).map((
        modulo,
        listaPermisos,
      ) {
        return MapEntry(
          modulo,
          (listaPermisos as List)
              .map(
                (p) => Permiso.values.firstWhere(
                  (e) => e.name == p,
                  orElse: () => throw Exception('Permiso inválido: $p'),
                ),
              )
              .toList(),
        );
      }),
    );
  }

  @override
  String toString() {
    return 'User(userId: $userId, usuario: $usuario, usuarioNombre: $usuarioNombre, perfil: $perfil, permisos: $permisos)';
  }
}

enum Permiso { agregar, borrar, editar, listar }
