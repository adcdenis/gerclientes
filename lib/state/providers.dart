import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:gerclientes/data/database/app_database.dart';
import 'package:gerclientes/data/models/counter.dart';
import 'package:gerclientes/data/models/category.dart' as model;
import 'package:gerclientes/data/repositories/corrida_repository.dart';
import 'package:gerclientes/data/repositories/category_repository.dart';
import 'package:gerclientes/data/services/backup_service.dart';
import 'package:gerclientes/data/repositories/server_repository.dart';
import 'package:gerclientes/data/repositories/plan_repository.dart';
import 'package:gerclientes/data/repositories/client_repository.dart';
import 'package:gerclientes/data/models/server_model.dart';
import 'package:gerclientes/data/models/plan_model.dart';
import 'package:gerclientes/data/models/client_model.dart';
export 'cloud_providers.dart';

// Database
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

// Repositories
final corridaRepositoryProvider = Provider<CorridaRepository>((ref) => CorridaRepository(ref.read(databaseProvider)));
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) => CategoryRepository(ref.read(databaseProvider)));
final backupServiceProvider = Provider<BackupService>((ref) => BackupServiceImpl(ref.read(databaseProvider)));
final serverRepositoryProvider = Provider<ServerRepository>((ref) => ServerRepository(ref.read(databaseProvider)));
final planRepositoryProvider = Provider<PlanRepository>((ref) => PlanRepository(ref.read(databaseProvider)));
final clientRepositoryProvider = Provider<ClientRepository>((ref) => ClientRepository(ref.read(databaseProvider)));

// Streams of data
final corridasProvider = StreamProvider<List<Counter>>((ref) => ref.watch(corridaRepositoryProvider).watchAll());
final categoriesProvider = StreamProvider<List<model.Category>>((ref) => ref.watch(categoryRepositoryProvider).watchAll());
final serversProvider = StreamProvider<List<Server>>((ref) => ref.watch(serverRepositoryProvider).watchAll());
final plansProvider = StreamProvider<List<Plan>>((ref) => ref.watch(planRepositoryProvider).watchAll());
final clientsProvider = StreamProvider<List<Client>>((ref) => ref.watch(clientRepositoryProvider).watchAll());

// Versão do aplicativo para exibir no rodapé do menu lateral
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return 'v${info.version} (build ${info.buildNumber})';
});

// Filtros de Clientes
enum ClientFilter {
  threeDays,
  active,
  expired,
  all
}

final clientFilterProvider = StateProvider<ClientFilter>((ref) => ClientFilter.threeDays);
