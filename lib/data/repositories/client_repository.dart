import 'package:gerclientes/data/database/app_database.dart';
import 'package:gerclientes/data/models/client_model.dart';
import 'package:drift/drift.dart';

class ClientRepository {
  final AppDatabase db;
  ClientRepository(this.db);

  Client _mapRow(ClientRow r) => Client(
        id: r.id,
        name: r.name,
        user: r.user,
        email: r.email,
        phone: r.phone,
        dueDate: (() {
          final d = r.dueDate.isUtc ? r.dueDate.toLocal() : r.dueDate;
          return DateTime(
            d.year,
            d.month,
            d.day,
            d.hour,
            d.minute,
            d.second,
            d.millisecond,
            d.microsecond,
          );
        })(),
        observation: r.observation,
        serverId: r.serverId,
        planId: r.planId,
      );

  ClientsCompanion _toCompanion(Client c) => ClientsCompanion(
        id: c.id != null ? Value(c.id!) : const Value.absent(),
        name: Value(c.name),
        user: Value(c.user),
        email: Value(c.email),
        phone: Value(c.phone),
        dueDate: Value(c.dueDate),
        observation: Value(c.observation),
        serverId: Value(c.serverId),
        planId: Value(c.planId),
      );

  Future<int> create(Client c) => db.insertClient(_toCompanion(c));
  Future<List<Client>> all() async => (await db.getAllClients()).map(_mapRow).toList();
  Future<Client?> byId(int id) async {
    final r = await db.getClientById(id);
    return r == null ? null : _mapRow(r);
  }

  Future<bool> update(Client c) => db.updateClient(_toCompanion(c));
  Future<int> delete(int id) => db.deleteClient(id);

  Stream<List<Client>> watchAll() => db.watchAllClients().map((rows) => rows.map(_mapRow).toList());
}
