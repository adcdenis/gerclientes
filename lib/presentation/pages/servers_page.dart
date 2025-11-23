import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerclientes/data/models/server_model.dart';
import 'package:gerclientes/state/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:gerclientes/presentation/widgets/server_card.dart';

class ServersPage extends ConsumerWidget {
  const ServersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serversAsync = ref.watch(serversProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Servidores'),
      ),
      body: serversAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (servers) {
          final sortedServers = [...servers]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${sortedServers.length} servidor(es)', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedServers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final s = sortedServers[i];
                        return ServerCard(
                          server: s,
                          onTap: () => context.push('/servers/${s.id}/edit', extra: s),
                          onDelete: () => _confirmDelete(context, ref, s),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/servers/new'),
        child: const Icon(Icons.add),
      ),
    );
  }


  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Server server) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return Consumer(builder: (context, ref2, _) {
          final clientsAsync = ref2.watch(clientsProvider);
          final serversAsync = ref2.watch(serversProvider);
          return clientsAsync.when(
            loading: () => const AlertDialog(title: Text('Carregando...')),
            error: (e, _) => AlertDialog(title: const Text('Erro'), content: Text('$e')),
            data: (clients) {
              var associated = clients.where((c) => c.serverId == server.id).toList();
              if (associated.isEmpty) {
                return AlertDialog(
                  title: const Text('Confirmar Exclusão'),
                  content: Text('Deseja excluir o servidor "${server.name}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar')),
                    FilledButton(
                      onPressed: () async {
                        if (server.id != null) {
                          await ref2.read(serverRepositoryProvider).delete(server.id!);
                          if (!dialogCtx.mounted) return;
                          Navigator.pop(dialogCtx);
                        }
                      },
                      child: const Text('Excluir'),
                    ),
                  ],
                );
              }
              final selections = <int, int?>{};
              return StatefulBuilder(builder: (ctx, setState) {
                final otherServers = serversAsync.maybeWhen(data: (ss) => ss.where((s) => s.id != server.id).toList(), orElse: () => const []);
                return AlertDialog(
                  title: const Text('Servidor em uso'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Associado a ${associated.length} cliente(s):'),
                        const SizedBox(height: 12),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (_, i) {
                              final c = associated[i];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          c.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () async {
                                          if (c.id != null) {
                                            await ref2.read(clientRepositoryProvider).delete(c.id!);
                                            ref2.invalidate(clientsProvider);
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (otherServers.isNotEmpty)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<int>(
                                            isExpanded: true,
                                            menuMaxHeight: 240,
                                            initialValue: selections[c.id ?? i],
                                            items: otherServers.map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.name))).toList(),
                                            onChanged: (v) => setState(() => selections[c.id ?? i] = v),
                                            decoration: const InputDecoration(hintText: 'Selecione'),
                                          ),
                                        ),
                                    IconButton(
                                      icon: const Icon(Icons.swap_horiz),
                                      onPressed: () async {
                                        final key = c.id ?? i;
                                        final target = selections[key];
                                        if (target != null) {
                                          await ref2.read(clientRepositoryProvider).update(c.copyWith(serverId: target));
                                          ref2.invalidate(clientsProvider);
                                          setState(() {
                                            associated.removeWhere((x) => x.id == c.id);
                                          });
                                          if (dialogCtx.mounted) {
                                            ScaffoldMessenger.of(dialogCtx).showSnackBar(const SnackBar(content: Text('Cliente migrado')));
                                          }
                                        }
                                      },
                                    ),
                                      ],
                                    ),
                                ],
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemCount: associated.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Fechar')),
                    FilledButton(
                      onPressed: associated.isEmpty && server.id != null
                          ? () async {
                              await ref2.read(serverRepositoryProvider).delete(server.id!);
                              if (!dialogCtx.mounted) return;
                              Navigator.pop(dialogCtx);
                            }
                          : null,
                      child: const Text('Excluir servidor'),
                    ),
                  ],
                );
              });
            },
          );
        });
      },
    );
  }
}

class ServerFormPage extends ConsumerStatefulWidget {
  final Server? initialServer;
  const ServerFormPage({super.key, this.initialServer});

  @override
  ConsumerState<ServerFormPage> createState() => _ServerFormPageState();
}

class _ServerFormPageState extends ConsumerState<ServerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialServer?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialServer != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Servidor' : 'Novo Servidor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Servidor *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                autofocus: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      final name = _nameController.text.trim();
                      if (isEditing) {
                        final updated = _serverCopyWith(widget.initialServer!, name: name);
                        await ref.read(serverRepositoryProvider).update(updated);
                      } else {
                        await ref.read(serverRepositoryProvider).create(Server(name: name));
                      }
                      if (context.mounted) context.go('/servers');
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => context.go('/servers'),
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

Server _serverCopyWith(Server s, {String? name}) => Server(id: s.id, name: name ?? s.name);
