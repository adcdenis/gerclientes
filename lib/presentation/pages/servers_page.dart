import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerclientes/data/models/server_model.dart';
import 'package:gerclientes/state/providers.dart';
import 'package:go_router/go_router.dart';

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
          final cs = Theme.of(context).colorScheme;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${servers.length} servidor(es)', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: servers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final s = servers[i];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => context.go('/servers/${s.id}/edit', extra: s),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: cs.outlineVariant),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(s.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _confirmDelete(context, ref, s),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/servers/new'),
        child: const Icon(Icons.add),
      ),
    );
  }


  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Server server) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir o servidor "${server.name}"?'),
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

    if (confirmed == true && server.id != null) {
      await ref.read(serverRepositoryProvider).delete(server.id!);
    }
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
