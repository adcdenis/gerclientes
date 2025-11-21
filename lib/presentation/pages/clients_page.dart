import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerclientes/data/models/client_model.dart';
import 'package:gerclientes/state/providers.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ClientsPage extends ConsumerWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);
    final serversAsync = ref.watch(serversProvider);
    final plansAsync = ref.watch(plansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Clientes'),
      ),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (clients) {
          final cs = Theme.of(context).colorScheme;
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
                  final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
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
                                return Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => context.go('/clients/${c.id}/edit', extra: c),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: cs.outlineVariant),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete),
                                                  onPressed: () => _confirmDelete(context, ref, c),
                                                ),
                                              ],
                                            ),
                                        const SizedBox(height: 8),
                                        Table(
                                          columnWidths: const {0: FlexColumnWidth(), 1: FlexColumnWidth()},
                                          defaultVerticalAlignment: TableCellVerticalAlignment.top,
                                          children: [
                                            TableRow(children: [
                                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                const Text('Email:', style: TextStyle(fontSize: 12)),
                                                const SizedBox(height: 4),
                                                Text(c.email ?? '-', style: const TextStyle(fontSize: 14)),
                                              ]),
                                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                const Text('Telefone:', style: TextStyle(fontSize: 12)),
                                                const SizedBox(height: 4),
                                                Text(c.phone ?? '-', style: const TextStyle(fontSize: 14)),
                                              ]),
                                            ]),
                                            TableRow(children: [
                                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                const Text('Servidor:', style: TextStyle(fontSize: 12)),
                                                const SizedBox(height: 4),
                                                Text(c.serverId != null ? (serverById[c.serverId] ?? '-') : '-', style: const TextStyle(fontSize: 14)),
                                              ]),
                                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                const Text('Plano:', style: TextStyle(fontSize: 12)),
                                                const SizedBox(height: 4),
                                                Text(c.planId != null ? (planById[c.planId] ?? '-') : '-', style: const TextStyle(fontSize: 14)),
                                              ]),
                                            ]),
                                            TableRow(children: [
                                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                const Text('Vencimento:', style: TextStyle(fontSize: 12)),
                                                const SizedBox(height: 4),
                                                Text(DateFormat('dd/MM/yyyy').format(c.dueDate), style: const TextStyle(fontSize: 14)),
                                              ]),
                                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                const Text('Valor:', style: TextStyle(fontSize: 12)),
                                                const SizedBox(height: 4),
                                                Text(c.planId != null && planValById[c.planId] != null ? currency.format(planValById[c.planId]) : '-', style: const TextStyle(fontSize: 14)),
                                              ]),
                                            ]),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/clients/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir o cliente "${client.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && client.id != null) {
      await ref.read(clientRepositoryProvider).delete(client.id!);
    }
  }
}

class ClientFormPage extends ConsumerStatefulWidget {
  final Client? initialClient;
  const ClientFormPage({super.key, this.initialClient});

  @override
  ConsumerState<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends ConsumerState<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _userController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _observationController;
  late DateTime _dueDate;
  int? _selectedServerId;
  int? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    final c = widget.initialClient;
    _nameController = TextEditingController(text: c?.name ?? '');
    _userController = TextEditingController(text: c?.user ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _observationController = TextEditingController(text: c?.observation ?? '');
    _dueDate = c?.dueDate ?? DateTime.now();
    _selectedServerId = c?.serverId;
    _selectedPlanId = c?.planId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serversAsync = ref.watch(serversProvider);
    final plansAsync = ref.watch(plansProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialClient != null ? 'Editar Cliente' : 'Novo Cliente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome *'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(labelText: 'Usuário'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Vencimento: ${DateFormat('dd/MM/yyyy').format(_dueDate)}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _dueDate = picked);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              serversAsync.when(
                data: (servers) => DropdownButtonFormField<int>(
                  initialValue: _selectedServerId,
                  decoration: const InputDecoration(labelText: 'Servidor'),
                  items: servers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                  onChanged: (v) => setState(() => _selectedServerId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erro ao carregar servidores: $e'),
              ),
              plansAsync.when(
                data: (plans) => DropdownButtonFormField<int>(
                  initialValue: _selectedPlanId,
                  decoration: const InputDecoration(labelText: 'Plano'),
                  items: plans.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                  onChanged: (v) => setState(() => _selectedPlanId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erro ao carregar planos: $e'),
              ),
              TextFormField(
                controller: _observationController,
                decoration: const InputDecoration(labelText: 'Observação'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final client = Client(
                          id: widget.initialClient?.id,
                          name: _nameController.text.trim(),
                          user: _userController.text.trim().isEmpty ? null : _userController.text.trim(),
                          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
                          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                          dueDate: _dueDate,
                          observation: _observationController.text.trim().isEmpty ? null : _observationController.text.trim(),
                          serverId: _selectedServerId,
                          planId: _selectedPlanId,
                        );
                        if (widget.initialClient != null) {
                          await ref.read(clientRepositoryProvider).update(client);
                        } else {
                          await ref.read(clientRepositoryProvider).create(client);
                        }
                        if (context.mounted) context.go('/clients');
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => context.go('/clients'),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
