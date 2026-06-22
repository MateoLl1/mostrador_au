class AppSession {
  final int usCodigo;
  final String usNombre;
  final String usLogin;
  final String usPassword; // plain text — used for session re-validation on startup
  final String puModulo;
  final int agenciaId;
  final String agenciaNombre;

  const AppSession({
    required this.usCodigo,
    required this.usNombre,
    required this.usLogin,
    required this.usPassword,
    required this.puModulo,
    required this.agenciaId,
    required this.agenciaNombre,
  });

  factory AppSession.fromJson(Map<String, dynamic> json) => AppSession(
        usCodigo: (json['usCodigo'] as num).toInt(),
        usNombre: json['usNombre'] as String,
        usLogin: json['usLogin'] as String,
        usPassword: json['usPassword'] as String,
        puModulo: json['puModulo'] as String,
        agenciaId: (json['agenciaId'] as num).toInt(),
        agenciaNombre: json['agenciaNombre'] as String,
      );

  Map<String, dynamic> toJson() => {
        'usCodigo': usCodigo,
        'usNombre': usNombre,
        'usLogin': usLogin,
        'usPassword': usPassword,
        'puModulo': puModulo,
        'agenciaId': agenciaId,
        'agenciaNombre': agenciaNombre,
      };
}
