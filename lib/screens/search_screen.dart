import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/solar_flares_provider.dart';
import '../utils/validators.dart';
import '../widgets/solar_flare_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String? _errorText;
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch() {
    // Validate using the dedicated validator — not inside widget logic
    final error = Validators.validateSearchQuery(_controller.text);
    setState(() {
      _errorText = error;
    });
    if (error != null) return;

    final query = _controller.text.trim();
    setState(() => _hasSearched = true);
    context.read<SolarFlaresProvider>().setSearchQuery(query);
  }

  void _onClear() {
    _controller.clear();
    setState(() {
      _errorText = null;
      _hasSearched = false;
    });
    context.read<SolarFlaresProvider>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolarFlaresProvider>();
    final results = _hasSearched ? provider.flares : [];

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Search flares by class, location or notes…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: _onClear,
                            )
                          : null,
                      errorText: _errorText,
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: (_) {
                      if (_errorText != null) {
                        setState(() => _errorText = null);
                      }
                    },
                    onFieldSubmitted: (_) => _onSearch(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _onSearch,
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Search'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _hasSearched
                ? results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.4)),
                            const SizedBox(height: 16),
                            Text('No flares match "${_controller.text}"'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.only(top: 8, bottom: 24),
                        itemCount: results.length,
                        itemBuilder: (context, i) {
                          final flare = results[i];
                          return SolarFlareTile(
                            flare: flare,
                            onTap: () => context.push(
                              '/flare/${Uri.encodeComponent(flare.id)}',
                              extra: flare,
                            ),
                          );
                        },
                      )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wb_sunny_outlined,
                              size: 56,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'Search solar flares',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a flare class (X1, M5), a source location (N20W10), or keywords from notes.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
