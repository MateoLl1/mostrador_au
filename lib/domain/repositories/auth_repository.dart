import 'package:mostrador_au/domain/domain.dart';

abstract class AuthRepository {
  Future<LoginResponse> login({required String login, required String password, required int agenciaId});
  Future<List<Agencia>> getAgenciasPorUsuario({required String login, required String password});
}
