import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerclientes/state/providers.dart';
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
                                    showActions: false,
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
