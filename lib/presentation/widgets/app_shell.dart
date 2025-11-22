import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gerclientes/state/providers.dart';
import 'package:intl/intl.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ouve eventos de restauração e mostra uma mensagem com data/hora exata
    ref.listen(cloudRestoreEventProvider, (prev, next) {
      next.whenData((dt) {
        final formatted = DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dados atualizados. Restauração de $formatted.')),
        );
      });
    });
    return PopScope(
        // Intercepta sempre o botão voltar para aplicar regra:
        // voltar leva à listagem de contadores; somente nela perguntar para sair.
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          // Se o Drawer estiver aberto, feche-o e não trate como "voltar" da página
        final scaffoldState = Scaffold.maybeOf(context);
        if (scaffoldState?.isDrawerOpen == true) {
          scaffoldState!.closeDrawer();
          return;
        }
        final router = GoRouter.of(context);
        final location = GoRouterState.of(context).uri.toString();
        if (location == '/') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sair do aplicativo'),
              content: const Text('Deseja realmente fechar o app?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sair')),
              ],
            ),
          );
          if (confirm == true) {
            SystemNavigator.pop();
          }
        } else {
          if (location.startsWith('/servers') && location != '/servers') {
            router.go('/servers');
          } else if (location.startsWith('/plans') && location != '/plans') {
            router.go('/plans');
          } else if (location.startsWith('/clients') && location != '/clients') {
            router.go('/clients');
          } else if (location.startsWith('/reports')) {
            router.go('/');
          } else if (location.startsWith('/cloud-backup')) {
            router.go('/backup');
          } else {
            router.go('/');
          }
        }
      },
      child: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final selectedIndex = _selectedIndexForLocation(GoRouterState.of(context).uri.toString());
        final cs = Theme.of(context).colorScheme;
        final title = Row(
          children: const [
            Icon(Icons.people),
            SizedBox(width: 8),
            Text('GerClientes'),
          ],
        );

      if (isWide) {
        return Scaffold(
          appBar: AppBar(title: title, actions: const [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: _ProfileAvatar(),
            ),
          ]),
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) => _goToIndex(context, index),
                extended: constraints.maxWidth >= 1200,
                // Quando extended=true, labelType deve ser null/none.
                labelType: (constraints.maxWidth >= 1200)
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                useIndicator: true,
                elevation: 2,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                indicatorColor: Theme.of(context).colorScheme.primaryContainer,
                leading: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Row(children: [
                          Icon(Icons.people),
                          SizedBox(width: 8),
                          Text('GerClientes', style: TextStyle(fontWeight: FontWeight.w600)),
                        ]),
                        SizedBox(height: 4),
                        Text('Gerencie clientes, planos e servidores', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                trailing: const Padding(
                  padding: EdgeInsets.all(12),
                  child: _VersionFooter(),
                ),
                destinations: [
                  NavigationRailDestination(icon: Icon(Icons.dashboard_outlined, color: cs.primary), selectedIcon: Icon(Icons.dashboard, color: cs.primary), label: const Text('Dashboard')),
                  NavigationRailDestination(icon: Icon(Icons.people_outline, color: cs.secondary), selectedIcon: Icon(Icons.people, color: cs.secondary), label: const Text('Clientes')),
                  NavigationRailDestination(icon: Icon(Icons.assignment_outlined, color: cs.primary), selectedIcon: Icon(Icons.assignment, color: cs.primary), label: const Text('Relatórios')),
                  NavigationRailDestination(icon: Icon(Icons.sync_alt, color: cs.secondary), selectedIcon: Icon(Icons.sync, color: cs.secondary), label: const Text('Backup')),
                  NavigationRailDestination(icon: Icon(Icons.dns_outlined, color: cs.tertiary), selectedIcon: Icon(Icons.dns, color: cs.tertiary), label: const Text('Servidores')),
                  NavigationRailDestination(icon: Icon(Icons.request_quote_outlined, color: cs.error), selectedIcon: Icon(Icons.request_quote, color: cs.error), label: const Text('Planos')),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(title: title, centerTitle: false, actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: _ProfileAvatar(),
          ),
        ]),
        drawer: _AppDrawer(selectedIndex: selectedIndex, onNavigateIndex: (index) => _goToIndex(context, index)),
        body: child,
      );
    }),
    );
  }

  int _selectedIndexForLocation(String location) {
    if (location.startsWith('/clients')) return 1;
    if (location.startsWith('/reports')) return 2;
    if (location.startsWith('/backup')) return 3;
    if (location.startsWith('/cloud-backup')) return 3;
    if (location.startsWith('/servers')) return 4;
    if (location.startsWith('/plans')) return 5;
    return 0;
  }

  void _goToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/clients');
        break;
      case 2:
        context.go('/reports');
        break;
      case 3:
        context.go('/backup');
        break;
      case 4:
        context.go('/servers');
        break;
      case 5:
        context.go('/plans');
        break;
    }
  }
}

class _AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavigateIndex;
  const _AppDrawer({required this.selectedIndex, required this.onNavigateIndex});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget item(IconData icon, String label, bool selected, VoidCallback onTap, Color iconColor) {
      final bg = selected ? cs.primaryContainer : cs.surfaceContainerHigh;
      final fg = selected ? cs.onPrimaryContainer : cs.onSurface;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Scaffold.maybeOf(context)?.closeDrawer();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );
    }

    return Drawer(
      child: SafeArea(
        child: Column(children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cs.primaryContainer, cs.secondaryContainer],
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Row(children: [
                Icon(Icons.people, size: 28),
                SizedBox(width: 10),
                Text('GerClientes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              ]),
              SizedBox(height: 4),
              Text('Gerencie clientes, planos e servidores', style: TextStyle(fontSize: 12)),
            ]),
          ),
          Expanded(
            child: ListView(children: [
              item(Icons.dashboard_outlined, 'Dashboard', selectedIndex == 0, () => onNavigateIndex(0), cs.primary),
              item(Icons.people_outline, 'Clientes', selectedIndex == 1, () => onNavigateIndex(1), cs.secondary),
              item(Icons.assignment_outlined, 'Relatórios', selectedIndex == 2, () => onNavigateIndex(2), cs.primary),
              item(Icons.dns_outlined, 'Servidores', selectedIndex == 4, () => onNavigateIndex(4), cs.tertiary),
              item(Icons.request_quote_outlined, 'Planos', selectedIndex == 5, () => onNavigateIndex(5), cs.error),
              item(Icons.sync_alt, 'Backup', selectedIndex == 3, () => onNavigateIndex(3), cs.secondary),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Scaffold.maybeOf(context)?.closeDrawer();
                    context.go('/message-template');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: BorderRadius.circular(14)),
                    child: Row(children: const [
                      Icon(Icons.message_outlined),
                      SizedBox(width: 10),
                      Text('Mensagem WhatsApp', style: TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _VersionFooter(),
          ),
        ]),
      ),
    );
  }
}

// Rodapé com a versão do aplicativo
class _VersionFooter extends ConsumerWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsync = ref.watch(appVersionProvider);
    final scheme = Theme.of(context).colorScheme;
    return versionAsync.when(
      loading: () => Text('Versão...', style: TextStyle(color: scheme.onSurfaceVariant)),
      error: (err, _) => Text('Versão indisponível', style: TextStyle(color: scheme.onSurfaceVariant)),
      data: (v) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(v, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// Avatar do usuário (topo direito): mostra foto do Google quando logado,
// e avatar padrão quando deslogado.
class _ProfileAvatar extends ConsumerWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(cloudUserProvider);
    final cs = Theme.of(context).colorScheme;
    Widget defaultAvatar() => CircleAvatar(
          radius: 16,
          backgroundColor: cs.surface,
          child: Icon(Icons.account_circle, size: 20, color: cs.onSurfaceVariant),
        );

    return userAsync.maybeWhen(
      data: (user) {
        if (user == null || user.photoUrl == null) {
          return defaultAvatar();
        }
        return CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(user.photoUrl!),
          backgroundColor: cs.surface,
        );
      },
      orElse: () => defaultAvatar(),
    );
  }
}
