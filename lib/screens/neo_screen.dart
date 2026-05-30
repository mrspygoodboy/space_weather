import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/neo_provider.dart';
import '../widgets/neo_tile.dart';
import '../widgets/state_widgets.dart' as sw;

class NeoScreen extends StatefulWidget {
  const NeoScreen({super.key});

  @override
  State<NeoScreen> createState() => _NeoScreenState();
}

class _NeoScreenState extends State<NeoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NeoProvider>().loadNearEarthObjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NeoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Near-Earth Objects'),
        actions: [
          if (provider.status == NeoStatus.success)
            IconButton(
              icon: Icon(
                provider.showHazardousOnly
                    ? Icons.warning_amber_rounded
                    : Icons.warning_amber_outlined,
                color: provider.showHazardousOnly
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
              tooltip: 'Show hazardous only',
              onPressed: provider.toggleHazardousFilter,
            ),
        ],
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, NeoProvider provider) {
    switch (provider.status) {
      case NeoStatus.initial:
      case NeoStatus.loading:
        return const sw.LoadingWidget(message: 'Scanning for asteroids...');

      case NeoStatus.error:
        return sw.ErrorWidget2(
          message: provider.errorMessage,
          onRetry: provider.loadNearEarthObjects,
        );

      case NeoStatus.success:
        if (provider.objects.isEmpty) {
          return sw.EmptyWidget(
            title: provider.showHazardousOnly
                ? 'No hazardous objects found'
                : 'No objects found',
            subtitle: provider.showHazardousOnly
                ? 'No potentially hazardous asteroids this week.'
                : 'No near-earth objects in range.',
            icon: Icons.circle_outlined,
            onAction: provider.showHazardousOnly
                ? provider.toggleHazardousFilter
                : null,
            actionLabel:
                provider.showHazardousOnly ? 'Show all objects' : null,
          );
        }

        return Column(
          children: [
            if (provider.hazardousCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .errorContainer
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color:
                              Theme.of(context).colorScheme.error,
                          size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${provider.hazardousCount} potentially hazardous object${provider.hazardousCount > 1 ? 's' : ''} this week',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.loadNearEarthObjects,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: provider.objects.length,
                  itemBuilder: (context, i) {
                    final neo = provider.objects[i];
                    return NeoTile(
                      neo: neo,
                      onTap: () => context.push(
                        '/neo/${Uri.encodeComponent(neo.id)}',
                        extra: neo,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
    }
  }
}
