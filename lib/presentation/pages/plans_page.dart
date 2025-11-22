import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerclientes/data/models/plan_model.dart';
import 'package:gerclientes/state/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:gerclientes/presentation/widgets/plan_card.dart';

class PlansPage extends ConsumerWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Planos'),
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (plans) {
          final sortedPlans = [...plans]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${sortedPlans.length} plano(s)', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedPlans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final p = sortedPlans[i];
                        return PlanCard(
                          plan: p,
                          onTap: () => context.go('/plans/${p.id}/edit', extra: p),
                          onDelete: () => _confirmDelete(context, ref, p),
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
        onPressed: () => context.go('/plans/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Plan plan) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return Consumer(builder: (context, ref2, _) {
          final clientsAsync = ref2.watch(clientsProvider);
          final plansAsync = ref2.watch(plansProvider);
          return clientsAsync.when(
            loading: () => const AlertDialog(title: Text('Carregando...')),
            error: (e, _) => AlertDialog(title: const Text('Erro'), content: Text('$e')),
            data: (clients) {
              var associated = clients.where((c) => c.planId == plan.id).toList();
              if (associated.isEmpty) {
                return AlertDialog(
                  title: const Text('Confirmar Exclusão'),
                  content: Text('Deseja excluir o plano "${plan.name}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar')),
                    FilledButton(
                      onPressed: () async {
                        if (plan.id != null) {
                          await ref2.read(planRepositoryProvider).delete(plan.id!);
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
                final otherPlans = plansAsync.maybeWhen(data: (ps) => ps.where((p) => p.id != plan.id).toList(), orElse: () => const []);
                return AlertDialog(
                  title: const Text('Plano em uso'),
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
                                  if (otherPlans.isNotEmpty)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<int>(
                                            isExpanded: true,
                                            menuMaxHeight: 240,
                                            initialValue: selections[c.id ?? i],
                                            items: otherPlans.map((p) => DropdownMenuItem<int>(value: p.id, child: Text(p.name))).toList(),
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
                                          await ref2.read(clientRepositoryProvider).update(c.copyWith(planId: target));
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
                      onPressed: associated.isEmpty && plan.id != null
                          ? () async {
                              await ref2.read(planRepositoryProvider).delete(plan.id!);
                              if (!dialogCtx.mounted) return;
                              Navigator.pop(dialogCtx);
                            }
                          : null,
                      child: const Text('Excluir plano'),
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

class PlanFormPage extends ConsumerStatefulWidget {
  final Plan? initialPlan;
  const PlanFormPage({super.key, this.initialPlan});

  @override
  ConsumerState<PlanFormPage> createState() => _PlanFormPageState();
}

class _PlanFormPageState extends ConsumerState<PlanFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialPlan?.name ?? '');
    _valueController = TextEditingController(
      text: widget.initialPlan?.value != null ? widget.initialPlan!.value.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialPlan != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Plano' : 'Novo Plano'),
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
                decoration: const InputDecoration(labelText: 'Nome do Plano *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(labelText: 'Valor (R\$) *'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final parsed = double.tryParse((v ?? '').replaceAll(',', '.'));
                  return parsed == null ? 'Informe um número válido' : null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      final name = _nameController.text.trim();
                      final value = double.parse(_valueController.text.replaceAll(',', '.'));
                      if (isEditing) {
                        final updated = widget.initialPlan!.copyWith(name: name, value: value);
                        await ref.read(planRepositoryProvider).update(updated);
                      } else {
                        await ref.read(planRepositoryProvider).create(Plan(name: name, value: value));
                      }
                      if (context.mounted) context.go('/plans');
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => context.go('/plans'),
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
