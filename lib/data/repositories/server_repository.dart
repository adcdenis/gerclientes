import 'package:gerclientes/data/database/app_database.dart';
import 'package:gerclientes/data/models/server_model.dart';
import 'package:drift/drift.dart';

class ServerRepository {
  final AppDatabase db;
  ServerRepository(this.db);

  Server _mapRow(ServerRow r) => Server(
        id: r.id,
        name: r.name,
      );

  ServersCompanion _toCompanion(Server s) => ServersCompanion(
        id: s.id != null ? Value(s.id!) : const Value.absent(),
        name: Value(s.name),
      );

  Future<int> create(Server s) => db.insertServer(_toCompanion(s));
  Future<List<Server>> all() async => (await db.getAllServers()).map(_mapRow).toList();
  Future<Server?> byId(int id) async {
    final r = await db.getServerById(id);
    return r == null ? null : _mapRow(r);
  }

  Future<bool> update(Server s) => db.updateServer(_toCompanion(s));
  Future<int> delete(int id) => db.deleteServer(id);

  Stream<List<Server>> watchAll() => db.watchAllServers().map((rows) => rows.map(_mapRow).toList());
}
