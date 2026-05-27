import 'package:cleartodrive/domain/entities/vehicle.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  Future<List<Vehicle>> _load() =>
      ref.read(vehicleRepositoryProvider).getAll();

  Future<void> _showAddDialog() async {
    final l10n = AppLocalizations.of(context);
    final plateController = TextEditingController();
    final nameController = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addVehicle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: plateController,
              decoration: InputDecoration(labelText: l10n.licensePlate),
              textCapitalization: TextCapitalization.characters,
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.displayName),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (saved == true && plateController.text.trim().isNotEmpty) {
      final now = DateTime.now();
      await ref.read(vehicleRepositoryProvider).upsert(
            Vehicle(
              id: const Uuid().v4(),
              licensePlate: plateController.text.trim().toUpperCase(),
              displayName: nameController.text.trim().isEmpty
                  ? null
                  : nameController.text.trim(),
              createdAt: now,
              updatedAt: now,
            ),
          );
      setState(() {});
    }

    plateController.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vehicles)),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final vehicles = snapshot.data ?? [];
          if (vehicles.isEmpty) {
            return Center(child: Text(l10n.noVehicles));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final v = vehicles[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_car_outlined),
                  title: Text(v.licensePlate),
                  subtitle: v.displayName != null ? Text(v.displayName!) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
