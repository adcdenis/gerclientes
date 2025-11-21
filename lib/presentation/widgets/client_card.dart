import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gerclientes/data/models/client_model.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final String serverName;
  final String planName;
  final double? planValue;
  final VoidCallback? onTap;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onDelete;
  final bool showActions;

  const ClientCard({
    super.key,
    required this.client,
    required this.serverName,
    required this.planName,
    this.planValue,
    this.onTap,
    this.onWhatsApp,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isExpired = client.dueDate.isBefore(today);
    final daysUntilDue = client.dueDate.difference(today).inDays;
    
    // Definir cor do status
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (isExpired) {
      statusColor = Colors.red;
      statusText = 'Vencido';
      statusIcon = Icons.warning_rounded;
    } else if (daysUntilDue <= 3) {
      statusColor = Colors.orange;
      statusText = daysUntilDue == 0 ? 'Vence hoje' : 'Vence em $daysUntilDue dias';
      statusIcon = Icons.schedule;
    } else {
      statusColor = Colors.green;
      statusText = 'Ativo';
      statusIcon = Icons.check_circle;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.surface,
                cs.surfaceContainerHighest.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com nome e ações
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person, color: cs.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(statusIcon, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (showActions) ...[
                      if (onWhatsApp != null)
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                          tooltip: 'Enviar mensagem WhatsApp',
                          onPressed: onWhatsApp,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(Icons.delete, color: cs.error),
                          tooltip: 'Excluir cliente',
                          onPressed: onDelete,
                        ),
                    ],
                  ],
                ),
              ),
              // Conteúdo do card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInfoRow(Icons.email_outlined, 'Email', client.email ?? '-', cs),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoRow(Icons.phone_outlined, 'Telefone', client.phone ?? '-', cs),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInfoRow(Icons.dns_outlined, 'Servidor', serverName, cs),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoRow(Icons.card_membership_outlined, 'Plano', planName, cs),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInfoRow(Icons.calendar_today_outlined, 'Vencimento', DateFormat('dd/MM/yyyy').format(client.dueDate), cs),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoRow(Icons.attach_money, 'Valor', planValue != null ? currency.format(planValue) : '-', cs),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ColorScheme cs) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: cs.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
