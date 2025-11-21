import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerclientes/state/providers.dart';
import 'package:intl/intl.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);
    final plansAsync = ref.watch(plansProvider);
    final cs = Theme.of(context).colorScheme;

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
                    final now = DateTime.now();
                    final totalClients = clients.length;
                    
                    final expiringClients = clients.where((c) {
                      final diff = c.dueDate.difference(now).inDays;
                      return diff >= 0 && diff <= 7;
                    }).toList();

                    double monthlyRevenue = 0;
                    for (final client in clients) {
                      if (client.planId != null) {
                        final planMatch = plans.where((p) => p.id == client.planId).firstOrNull;
                        if (planMatch != null) {
                          monthlyRevenue += planMatch.value;
                        }
                      }
                    }

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
                              title: 'Total Clientes',
                              value: totalClients.toString(),
                              icon: Icons.people,
                              color: cs.primaryContainer,
                              onColor: cs.onPrimaryContainer,
                            ),
                            _statCard(
                              context,
                              title: 'A Vencer (7 dias)',
                              value: expiringClients.length.toString(),
                              icon: Icons.warning_amber,
                              color: cs.errorContainer,
                              onColor: cs.onErrorContainer,
                            ),
                            _statCard(
                              context,
                              title: 'Receita Mensal',
                              value: NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(monthlyRevenue),
                              icon: Icons.attach_money,
                              color: cs.tertiaryContainer,
                              onColor: cs.onTertiaryContainer,
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
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: expiringClients.length,
                            itemBuilder: (context, index) {
                              final client = expiringClients[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.person_outline),
                                  title: Text(client.name),
                                  subtitle: Text('Vence em: ${DateFormat('dd/MM/yyyy').format(client.dueDate)}'),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
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
