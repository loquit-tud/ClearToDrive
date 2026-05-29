import 'package:cleartodrive/core/build_info.dart';
import 'package:cleartodrive/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cleartodrive/presentation/providers/app_providers.dart';
import 'package:cleartodrive/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _sendTestNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(sendTestNotificationUseCaseProvider).execute();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.testNotificationScheduled)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.testNotificationFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final permission = ref.watch(notificationPermissionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SettingsSection(
            title: l10n.settingsReminders,
            child: ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(l10n.settingsReminders),
              subtitle: Text(l10n.reminderDefaultsHint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/reminders'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsSection(
            title: l10n.notificationPermissionsTitle,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  permission.when(
                    data: (enabled) => Text(
                      enabled
                          ? l10n.notificationPermissionsEnabled
                          : l10n.notificationPermissionsDisabled,
                    ),
                    loading: () => Text(l10n.checking),
                    error: (_, _) => Text(l10n.notificationPermissionsUnknown),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  permission.when(
                    data: (enabled) => enabled
                        ? const SizedBox.shrink()
                        : Text(
                            l10n.notificationDeniedExplanation,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: () async {
                      await ref
                          .read(notificationPermissionProvider.notifier)
                          .request();
                    },
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(l10n.requestPermission),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.howToEnableNotificationsTitle),
                          content: Text(l10n.howToEnableNotificationsBody),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(l10n.ok),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.help_outline),
                    label: Text(l10n.help),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notification_add_outlined),
                    title: Text(l10n.sendTestNotification),
                    subtitle: Text(l10n.sendTestNotificationHint),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _sendTestNotification(context, ref),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsSection(
            title: 'Date și confidențialitate',
            child: ListTile(
              leading: const Icon(Icons.phone_android_outlined),
              title: Text(l10n.dataStaysOnDevice),
              subtitle: const Text('Nu folosim conturi, cloud sau backend.'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsSection(
            title: l10n.buildInfoTitle,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.buildInfoTitle),
                  subtitle: Text(
                    l10n.buildInfoValue(
                      BuildInfo.buildLabel,
                      BuildInfo.appVersion,
                      DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    ),
                  ),
                ),
                const Divider(),
                const AboutListTile(
                  applicationName: 'ClearToDrive',
                  applicationVersion: BuildInfo.appVersion,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.cardRadius,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          child,
        ],
      ),
    );
  }
}
