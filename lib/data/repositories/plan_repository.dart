import 'package:gerclientes/data/database/app_database.dart';
import 'package:gerclientes/data/models/plan_model.dart';
import 'package:drift/drift.dart';

class PlanRepository {
  final AppDatabase db;
  PlanRepository(this.db);

  Plan _mapRow(PlanRow r) => Plan(
        id: r.id,
        name: r.name,
        value: r.value,
      );

  PlansCompanion _toCompanion(Plan p) => PlansCompanion(
        id: p.id != null ? Value(p.id!) : const Value.absent(),
        name: Value(p.name),
        value: Value(p.value),
      );

  Future<int> create(Plan p) => db.insertPlan(_toCompanion(p));
  Future<List<Plan>> all() async => (await db.getAllPlans()).map(_mapRow).toList();
  Future<Plan?> byId(int id) async {
    final r = await db.getPlanById(id);
    return r == null ? null : _mapRow(r);
  }

  Future<bool> update(Plan p) => db.updatePlan(_toCompanion(p));
  Future<int> delete(int id) => db.deletePlan(id);

  Stream<List<Plan>> watchAll() => db.watchAllPlans().map((rows) => rows.map(_mapRow).toList());
}
