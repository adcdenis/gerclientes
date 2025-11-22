import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerclientes/data/models/client_model.dart';
import 'package:gerclientes/state/providers.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gerclientes/presentation/widgets/client_card.dart';

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
        data: (clientsData) {
          final filter = ref.watch(clientFilterProvider);
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final filteredClients = clientsData.where((c) {
            final diff = c.dueDate.difference(today).inDays;
            switch (filter) {
              case ClientFilter.threeDays:
                return diff >= 0 && diff <= 3;
              case ClientFilter.active:
                return !c.dueDate.isBefore(today);
              case ClientFilter.expired:
                return c.dueDate.isBefore(today);
              case ClientFilter.all:
                return true;
            }
          }).toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
          
          final clients = filteredClients;
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
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _FilterChip(
                                    label: '3 dias',
                                    icon: Icons.schedule,
                                    selected: ref.watch(clientFilterProvider) == ClientFilter.threeDays,
                                    onSelected: (v) => ref.read(clientFilterProvider.notifier).state = ClientFilter.threeDays,
                                  ),
                                  const SizedBox(width: 2),
                                  _FilterChip(
                                    label: 'Ativos',
                                    icon: Icons.check_circle,
                                    selected: ref.watch(clientFilterProvider) == ClientFilter.active,
                                    onSelected: (v) => ref.read(clientFilterProvider.notifier).state = ClientFilter.active,
                                  ),
                                  const SizedBox(width: 2),
                                  _FilterChip(
                                    label: 'Vencidos',
                                    icon: Icons.warning,
                                    selected: ref.watch(clientFilterProvider) == ClientFilter.expired,
                                    onSelected: (v) => ref.read(clientFilterProvider.notifier).state = ClientFilter.expired,
                                  ),
                                  const SizedBox(width: 2),
                                  _FilterChip(
                                    label: 'Todos',
                                    icon: Icons.list,
                                    selected: ref.watch(clientFilterProvider) == ClientFilter.all,
                                    onSelected: (v) => ref.read(clientFilterProvider.notifier).state = ClientFilter.all,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
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
                                  onTap: () => context.go('/clients/${c.id}/edit', extra: c),
                                  onWhatsApp: () => _sendWhatsAppMessage(context, ref, c, plans),
                                  onDelete: () => _confirmDelete(context, ref, c),
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
    message += '- *Aguardamos seu contato para renovação!*';
    
    return message;
  }

  Future<void> _sendWhatsAppMessage(BuildContext context, WidgetRef ref, Client client, List<dynamic> plans) async {
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
      final plan = plans.where((p) => p.id == client.planId).firstOrNull;
      if (plan != null) {
        planName = plan.name;
        planValue = plan.value;
      }
    }

    final message = _buildWhatsAppMessage(
      clientName: client.name,
      dueDate: client.dueDate,
      planName: planName,
      planValue: planValue,
      user: client.user,
    );

    // Normalizar telefone (apenas dígitos) e evitar DDI duplicado
    var phone = client.phone!.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('55')) {
      phone = phone.substring(2);
    }

    if (phone.length < 10) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefone inválido para WhatsApp')),
        );
      }
      return;
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

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? Colors.transparent : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
    );
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
                data: (servers) {
                  final sorted = [...servers]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                  return DropdownButtonFormField<int>(
                  initialValue: _selectedServerId,
                  decoration: const InputDecoration(labelText: 'Servidor'),
                  items: sorted.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                  onChanged: (v) => setState(() => _selectedServerId = v),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erro ao carregar servidores: $e'),
              ),
              plansAsync.when(
                data: (plans) {
                  final sorted = [...plans]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                  return DropdownButtonFormField<int>(
                  initialValue: _selectedPlanId,
                  decoration: const InputDecoration(labelText: 'Plano'),
                  items: sorted.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                  onChanged: (v) => setState(() => _selectedPlanId = v),
                  );
                },
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
