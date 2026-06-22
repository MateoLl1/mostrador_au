class LoginResponse {
  final int usCodigo;
  final String usNombre;
  final String usLogin;
  final String usPassword;
  final String? puModulo;

  const LoginResponse({
    required this.usCodigo,
    required this.usNombre,
    required this.usLogin,
    required this.usPassword,
    this.puModulo,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      usCodigo:   (json['usCodigo'] as num?)?.toInt() ?? 0,
      usNombre:   json['usNombre']?.toString() ?? '',
      usLogin:    json['usLogin']?.toString() ?? '',
      usPassword: json['usPassword']?.toString() ?? '',
      puModulo:   json['puModulo']?.toString(),
    );
  }
}
