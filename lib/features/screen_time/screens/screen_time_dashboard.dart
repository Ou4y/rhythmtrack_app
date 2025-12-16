import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/app_usage.dart';
import '../models/installed_app.dart';
import '../models/app_limit.dart';

import '../services/usage_stats_service.dart';
import '../services/installed_apps_service.dart';
import '../services/app_limit_service.dart';

import 'set_app_limit_screen.dart';
import 'app_limit_detail_screen.dart';

class ScreenTimeDashboard extends StatefulWidget {
  const ScreenTimeDashboard({super.key});

  @override
  State<ScreenTimeDashboard> createState() =>
      _ScreenTimeDashboardState();
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
    _loadData();
  }

  // ================= DATA =================
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

  // ================= SNACKBAR =================
  void _showUndoSnackBar() {
    if (_lastDeletedLimit == null || _snackBarVisible) return;

    _snackBarVisible = true;

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: const Text('App limit deleted'),
            duration: const Duration(seconds: 4),
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final totalMinutes =
        _usages.fold<int>(0, (sum, u) => sum + u.totalMinutes);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A20),
        elevation: 0,
        title: const Text(
          "Screen Time Control",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.blue,
        backgroundColor: const Color(0xFF151F28),
        child: _loading
            ?  ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 300),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCard(totalMinutes),
                  const SizedBox(height: 20),
                  ..._usages.map(_buildUsageTile),
                  const SizedBox(height: 24),
                  _buildAddLimitButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildSummaryCard(int minutes) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151F28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's screen time",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            _formatMinutes(minutes),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageTile(AppUsage usage) {
    final installed = _installedFor(usage.packageName);
    final limit = _limitFor(usage.packageName);

    final appName = installed?.appName ?? usage.packageName;
    final iconBase64 = installed?.iconBase64 ?? "";

    return GestureDetector(
      onTap: () async {
        if (limit != null) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AppLimitDetailScreen(limit: limit, usage: usage),
            ),
          );

          if (!mounted) return;

          if (result is AppLimit) {
            _lastDeletedLimit = result;
            await _loadData();
            _showUndoSnackBar();
          } else if (result == true) {
            await _loadData();
          }
        } else {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SetAppLimitScreen(
                preselectedPackageName: usage.packageName,
              ),
            ),
          );

          if (result != null && mounted) {
            await AppLimitService.instance.saveLimit(
              AppLimit(
                packageName: result["packageName"],
                appName: result["appName"],
                iconBase64: result["iconBase64"],
                limitMinutes: result["limitMinutes"],
              ),
            );
            await _loadData();
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                iconBase64.isEmpty
                    ? const Icon(Icons.apps, color: Colors.white)
                    : Image.memory(
                        base64Decode(iconBase64),
                        width: 32,
                        height: 32,
                      ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    appName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  "${usage.totalMinutes} min",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Limit text
            Text(
              limit != null
                  ? "Limit: ${limit.limitMinutes} min/day"
                  : "No limit set",
              style: TextStyle(
                color:
                    limit != null ? Colors.white60 : Colors.white38,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddLimitButton() {
    return ElevatedButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SetAppLimitScreen()),
        );

        if (result != null && mounted) {
          await AppLimitService.instance.saveLimit(
            AppLimit(
              packageName: result["packageName"],
              appName: result["appName"],
              iconBase64: result["iconBase64"],
              limitMinutes: result["limitMinutes"],
            ),
          );
          await _loadData();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0EA5E9),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: const Text(
        "Add App Limit",
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return "${h}h ${m}m";
  }
}