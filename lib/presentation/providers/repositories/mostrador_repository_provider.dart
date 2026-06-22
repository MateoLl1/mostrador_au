import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/domain/domain.dart';
import 'package:mostrador_au/infrastructure/infrastructure.dart';

final mostradorRepositoryProvider = Provider<MostradorRepository>((ref) {
  return MostradorRepositoryImpl(datasource: MostradorDatasourceImpl());
});
