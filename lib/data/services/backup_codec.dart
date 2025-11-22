import 'dart:convert';

import 'package:gerclientes/data/database/app_database.dart';

/// Utilitário para serializar e restaurar dados de backup sem depender de IO.
class BackupCodec {
  static DateTime _dateFromJson(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    late final DateTime dt;
    if (v is String) {
      dt = DateTime.parse(v);
    } else if (v is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(v);
    } else if (v is num) {
      dt = DateTime.fromMillisecondsSinceEpoch(v.toInt());
    } else {
      throw ArgumentError('Unsupported date value: $v');
    }
    return DateTime(
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
      dt.second,
      dt.millisecond,
      dt.microsecond,
    );
  }
  // Histórico removido do backup: não há cálculo de órfãos ou filtros
  /// Gera um Map pronto para JSON contendo todas as entidades.
  static Future<Map<String, dynamic>> encode(AppDatabase db) async {
    // final counters = await db.getAllCounters();
    // final categories = await db.getAllCategories();
    final servers = await db.getAllServers();
    final plans = await db.getAllPlans();
    final clients = await db.getAllClients();
    return {
      'version': 1,
      'servers': servers.map((c) => c.toJson()).toList(),
      'plans': plans.map((c) => c.toJson()).toList(),
      'clients': clients.map((c) => c.toJson()).toList(),
    };
  }

  /// Valida a estrutura e tipos do JSON de backup.
  /// Retorna uma lista de mensagens de erro; vazia se válido.
  static List<String> validate(Map<String, dynamic> data) {
    final errors = <String>[];

    void requireKey<T>(String key, bool Function(dynamic) typeCheck, {String? ctx}) {
      if (!data.containsKey(key)) {
        errors.add('[${ctx ?? 'root'}] chave obrigatória ausente: $key');
        return;
      }
      final v = data[key];
      if (!typeCheck(v)) {
        errors.add('[${ctx ?? 'root'}] tipo inválido para $key: ${v.runtimeType}');
      }
    }

    requireKey<int>('version', (v) => v is int);
    // Counters e Categories agora são opcionais/legado
    // requireKey<List>('counters', (v) => v is List);
    // requireKey<List>('categories', (v) => v is List);
    requireKey<List>('servers', (v) => v is List);
    requireKey<List>('plans', (v) => v is List);
    requireKey<List>('clients', (v) => v is List);
    // Histórico não é mais suportado

    // Ignora chaves legadas 'counters' e 'categories' se presentes

    // Servers
    final servers = (data['servers'] as List<dynamic>? ?? []);
    for (var i = 0; i < servers.length; i++) {
      final m = servers[i];
      if (m is! Map<String, dynamic>) { errors.add('[servers[$i]] não é um objeto'); continue; }
      if (m['id'] is! num) errors.add('[servers[$i]] id obrigatorio (num)');
      if (m['name'] is! String) errors.add('[servers[$i]] name obrigatorio (string)');
    }

    // Plans
    final plans = (data['plans'] as List<dynamic>? ?? []);
    for (var i = 0; i < plans.length; i++) {
      final m = plans[i];
      if (m is! Map<String, dynamic>) { errors.add('[plans[$i]] não é um objeto'); continue; }
      if (m['id'] is! num) errors.add('[plans[$i]] id obrigatorio (num)');
      if (m['name'] is! String) errors.add('[plans[$i]] name obrigatorio (string)');
      if (m['value'] is! num) errors.add('[plans[$i]] value obrigatorio (num)');
    }

    // Clients
    final clients = (data['clients'] as List<dynamic>? ?? []);
    for (var i = 0; i < clients.length; i++) {
      final m = clients[i];
      if (m is! Map<String, dynamic>) { errors.add('[clients[$i]] não é um objeto'); continue; }
      if (m['id'] is! num) errors.add('[clients[$i]] id obrigatorio (num)');
      if (m['name'] is! String) errors.add('[clients[$i]] name obrigatorio (string)');
      if (m['user'] != null && m['user'] is! String) errors.add('[clients[$i]] user opcional (string)');
      if (m['email'] != null && m['email'] is! String) errors.add('[clients[$i]] email opcional (string)');
      if (m['phone'] != null && m['phone'] is! String) errors.add('[clients[$i]] phone opcional (string)');
      if (m['observation'] != null && m['observation'] is! String) errors.add('[clients[$i]] observation opcional (string)');
      if (m['dueDate'] == null) {
        errors.add('[clients[$i]] dueDate obrigatorio');
      } else {
        try { _dateFromJson(m['dueDate']); } catch (_) { errors.add('[clients[$i]] dueDate inválido'); }
      }
    }

    // Histórico removido: nenhuma validação de history

    return errors;
  }

  /// Restaura dados a partir de um Map JSON.
  static Future<void> restore(AppDatabase db, Map<String, dynamic> data) async {
    // Executa restauração de forma atômica para evitar estados intermediários
    await db.transaction(() async {
      // Restauração completa: limpamos os dados atuais antes de inserir
      // Ordem de deleção: tabelas dependentes primeiro (Clients)
      await db.customStatement('DELETE FROM clients');
      await db.customStatement('DELETE FROM servers');
      await db.customStatement('DELETE FROM plans');
      // Ignora tabelas legadas: não deleta counters/categories

      // Ignora restauração de categorias e contadores legados



      // Recria Servers
      final servers = (data['servers'] as List<dynamic>? ?? []);
      for (final s in servers) {
        final m = s as Map<String, dynamic>;
        await db.upsertServerRaw(
          id: (m['id'] as num).toInt(),
          name: m['name'] as String,
        );
      }

      // Recria Plans
      final plans = (data['plans'] as List<dynamic>? ?? []);
      for (final p in plans) {
        final m = p as Map<String, dynamic>;
        await db.upsertPlanRaw(
          id: (m['id'] as num).toInt(),
          name: m['name'] as String,
          value: (m['value'] as num).toDouble(),
        );
      }

      // Recria Clients
      final clients = (data['clients'] as List<dynamic>? ?? []);
      for (final c in clients) {
        final m = c as Map<String, dynamic>;
        await db.upsertClientRaw(
          id: (m['id'] as num).toInt(),
          name: m['name'] as String,
          user: m['user'] as String?,
          email: m['email'] as String?,
          phone: m['phone'] as String?,
          dueDate: _dateFromJson(m['dueDate']),
          observation: m['observation'] as String?,
          serverId: m['serverId'] != null ? (m['serverId'] as num).toInt() : null,
          planId: m['planId'] != null ? (m['planId'] as num).toInt() : null,
        );
      }

      // Histórico removido: nada a restaurar
    });
  }

  /// Convenience para retornar uma String JSON a partir do banco.
  static Future<String> encodeToJsonString(AppDatabase db) async {
    final map = await encode(db);
    return jsonEncode(map);
  }

  /// Convenience para restaurar a partir de uma String JSON.
  static Future<void> restoreFromJsonString(AppDatabase db, String jsonStr) async {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    await restore(db, data);
  }
}