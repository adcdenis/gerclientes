import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gerclientes/state/providers.dart';
// Persistência agora via SQLite
import 'package:flutter/services.dart';

class MessageTemplatePage extends ConsumerStatefulWidget {
  const MessageTemplatePage({super.key});

  @override
  ConsumerState<MessageTemplatePage> createState() => _MessageTemplatePageState();
}

class _MessageTemplatePageState extends ConsumerState<MessageTemplatePage> {
  final _controller = TextEditingController();
  bool _saving = false;
  String _name = 'José da Silva';
  DateTime _due = DateTime.now().add(const Duration(days: 3));
  String _plan = 'Mensal HD';
  double _value = 39.9;
  String _user = 'ze.silva';
  String _server = 'Servidor A';
  String _email = 'ze@exemplo.com';
  String _phone = '(11) 98888-7777';
  String _obs = 'Prefere contato à tarde';
  int _id = 1234;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.invalidate(whatsappTemplateProvider);
      final tpl = await ref.read(whatsappTemplateProvider.future);
      _controller.text = tpl;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertToken(String token) {
    final sel = _controller.selection;
    final text = _controller.text;
    final start = sel.start >= 0 ? sel.start : text.length;
    final end = sel.end >= 0 ? sel.end : start;
    final newText = text.replaceRange(start, end, token);
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: start + token.length);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(databaseProvider).setSetting('whatsapp_template_vencimento', _controller.text);
    try {
      await ref.read(cloudSyncServiceProvider).backupNow();
    } catch (_) {
      // silencioso: backup automático depende de login/configuração
    }
    ref.invalidate(whatsappTemplateProvider);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template salvo')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mensagem do WhatsApp')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Template da mensagem de vencimento', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escreva sua mensagem. Use tokens e formatação do WhatsApp.',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ActionChip(label: const Text('{NOME}'), onPressed: () => _insertToken('{NOME}')),
              ActionChip(label: const Text('{VENCIMENTO}'), onPressed: () => _insertToken('{VENCIMENTO}')),
              ActionChip(label: const Text('{PLANO}'), onPressed: () => _insertToken('{PLANO}')),
              ActionChip(label: const Text('{VALOR}'), onPressed: () => _insertToken('{VALOR}')),
              ActionChip(label: const Text('{USUARIO}'), onPressed: () => _insertToken('{USUARIO}')),
              ActionChip(label: const Text('{SAUDACAO}'), onPressed: () => _insertToken('{SAUDACAO}')),
              ActionChip(label: const Text('{SERVIDOR}'), onPressed: () => _insertToken('{SERVIDOR}')),
              ActionChip(label: const Text('{EMAIL}'), onPressed: () => _insertToken('{EMAIL}')),
              ActionChip(label: const Text('{TELEFONE}'), onPressed: () => _insertToken('{TELEFONE}')),
              ActionChip(label: const Text('{OBSERVACAO}'), onPressed: () => _insertToken('{OBSERVACAO}')),
              ActionChip(label: const Text('{ID}'), onPressed: () => _insertToken('{ID}')),
              ActionChip(label: const Text('{DATA_ATUAL}'), onPressed: () => _insertToken('{DATA_ATUAL}')),
              ActionChip(label: const Text('{HORA_ATUAL}'), onPressed: () => _insertToken('{HORA_ATUAL}')),
              ActionChip(label: const Text('*negrito*'), onPressed: () => _insertToken('*negrito*')),
              ActionChip(label: const Text('_itálico_'), onPressed: () => _insertToken('_itálico_')),
              ActionChip(label: const Text('~tachado~'), onPressed: () => _insertToken('~tachado~')),
              ActionChip(label: const Text('`monospace`'), onPressed: () => _insertToken('`monospace`')),
            ]),
            const SizedBox(height: 12),
            ExpansionTile(
              title: const Text('Pré-visualizar'),
              childrenPadding: const EdgeInsets.all(8),
              children: [
                Wrap(spacing: 8, runSpacing: 8, children: [
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      onChanged: (v) => setState(() => _name = v),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Vencimento', border: OutlineInputBorder()),
                      child: Row(
                        children: [
                          Expanded(child: Text('${_due.day.toString().padLeft(2, '0')}/${_due.month.toString().padLeft(2, '0')}/${_due.year}')),
                          IconButton(
                            icon: const Icon(Icons.date_range),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _due,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setState(() => _due = picked);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: TextFormField(
                      initialValue: _plan,
                      decoration: const InputDecoration(labelText: 'Plano'),
                      onChanged: (v) => setState(() => _plan = v),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: TextFormField(
                      initialValue: _value.toStringAsFixed(2),
                      decoration: const InputDecoration(labelText: 'Valor'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setState(() => _value = double.tryParse(v.replaceAll(',', '.')) ?? _value),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: TextFormField(
                      initialValue: _user,
                      decoration: const InputDecoration(labelText: 'Usuário'),
                      onChanged: (v) => setState(() => _user = v),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: TextFormField(
                      initialValue: _server,
                      decoration: const InputDecoration(labelText: 'Servidor'),
                      onChanged: (v) => setState(() => _server = v),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      initialValue: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      onChanged: (v) => setState(() => _email = v),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: TextFormField(
                      initialValue: _phone,
                      decoration: const InputDecoration(labelText: 'Telefone'),
                      onChanged: (v) => setState(() => _phone = v),
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: TextFormField(
                      initialValue: _obs,
                      decoration: const InputDecoration(labelText: 'Observação'),
                      onChanged: (v) => setState(() => _obs = v),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      initialValue: _id.toString(),
                      decoration: const InputDecoration(labelText: 'ID'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setState(() => _id = int.tryParse(v) ?? _id),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: cs.surfaceContainerHigh,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(_renderPreview(), style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await Clipboard.setData(ClipboardData(text: _renderPreview()));
                        messenger.showSnackBar(const SnackBar(content: Text('Prévia copiada')));
                      },
                      icon: const Icon(Icons.copy_all),
                      label: const Text('Copiar'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: Text(
                  'Dicas: use *texto* para negrito, _texto_ para itálico, ~texto~ para tachado, `texto` para monospace. Tokens serão substituídos automaticamente.',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save), label: const Text('Salvar')),
            ]),
          ],
        ),
      ),
    );
  }

  String _renderPreview() {
    final greeting = _greeting();
    final due = '${_due.day.toString().padLeft(2, '0')}/${_due.month.toString().padLeft(2, '0')}/${_due.year}';
    final now = DateTime.now();
    final dataAtual = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final horaAtual = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final valorStr = _value.toStringAsFixed(2).replaceAll('.', ',');
    var out = _controller.text;
    final map = {
      '{SAUDACAO}': greeting,
      '{NOME}': _name,
      '{VENCIMENTO}': due,
      '{PLANO}': _plan,
      '{VALOR}': 'R\$ $valorStr',
      '{USUARIO}': _user,
      '{SERVIDOR}': _server,
      '{EMAIL}': _email,
      '{TELEFONE}': _phone,
      '{OBSERVACAO}': _obs,
      '{ID}': _id.toString(),
      '{DATA_ATUAL}': dataAtual,
      '{HORA_ATUAL}': horaAtual,
    };
    for (final e in map.entries) {
      out = out.replaceAll(e.key, e.value);
    }
    return out.split('\n').where((l) => l.trim().isNotEmpty).join('\n');
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }
}