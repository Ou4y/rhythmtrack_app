import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/app_usage.dart';
import '../models/installed_app.dart';
import '../models/app_limit.dart';

import '../services/usage_stats_service.dart';
import '../services/installed_apps_service.dart';
import '../services/app_limit_service.dart';
import 'package:rhythmtrack_app/services/notification_service.dart';

import 'set_app_limit_screen.dart';
import 'app_limit_detail_screen.dart';

class ScreenTimeDashboard extends StatefulWidget {
  const ScreenTimeDashboard({super.key});

  @override
  State<ScreenTimeDashboard> createState() => _ScreenTimeDashboardState();
}

class _ScreenTimeDashboardState extends State<ScreenTimeDashboard> {
  bool _loading = true;

  List<AppUsage> _usages = [];
  List<InstalledApp> _installedApps = [];
  List<AppLimit> _limits = [];

  AppLimit? _lastDeletedLimit;
  bool _snackBarVisible = false;

  @override
  void initState() {
    super.initState();
    NotificationService.init(context);
    NotificationService.scheduleAllReminders();
    _loadData();
  }

  // ───────────────── DATA ─────────────────

  Future<void> _loadData() async {
    if (mounted) setState(() => _loading = true);

    final usage = await UsageStatsService.getTodayUsage();
    final installed = await InstalledAppsService.getInstalledApps();
    final limits = await AppLimitService.instance.getAllLimits();

    if (!mounted) return;

    setState(() {
      _usages = usage;
      _installedApps = installed;
      _limits = limits;
      _loading = false;
    });
  }

  InstalledApp? _installedFor(String packageName) {
    try {
      return _installedApps.firstWhere(
        (a) => a.packageName == packageName,
      );
    } catch (_) {
      return null;
    }
  }

  AppLimit? _limitFor(String packageName) {
    try {
      return _limits.firstWhere(
        (l) => l.packageName == packageName,
      );
    } catch (_) {
      return null;
    }
  }

  // ───────────────── SNACKBAR FIX ─────────────────

  void _showUndoSnackBar() {
    if (_lastDeletedLimit == null || _snackBarVisible) return;

    _snackBarVisible = true;

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: const Text('App limit deleted'),
            duration: const Duration(seconds: 4), // ✅ FIX
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () async {
                final limit = _lastDeletedLimit;
                if (limit == null) return;

                await AppLimitService.instance.saveLimit(limit);
                if (!mounted) return;

                _lastDeletedLimit = null;
                _snackBarVisible = false;
                await _loadData();
              },
            ),
          ),
        )
        .closed
        .then((_) {
          _snackBarVisible = false;
          _lastDeletedLimit = null;
        });
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Screen Time', style: theme.textTheme.titleLarge),
        shape: theme.appBarTheme.shape,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: cs.primary,
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 300),
                  Center(
                    child: CircularProgressIndicator(color: cs.primary),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ..._usages.map(_buildUsageTile),
                  _buildAddLimitButton(context),
                ],
              ),
      ),
    );
  }

  Widget _buildUsageTile(AppUsage usage) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final installed = _installedFor(usage.packageName);
    final limit = _limitFor(usage.packageName);

    final used = usage.totalMinutes;
    final max = limit?.limitMinutes;

    final hasLimit = max != null && max > 0;
    final progress =
        hasLimit ? (used / max).clamp(0.0, 1.0) : 0.0;

    final remaining =
        hasLimit ? (max - used).clamp(0, max) : 0;

    Color progressColor;
    String statusText = '';

    if (!hasLimit) {
      progressColor = cs.primary;
    } else if (used >= max) {
      progressColor = cs.error;
      statusText = 'Limit exceeded';
    } else if (progress >= 0.8) {
      progressColor = cs.secondary;
      statusText = '$remaining min left';
    } else {
      progressColor = cs.primary;
      statusText = '$remaining min left';
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => hasLimit
                ? AppLimitDetailScreen(limit: limit!, usage: usage)
                : SetAppLimitScreen(
                    preselectedPackageName: usage.packageName,
                  ),
          ),
        );

        if (!mounted) return;

        if (result is AppLimit) {
          _lastDeletedLimit = result;
          await _loadData();
          _showUndoSnackBar();
        } else if (result == true) {
          await _loadData();
        } else if (result is Map<String, dynamic>) {
          await AppLimitService.instance.saveLimit(
            AppLimit(
              packageName: result['packageName'],
              appName: result['appName'],
              iconBase64: result['iconBase64'],
              limitMinutes: result['limitMinutes'],
            ),
          );
          await _loadData();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                installed?.iconBase64.isEmpty ?? true
                    ? Icon(Icons.apps, color: theme.iconTheme.color)
                    : Image.memory(
                        base64Decode(installed!.iconBase64),
                        width: 32,
                        height: 32,
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    installed?.appName ?? usage.packageName,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text('$used min', style: theme.textTheme.bodySmall),
              ],
            ),
            if (hasLimit) ...[
              const SizedBox(height: 6),
              Text(
                '$used / $max min  •  $statusText',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: used >= max ? cs.error : null,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: cs.primary.withOpacity(0.15),
                  color: progressColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddLimitButton(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SetAppLimitScreen(),
              ),
            );

            if (result != null && mounted) {
              await AppLimitService.instance.saveLimit(
                AppLimit(
                  packageName: result['packageName'],
                  appName: result['appName'],
                  iconBase64: result['iconBase64'],
                  limitMinutes: result['limitMinutes'],
                ),
              );
              await _loadData();
            }
          },
          child: Text(
            'Add App Limit',
            style: TextStyle(
              color: cs.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}