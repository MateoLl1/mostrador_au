import 'package:mostrador_au/domain/domain.dart';

abstract class AuthRepository {
  Future<LoginResponse> login({required String login, required String password});
  Future<List<Agencia>> getAgencias();
}
