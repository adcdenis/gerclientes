import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerclientes/state/providers.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gerclientes/presentation/widgets/client_card.dart';
import 'package:gerclientes/data/models/client_model.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);
    final plansAsync = ref.watch(plansProvider);
    final serversAsync = ref.watch(serversProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            clientsAsync.when(
              data: (clients) {
                return plansAsync.when(
                  data: (plans) {
                    return serversAsync.when(
                      data: (servers) {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final totalClients = clients.length;
                        
                        final serverById = { for (final s in servers) s.id: s.name };
                        final planById = { for (final p in plans) p.id: p.name };
                        final planValById = { for (final p in plans) p.id: p.value };

                        // Clientes a vencer em 3 dias (0 a 3 dias)
                        final expiringIn3Days = clients.where((c) {
                          final diff = c.dueDate.difference(today).inDays;
                          return diff >= 0 && diff <= 3;
                        }).toList();

                        // Clientes ativos (vencimento hoje ou futuro)
                        final activeClients = clients.where((c) {
                          return !c.dueDate.isBefore(today);
                        }).toList();

                        // Clientes vencidos (vencimento no passado, estritamente antes de hoje)
                        final expiredClients = clients.where((c) {
                          return c.dueDate.isBefore(today);
                        }).toList();

                        // Clientes a vencer em 3 dias (para a lista abaixo)
                        final expiringClients = clients.where((c) {
                          final diff = c.dueDate.difference(today).inDays;
                          return diff >= 0 && diff <= 3;
                        }).toList()
                          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

                        return Column(
                          children: [
                            GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _statCard(
                                  context,
                                  title: 'Clientes a vencer em 3 dias',
                                  value: expiringIn3Days.length.toString(),
                                  icon: Icons.schedule,
                                  color: Colors.red.shade100,
                                  onColor: Colors.red.shade900,
                                ),
                                _statCard(
                                  context,
                                  title: 'Clientes Ativos',
                                  value: activeClients.length.toString(),
                                  icon: Icons.people,
                                  color: Colors.blue.shade100,
                                  onColor: Colors.blue.shade900,
                                ),
                                _statCard(
                                  context,
                                  title: 'Clientes Vencidos',
                                  value: expiredClients.length.toString(),
                                  icon: Icons.person_outline,
                                  color: Colors.lightBlue.shade100,
                                  onColor: Colors.lightBlue.shade900,
                                ),
                                _statCard(
                                  context,
                                  title: 'Total Geral',
                                  value: totalClients.toString(),
                                  icon: Icons.list_alt,
                                  color: Colors.purple.shade100,
                                  onColor: Colors.purple.shade900,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (expiringClients.isNotEmpty) ...[
                              const Text(
                                'Clientes a Vencer',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: expiringClients.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final client = expiringClients[index];
                                  return ClientCard(
                                    client: client,
                                    serverName: client.serverId != null ? (serverById[client.serverId] ?? '-') : '-',
                                    planName: client.planId != null ? (planById[client.planId] ?? '-') : '-',
                                    planValue: client.planId != null ? planValById[client.planId] : null,
                                    onRenew: () => _renewClient(context, ref, client),
                                    onWhatsApp: () => _sendWhatsAppMessage(context, ref, client),
                                    // No delete or edit on dashboard for now, or maybe edit?
                                    // Keeping it simple as per request "visual do card"
                                    // But dashboard usually allows quick actions.
                                    // The original code had ONLY whatsapp.
                                    // I will keep only whatsapp to match original functionality but with new design.
                                    showActions: true,
                                  );
                                },
                              ),
                            ],
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Erro ao carregar servidores: $e'),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Erro ao carregar planos: $e'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro ao carregar clientes: $e'),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  String _renderWhatsAppMessage(String template, {
    required String clientName,
    required DateTime dueDate,
    String? planName,
    double? planValue,
    String? user,
    String? serverName,
    String? email,
    String? phone,
    String? observation,
    int? id,
  }) {
    final greeting = _getGreeting();
    final dateFormatted = DateFormat('dd/MM/yyyy').format(dueDate);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final valorStr = planValue != null ? currency.format(planValue) : '';
    final now = DateTime.now();
    final dataAtual = DateFormat('dd/MM/yyyy').format(now);
    final horaAtual = DateFormat('HH:mm').format(now);
    final map = {
      '{SAUDACAO}': greeting,
      '{NOME}': clientName,
      '{VENCIMENTO}': dateFormatted,
      '{PLANO}': planName ?? '',
      '{VALOR}': valorStr,
      '{USUARIO}': user ?? '',
      '{SERVIDOR}': serverName ?? '',
      '{EMAIL}': email ?? '',
      '{TELEFONE}': phone ?? '',
      '{OBSERVACAO}': observation ?? '',
      '{ID}': id?.toString() ?? '',
      '{DATA_ATUAL}': dataAtual,
      '{HORA_ATUAL}': horaAtual,
    };
    var out = template;
    for (final e in map.entries) {
      out = out.replaceAll(e.key, e.value);
    }
    return out.split('\n').where((l) => l.trim().isNotEmpty).join('\n');
  }

  Future<void> _sendWhatsAppMessage(BuildContext context, WidgetRef ref, dynamic client) async {
    if (client.phone == null || client.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente não possui telefone cadastrado')),
      );
      return;
    }

    String? planName;
    double? planValue;
    String? serverName;
    if (client.planId != null) {
      final plans = await ref.read(plansProvider.future);
      final plan = plans.where((p) => p.id == client.planId).firstOrNull;
      if (plan != null) {
        planName = plan.name;
        planValue = plan.value;
      }
    }
    if (client.serverId != null) {
      final servers = await ref.read(serversProvider.future);
      final server = servers.where((s) => s.id == client.serverId).firstOrNull;
      if (server != null) {
        serverName = server.name;
      }
    }

    final template = await ref.read(whatsappTemplateProvider.future);
    final message = _renderWhatsAppMessage(
      template,
      clientName: client.name,
      dueDate: client.dueDate,
      planName: planName,
      planValue: planValue,
      user: client.user,
      serverName: serverName,
      email: client.email,
      phone: client.phone,
      observation: client.observation,
      id: client.id,
    );
    var phone = client.phone!.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('55')) {
      phone = phone.substring(2);
    }
    final encodedMessage = Uri.encodeComponent(message);
    final hasText = message.trim().isNotEmpty;
    final candidates = <Uri>[
      Uri.parse(hasText
          ? 'whatsapp://send?phone=55$phone&text=$encodedMessage'
          : 'whatsapp://send?phone=55$phone'),
      Uri.parse(hasText
          ? 'whatsapp-business://send?phone=55$phone&text=$encodedMessage'
          : 'whatsapp-business://send?phone=55$phone'),
      Uri.parse(hasText
          ? 'https://api.whatsapp.com/send?phone=55$phone&text=$encodedMessage'
          : 'https://api.whatsapp.com/send?phone=55$phone'),
    ];
    for (final uri in candidates) {
      if (await canLaunchUrl(uri)) {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
      }
    }
    await Share.share(message);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abrindo opções de compartilhamento (WhatsApp, etc.)')),
      );
    }
  }

  Widget _statCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color onColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: onColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: onColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: onColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
  Future<void> _renewClient(BuildContext context, WidgetRef ref, Client client) async {
    final newDue = client.dueDate.add(const Duration(days: 30));
    final updated = client.copyWith(dueDate: newDue);
    await ref.read(clientRepositoryProvider).update(updated);
    ref.invalidate(clientsProvider);
    final msg = 'Plano renovado com sucesso.  Próximo vencimento: ${DateFormat('dd/MM/yyyy').format(newDue)}';
    await Clipboard.setData(ClipboardData(text: msg));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Renovado e mensagem copiada')));
    }
  }
