import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerclientes/data/models/plan_model.dart';
import 'package:gerclientes/state/providers.dart';
import 'package:go_router/go_router.dart';

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
                    Text('${plans.length} plano(s)', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: plans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final p = plans[i];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => context.go('/plans/${p.id}/edit', extra: p),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: cs.outlineVariant),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 4),
                                        Text('R\$ ${p.value.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _confirmDelete(context, ref, p),
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
        onPressed: () => context.go('/plans/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Plan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir o plano "${plan.name}"?'),
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

    if (confirmed == true && plan.id != null) {
      await ref.read(planRepositoryProvider).delete(plan.id!);
    }
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
