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
  final VoidCallback? onRenew;
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
    this.onRenew,
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
      child: Stack(
        children: [
          InkWell(
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
                      constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.person, color: cs.primary, size: 22),
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
          if (showActions && (onRenew != null || onWhatsApp != null || onDelete != null))
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onRenew != null)
                      IconButton(
                        onPressed: onRenew,
                        icon: Icon(Icons.autorenew, color: cs.primary),
                        tooltip: 'Renovar ( +30 dias )',
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                      ),
                    if (onRenew != null && (onWhatsApp != null || onDelete != null))
                      const SizedBox(width: 4),
                    if (onWhatsApp != null)
                      IconButton(
                        onPressed: onWhatsApp,
                        icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                        tooltip: 'WhatsApp',
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                      ),
                    if (onWhatsApp != null && onDelete != null)
                      const SizedBox(width: 4),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(Icons.delete_outline, color: cs.onSurfaceVariant),
                        tooltip: 'Excluir',
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ColorScheme cs) {
    return Row(
      children: [
        Container(
          constraints: const BoxConstraints.tightFor(width: 20, height: 20),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: cs.primary),
        ),
        const SizedBox(width: 8),
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
