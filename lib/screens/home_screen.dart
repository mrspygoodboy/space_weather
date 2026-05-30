import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/solar_flares_provider.dart';
import '../models/solar_flare.dart';
import '../utils/app_router.dart';
import '../widgets/solar_flare_tile.dart';
import '../widgets/state_widgets.dart' as sw;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolarFlaresProvider>().loadFlares();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolarFlaresProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar Flares'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search',
            onPressed: () => context.push(AppRouter.search),
          ),
          _FilterMenu(provider: provider),
        ],
      ),
      drawer: _AppDrawer(),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, SolarFlaresProvider provider) {
    switch (provider.status) {
      case FlaresStatus.initial:
      case FlaresStatus.loading:
        return const sw.LoadingWidget(message: 'Fetching solar activity...');

      case FlaresStatus.error:
        return sw.ErrorWidget2(
          message: provider.errorMessage,
          onRetry: () => provider.loadFlares(),
        );

      case FlaresStatus.success:
        if (provider.flares.isEmpty) {
          return sw.EmptyWidget(
            title: provider.hasData
                ? 'No results match your filter'
                : 'No solar flares found',
            subtitle: provider.hasData
                ? 'Try clearing your filters.'
                : 'No events in the selected date range.',
            icon: Icons.wb_sunny_outlined,
            onAction: provider.hasData ? provider.clearFilters : null,
            actionLabel: provider.hasData ? 'Clear filters' : null,
          );
        }
        return RefreshIndicator(
          onRefresh: () => provider.loadFlares(),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: provider.flares.length,
            itemBuilder: (context, index) {
              final flare = provider.flares[index];
              return SolarFlareTile(
                flare: flare,
                onTap: () => context.push(
                  '/flare/${Uri.encodeComponent(flare.id)}',
                  extra: flare,
                ),
              );
            },
          ),
        );
    }
  }
}

class _FilterMenu extends StatelessWidget {
  final SolarFlaresProvider provider;
  const _FilterMenu({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isFiltered = provider.filterClass != null;
    return PopupMenuButton<FlareClass?>(
      icon: Badge(
        isLabelVisible: isFiltered,
        child: const Icon(Icons.filter_list_rounded),
      ),
      tooltip: 'Filter by class',
      onSelected: (cls) => provider.setFilterClass(cls),
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All classes')),
        const PopupMenuItem(value: FlareClass.x, child: Text('X — Extreme')),
        const PopupMenuItem(value: FlareClass.m, child: Text('M — Major')),
        const PopupMenuItem(value: FlareClass.c, child: Text('C — Moderate')),
        const PopupMenuItem(value: FlareClass.b, child: Text('B — Minor')),
      ],
    );
  }
}

class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NavigationDrawer(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.wb_sunny_rounded,
                  size: 36, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text('Space Weather',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text('NASA real-time data',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        const Divider(indent: 16, endIndent: 16),
        NavigationDrawerDestination(
          icon: const Icon(Icons.wb_sunny_outlined),
          selectedIcon: const Icon(Icons.wb_sunny_rounded),
          label: const Text('Solar Flares'),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.circle_outlined),
          selectedIcon: const Icon(Icons.circle),
          label: const Text('Near-Earth Objects'),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.search_outlined),
          selectedIcon: const Icon(Icons.search_rounded),
          label: const Text('Search'),
        ),
        const Divider(indent: 16, endIndent: 16),
        NavigationDrawerDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings_rounded),
          label: const Text('Settings'),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.info_outline_rounded),
          selectedIcon: const Icon(Icons.info_rounded),
          label: const Text('About'),
        ),
      ],
      onDestinationSelected: (index) {
        Navigator.pop(context);
        switch (index) {
          case 0:
            context.go(AppRouter.home);
          case 1:
            context.go(AppRouter.neo);
          case 2:
            context.go(AppRouter.search);
          case 3:
            context.go(AppRouter.settings);
          case 4:
            context.go(AppRouter.about);
        }
      },
    );
  }
}
