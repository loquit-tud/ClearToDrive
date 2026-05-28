import 'package:cleartodrive/application/use_cases/list_documents_use_case.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:cleartodrive/presentation/widgets/document_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<List<DocumentWithVehicle>>? _listFuture;
  int? _loadedRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final refresh = ref.watch(documentsRefreshProvider);
    final notificationStatus = ref.watch(notificationPermissionProvider);

    if (_listFuture == null || _loadedRefresh != refresh) {
      _loadedRefresh = refresh;
      _listFuture = ref.read(listDocumentsUseCaseProvider).execute();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car_outlined),
            onPressed: () => context.push('/vehicles'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addDocument),
      ),
      body: FutureBuilder(
        future: _listFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: (items.isEmpty ? 1 : items.length) + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return notificationStatus.when(
                  data: (enabled) => enabled
                      ? const SizedBox.shrink()
                      : Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.notifications_off_outlined,
                            ),
                            title: Text(l10n.notificationPermissionsDisabled),
                            subtitle: Text(l10n.notificationDeniedExplanation),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push('/settings'),
                          ),
                        ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                );
              }

              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noDocuments,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.noDocumentsHint, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => context.push('/add'),
                          child: Text(l10n.addDocument),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final item = items[index - 1];
              return DocumentCard(
                typeLabel: documentTypeLabel(l10n, item.document.type),
                plate: item.plate,
                expiryDate: item.document.expiryDate,
                onTap: () => context.push('/document/${item.document.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
