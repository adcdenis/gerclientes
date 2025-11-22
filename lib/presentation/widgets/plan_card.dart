import 'package:flutter/material.dart';
import 'package:gerclientes/data/models/plan_model.dart';
import 'package:intl/intl.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PlanCard({
    super.key,
    required this.plan,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

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
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, onDelete != null ? 56 : 16, 16),
                child: Row(
                  children: [
                    Container(
                      constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.card_membership, color: cs.primary, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.attach_money, size: 14, color: cs.primary),
                              const SizedBox(width: 4),
                              Text(
                                currency.format(plan.value),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant,
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
            ),
          ),
          if (onDelete != null)
            Positioned(
              right: 6,
              top: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, color: cs.onSurfaceVariant),
                    tooltip: 'Excluir plano',
                    iconSize: 14,
                    padding: EdgeInsets.zero,
                    splashRadius: 12,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    constraints: const BoxConstraints.tightFor(width: 18, height: 18),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
