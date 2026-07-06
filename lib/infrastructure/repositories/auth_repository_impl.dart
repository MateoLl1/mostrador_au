import 'package:mostrador_au/domain/domain.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl({required this.datasource});

  @override
  Future<LoginResponse> login({required String login, required String password, required int agenciaId}) {
    return datasource.login(login: login, password: password, agenciaId: agenciaId);
  }

  @override
  Future<List<Agencia>> getAgenciasPorUsuario({required String login, required String password}) {
    return datasource.getAgenciasPorUsuario(login: login, password: password);
  }
}
