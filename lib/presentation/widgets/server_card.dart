import 'package:flutter/material.dart';
import 'package:gerclientes/data/models/server_model.dart';

class ServerCard extends StatelessWidget {
  final Server server;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ServerCard({
    super.key,
    required this.server,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                Container(
                  constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.dns, color: cs.primary, size: 22),
                ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        server.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onDelete != null)
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
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline, color: cs.onSurfaceVariant),
                      tooltip: 'Excluir servidor',
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
}
