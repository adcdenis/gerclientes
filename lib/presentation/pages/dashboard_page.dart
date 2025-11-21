import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerclientes/state/providers.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gerclientes/presentation/widgets/client_card.dart';

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

                        // Clientes a vencer em 7 dias (para a lista abaixo)
                        final expiringClients = clients.where((c) {
                          final diff = c.dueDate.difference(today).inDays;
                          return diff >= 0 && diff <= 7;
                        }).toList();

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

  String _buildWhatsAppMessage({
    required String clientName,
    required DateTime dueDate,
    String? planName,
    double? planValue,
    String? user,
  }) {
    final greeting = _getGreeting();
    final dateFormatted = DateFormat('dd/MM/yyyy').format(dueDate);
    
    String message = 'Olá, $greeting\n';
    message += '*Segue seu vencimento IPTV*\n';
    message += '*Vencimento:* _${dateFormatted}_\n\n';
    
    if (planName != null && planValue != null) {
      message += '*PLANO CONTRATADO*\n';
      message += '⭕ _Plano:_ *$planName*\n';
      message += '⭕ _Valor:_ *R\$ ${planValue.toStringAsFixed(2)}*\n';
      if (user != null && user.isNotEmpty) {
        message += '⭕ _Conta:_ *$user*\n';
      }
      message += '\n';
    }
    
    message += '*FORMAS DE PAGAMENTOS*\n';
    message += '✅ Pic Pay : @canutobr\n';
    message += '✅ Banco do Brasil: ag 3020-1 cc 45746-9\n';
    message += '✅ Pix: canutopixbb@gmail.com\n\n';
    message += '- Duração da lista 30 dias, acesso de um ponto, não permite conexões simultâneas.\n';
    message += '- Assim que efetuar o pagamento, enviar o comprovante e vou efetuar a contratação/renovação o mais rápido possível.\n';
    message += '-*Aguardamos seu contato para renovação!*';
    
    return message;
  }

  Future<void> _sendWhatsAppMessage(BuildContext context, WidgetRef ref, dynamic client) async {
    if (client.phone == null || client.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente não possui telefone cadastrado')),
      );
      return;
    }

    // Buscar dados do plano se existir
    String? planName;
    double? planValue;
    
    if (client.planId != null) {
      final plansAsync = ref.read(plansProvider);
      plansAsync.whenData((plans) {
        final plan = plans.where((p) => p.id == client.planId).firstOrNull;
        if (plan != null) {
          planName = plan.name;
          planValue = plan.value;
        }
      });
    }

    final message = _buildWhatsAppMessage(
      clientName: client.name,
      dueDate: client.dueDate,
      planName: planName,
      planValue: planValue,
      user: client.user,
    );

    // Limpar telefone (remover caracteres não numéricos)
    final phone = client.phone!.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Montar URL do WhatsApp Web
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/55$phone?text=$encodedMessage');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
        );
      }
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
