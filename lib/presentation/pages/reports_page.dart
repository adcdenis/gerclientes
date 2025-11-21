import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gerclientes/state/providers.dart';
import 'package:gerclientes/domain/report_export.dart';
import 'package:gerclientes/presentation/widgets/client_card.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {


  

  

  

  

  

  

  


  

  

  

  

  

  

  

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);
    final plansAsync = ref.watch(plansProvider);
    final serversAsync = ref.watch(serversProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Text('📄', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Relatórios de Clientes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          const Text('Gere relatórios dos clientes com seus planos e servidores.'),
          const SizedBox(height: 16),

          // Filtros
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: clientsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => Text('Erro ao carregar clientes: $e'),
                data: (clients) {
                  return serversAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, st) => Text('Erro ao carregar servidores: $e'),
                    data: (servers) {
                      return plansAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, st) => Text('Erro ao carregar planos: $e'),
                        data: (plans) {
                          final serverById = { for (final s in servers) s.id: s.name };
                          final planById = { for (final p in plans) p.id: p.name };
                          final planValById = { for (final p in plans) p.id: p.value };
                          final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
                          final rows = clients.map((c) => ClientReportRow(
                            nome: c.name,
                            email: c.email ?? '-',
                            telefone: c.phone ?? '-',
                            vencimento: c.dueDate,
                            servidor: c.serverId != null ? (serverById[c.serverId] ?? '-') : '-',
                            plano: c.planId != null ? (planById[c.planId] ?? '-') : '-',
                            valor: c.planId != null && planValById[c.planId] != null ? currency.format(planValById[c.planId]) : '-',
                          )).toList();
                          return Wrap(spacing: 8, runSpacing: 8, children: [
                            FilledButton.icon(
                              onPressed: rows.isEmpty ? null : () async { final f = await generateXlsxClientsReport(rows); await shareFile(f, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'); },
                              icon: const Icon(Icons.grid_on),
                              label: const Text('Gerar Excel'),
                            ),
                            FilledButton.icon(
                              onPressed: rows.isEmpty ? null : () async { final f = await generatePdfClientsReport(rows); await shareFile(f, mimeType: 'application/pdf'); },
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Gerar PDF'),
                            ),
                          ]);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: clientsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Erro ao carregar: $e')),
                data: (clients) {
                  return serversAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Erro ao carregar servidores: $e')),
                    data: (servers) {
                      return plansAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, st) => Center(child: Text('Erro ao carregar planos: $e')),
                        data: (plans) {
                          final serverById = { for (final s in servers) s.id: s.name };
                          final planById = { for (final p in plans) p.id: p.name };
                          final planValById = { for (final p in plans) p.id: p.value };
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${clients.length} cliente(s)', style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: clients.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (ctx, i) {
                                  final c = clients[i];
                                  return ClientCard(
                                    client: c,
                                    serverName: c.serverId != null ? (serverById[c.serverId] ?? '-') : '-',
                                    planName: c.planId != null ? (planById[c.planId] ?? '-') : '-',
                                    planValue: c.planId != null ? planValById[c.planId] : null,
                                    showActions: false, // No actions in reports for now
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
