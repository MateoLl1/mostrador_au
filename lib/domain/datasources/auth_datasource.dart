import 'package:mostrador_au/domain/domain.dart';

abstract class AuthDatasource {
  Future<LoginResponse> login({required String login, required String password, required int agenciaId});
  Future<List<Agencia>> getAgencias();
}
