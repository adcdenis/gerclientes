import 'package:drift/drift.dart';
import 'connection/open_connection.dart';
import 'connection/open_test_connection.dart';

part 'app_database.g.dart';

@DataClassName('ServerRow')
class Servers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

@DataClassName('PlanRow')
class Plans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get value => real()();
}

@DataClassName('ClientRow')
class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get user => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get observation => text().nullable()();
  IntColumn get serverId => integer().nullable().references(Servers, #id)();
  IntColumn get planId => integer().nullable().references(Plans, #id)();
}

LazyDatabase _openConnection() => openConnection();

@DriftDatabase(tables: [Servers, Plans, Clients])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.test() : super(openTestConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // Garante que chaves estrangeiras estejam ativadas (necessário para CASCADE funcionar)
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (m) async {
          await m.createAll();
        },

        onUpgrade: (m, from, to) async {
          // Migração para v7: remover tabelas legadas (corridas, categories) e garantir
          // somente Servers, Plans, Clients.
          if (from < 7) {
            // Drop tabelas antigas se existirem
            final hasCorridas = await customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='corridas'",
            ).get();
            if (hasCorridas.isNotEmpty) {
              await customStatement('DROP TABLE corridas');
            }
            final hasCategories = await customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='categories'",
            ).get();
            if (hasCategories.isNotEmpty) {
              await customStatement('DROP TABLE categories');
            }
            final hasHistory = await customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='counter_history'",
            ).get();
            if (hasHistory.isNotEmpty) {
              await customStatement('DROP TABLE counter_history');
            }
            // Garante tabelas ativas
            final hasServers = await customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='servers'",
            ).get();
            if (hasServers.isEmpty) {
              await m.createTable(servers);
            }
            final hasPlans = await customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='plans'",
            ).get();
            if (hasPlans.isEmpty) {
              await m.createTable(plans);
            }
            final hasClients = await customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='clients'",
            ).get();
            if (hasClients.isEmpty) {
              await m.createTable(clients);
            }
          }
        },
      );

  // Tabelas ativas: Servers, Plans, Clients


  // CRUD Servers
  Future<int> insertServer(ServersCompanion entry) => into(servers).insert(entry);
  Future<List<ServerRow>> getAllServers() => select(servers).get();
  Future<ServerRow?> getServerById(int id) => (select(servers)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<bool> updateServer(ServersCompanion entry) => update(servers).replace(entry);
  Future<int> deleteServer(int id) => (delete(servers)..where((t) => t.id.equals(id))).go();
  Stream<List<ServerRow>> watchAllServers() => select(servers).watch();
  Future<void> upsertServerRaw({required int id, required String name}) async {
    await into(servers).insertOnConflictUpdate(ServersCompanion(
      id: Value(id),
      name: Value(name),
    ));
  }

  // CRUD Plans
  Future<int> insertPlan(PlansCompanion entry) => into(plans).insert(entry);
  Future<List<PlanRow>> getAllPlans() => select(plans).get();
  Future<PlanRow?> getPlanById(int id) => (select(plans)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<bool> updatePlan(PlansCompanion entry) => update(plans).replace(entry);
  Future<int> deletePlan(int id) => (delete(plans)..where((t) => t.id.equals(id))).go();
  Stream<List<PlanRow>> watchAllPlans() => select(plans).watch();
  Future<void> upsertPlanRaw({required int id, required String name, required double value}) async {
    await into(plans).insertOnConflictUpdate(PlansCompanion(
      id: Value(id),
      name: Value(name),
      value: Value(value),
    ));
  }

  // CRUD Clients
  Future<int> insertClient(ClientsCompanion entry) => into(clients).insert(entry);
  Future<List<ClientRow>> getAllClients() => select(clients).get();
  Future<ClientRow?> getClientById(int id) => (select(clients)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<bool> updateClient(ClientsCompanion entry) => update(clients).replace(entry);
  Future<int> deleteClient(int id) => (delete(clients)..where((t) => t.id.equals(id))).go();
  Stream<List<ClientRow>> watchAllClients() => select(clients).watch();
  Future<void> upsertClientRaw({
    required int id,
    required String name,
    String? user,
    String? email,
    String? phone,
    required DateTime dueDate,
    String? observation,
    int? serverId,
    int? planId,
  }) async {
    await into(clients).insertOnConflictUpdate(ClientsCompanion(
      id: Value(id),
      name: Value(name),
      user: Value(user),
      email: Value(email),
      phone: Value(phone),
      dueDate: Value(dueDate),
      observation: Value(observation),
      serverId: Value(serverId),
      planId: Value(planId),
    ));
  }
}