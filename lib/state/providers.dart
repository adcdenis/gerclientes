import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:gerclientes/data/database/app_database.dart';
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
final backupServiceProvider = Provider<BackupService>((ref) => BackupServiceImpl(ref.read(databaseProvider)));
final serverRepositoryProvider = Provider<ServerRepository>((ref) => ServerRepository(ref.read(databaseProvider)));
final planRepositoryProvider = Provider<PlanRepository>((ref) => PlanRepository(ref.read(databaseProvider)));
final clientRepositoryProvider = Provider<ClientRepository>((ref) => ClientRepository(ref.read(databaseProvider)));

// Streams of data
final serversProvider = StreamProvider<List<Server>>((ref) => ref.watch(serverRepositoryProvider).watchAll());
final plansProvider = StreamProvider<List<Plan>>((ref) => ref.watch(planRepositoryProvider).watchAll());
final clientsProvider = StreamProvider<List<Client>>((ref) => ref.watch(clientRepositoryProvider).watchAll());
final whatsappTemplateProvider = FutureProvider<String>((ref) async {
  final db = ref.read(databaseProvider);
  final tpl = await db.getSetting('whatsapp_template_vencimento');
  if (tpl != null && tpl.trim().isNotEmpty) return tpl;
  return 'Olá, {SAUDACAO}\n*Segue seu vencimento IPTV*\n*Vencimento:* _{VENCIMENTO}_\n\n*PLANO CONTRATADO*\n⭕ _Plano:_ *{PLANO}*\n⭕ _Valor:_ *R\$ {VALOR}*\n⭕ _Conta:_ *{USUARIO}*\n\n*FORMAS DE PAGAMENTOS*\n✅ Pic Pay : @canutobr\n✅ Banco do Brasil: ag 3020-1 cc 45746-9\n✅ Pix: canutopixbb@gmail.com\n\n- Duração da lista 30 dias, acesso de um ponto, não permite conexões simultâneas.\n- Assim que efetuar o pagamento, enviar o comprovante e vou efetuar a contratação/renovação o mais rápido possível.\n-*Aguardamos seu contato para renovação!*';
});

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
