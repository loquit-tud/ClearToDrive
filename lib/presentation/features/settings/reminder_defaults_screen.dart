import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReminderDefaultsScreen extends ConsumerWidget {
  const ReminderDefaultsScreen({super.key});

  Future<void> _maybeApplyToExisting(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.applyToExistingTitle),
        content: Text(l10n.applyToExistingBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.applyNow),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final count = await ref.read(rescheduleAllRemindersUseCaseProvider).execute();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.appliedToExistingCount(count))),
        );
      }
    }
  }

  Future<void> _toggleOffset(
    WidgetRef ref,
    BuildContext context,
    int days,
    bool enabled,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await ref
        .read(reminderPolicyProvider.notifier)
        .toggleOffset(days, enabled);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectOneReminder)),
      );
      return;
    }

    if (ok && context.mounted) {
      await _maybeApplyToExisting(ref, context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final policy = ref.watch(reminderPolicyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reminderDefaults)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.reminderDefaultsHint,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(l10n.daysBefore30),
            value: policy.daysBefore.contains(30),
            onChanged: (v) => _toggleOffset(ref, context, 30, v),
          ),
          SwitchListTile(
            title: Text(l10n.daysBefore14),
            value: policy.daysBefore.contains(14),
            onChanged: (v) => _toggleOffset(ref, context, 14, v),
          ),
          SwitchListTile(
            title: Text(l10n.daysBefore7),
            value: policy.daysBefore.contains(7),
            onChanged: (v) => _toggleOffset(ref, context, 7, v),
          ),
          SwitchListTile(
            title: Text(l10n.daysBefore1),
            value: policy.daysBefore.contains(1),
            onChanged: (v) => _toggleOffset(ref, context, 1, v),
          ),
          SwitchListTile(
            title: Text(l10n.dayOfExpiry),
            value: policy.dayOf,
            onChanged: (v) async {
              final ok =
                  await ref.read(reminderPolicyProvider.notifier).setDayOf(v);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.selectOneReminder)),
                );
                return;
              }
              if (ok && context.mounted) {
                await _maybeApplyToExisting(ref, context);
              }
            },
          ),
        ],
      ),
    );
  }
}
