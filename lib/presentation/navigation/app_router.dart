import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/dashboard_page.dart';
import '../pages/reports_page.dart';
import '../pages/backup_tabs_page.dart';
import '../pages/servers_page.dart';
import 'package:gerclientes/data/models/server_model.dart';
import '../pages/plans_page.dart';
import 'package:gerclientes/data/models/plan_model.dart';
import '../pages/clients_page.dart';
import 'package:gerclientes/data/models/client_model.dart';
import '../widgets/app_shell.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            pageBuilder: (context, state) => const MaterialPage(child: DashboardPage()),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            pageBuilder: (context, state) => const MaterialPage(child: ReportsPage()),
          ),
          GoRoute(
            path: '/backup',
            name: 'backup',
            pageBuilder: (context, state) => const MaterialPage(child: BackupTabsPage(initialIndex: 0)),
          ),
          GoRoute(
            path: '/cloud-backup',
            name: 'cloud_backup',
            pageBuilder: (context, state) => const MaterialPage(child: BackupTabsPage(initialIndex: 0)),
          ),
          GoRoute(
            path: '/servers',
            name: 'servers',
            pageBuilder: (context, state) => const MaterialPage(child: ServersPage()),
          ),
          GoRoute(
            path: '/servers/new',
            name: 'server_new',
            pageBuilder: (context, state) => const MaterialPage(child: ServerFormPage()),
          ),
          GoRoute(
            path: '/servers/:id/edit',
            name: 'server_edit',
            pageBuilder: (context, state) => MaterialPage(child: ServerFormPage(initialServer: state.extra as Server?)),
          ),
          GoRoute(
            path: '/plans',
            name: 'plans',
            pageBuilder: (context, state) => const MaterialPage(child: PlansPage()),
          ),
          GoRoute(
            path: '/plans/new',
            name: 'plan_new',
            pageBuilder: (context, state) => const MaterialPage(child: PlanFormPage()),
          ),
          GoRoute(
            path: '/plans/:id/edit',
            name: 'plan_edit',
            pageBuilder: (context, state) => MaterialPage(child: PlanFormPage(initialPlan: state.extra as Plan?)),
          ),
          GoRoute(
            path: '/clients',
            name: 'clients',
            pageBuilder: (context, state) => const MaterialPage(child: ClientsPage()),
          ),
          GoRoute(
            path: '/clients/new',
            name: 'client_new',
            pageBuilder: (context, state) => const MaterialPage(child: ClientFormPage()),
          ),
          GoRoute(
            path: '/clients/:id/edit',
            name: 'client_edit',
            pageBuilder: (context, state) => MaterialPage(child: ClientFormPage(initialClient: state.extra as Client?)),
          ),
        ],
      ),
    ],
  );
}
