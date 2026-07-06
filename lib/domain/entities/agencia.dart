class Agencia {
  final int agCodigo;
  final String agNombre;

  const Agencia({required this.agCodigo, required this.agNombre});

  @override
  bool operator ==(Object other) =>
      other is Agencia && other.agCodigo == agCodigo;

  @override
  int get hashCode => agCodigo.hashCode;
}
