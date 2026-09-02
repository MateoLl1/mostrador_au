/// Error esperado por mal uso del usuario (ej. "ya tiene un turno en
/// proceso"), no una falla de la app -- la API lo devuelve como 409 con un
/// mensaje ya listo para mostrar. Se maneja como snackbar, nunca como la
/// pantalla de error de pantallaTurnosProvider.
class TurnoConflictException implements Exception {
  final String mensaje;

  const TurnoConflictException(this.mensaje);

  @override
  String toString() => mensaje;
}
