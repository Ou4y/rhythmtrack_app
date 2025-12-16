import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/app_usage.dart';
import '../models/installed_app.dart';
import '../models/app_limit.dart';

import '../services/usage_stats_service.dart';
import '../services/installed_apps_service.dart';
import '../services/app_limit_service.dart';

import 'set_app_limit_screen.dart';

class ScreenTimeDashboard extends StatefulWidget {
  const ScreenTimeDashboard({super.key});

  @override
  State<ScreenTimeDashboard> createState() => _ScreenTimeDashboardState();
}

class _ScreenTimeDashboardState extends State<ScreenTimeDashboard> {
  bool _loading = true;
  List<AppUsage> _usages = [];
  List<InstalledApp> _installed = [];
  List<AppLimit> _limits = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final usage = await UsageStatsService.getTodayUsage();
    final installed = await InstalledAppsService.getInstalledApps();
    final limits = await AppLimitService.instance.getAllLimits();

    setState(() {
      _usages = usage;
      _installed = installed;
      _limits = limits;
      _loading = false;
    });
  }

  InstalledApp? _getInstalledInfo(String packageName) {
    try {
      return _installed.firstWhere((app) => app.packageName == packageName);
    } catch (_) {
      return null;
    }
  }

  AppLimit? _getLimitForApp(String packageName) {
    try {
      return _limits.firstWhere((limit) => limit.packageName == packageName);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes =
        _usages.fold<int>(0, (sum, usage) => sum + usage.totalMinutes);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A20),
        elevation: 0,
        title: const Text(
          'Screen Time Control',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryCard(totalMinutes),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _usages.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildUsageTile(_usages[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAddLimitButton(),
                ],
              ),
            ),
    );
  }

  // SUMMARY CARD (top)
  Widget _buildSummaryCard(int minutes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151F28),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's screen time",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            _formatMinutes(minutes),
            style: const TextStyle(color: Colors.white, fontSize: 32),
          ),
        ],
      ),
    );
  }

  // TILE FOR EACH APP
  Widget _buildUsageTile(AppUsage usage) {
    final installed = _getInstalledInfo(usage.packageName);

    final appName = installed?.appName ?? usage.packageName;

    final iconWidget = installed == null
        ? const Icon(Icons.apps, color: Colors.white, size: 26)
        : Image.memory(
            base64Decode(installed.iconBase64),
            width: 30,
            height: 30,
          );

    // Load real saved limit from SQLite
    final AppLimit? limit = _getLimitForApp(usage.packageName);
    final double limitMinutes = (limit?.limitMinutes ?? 60).toDouble();

    final double ratio =
        (usage.totalMinutes / limitMinutes).clamp(0.0, 1.0);

    // Progress bar color
    Color barColor;
    if (ratio >= 1) {
      barColor = Colors.red;
    } else if (ratio >= 0.8) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with icon + name + usage
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: iconWidget,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  appName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '${usage.totalMinutes} min',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 5,
              color: Colors.white12,
              child: FractionallySizedBox(
                widthFactor: ratio,
                child: Container(color: barColor),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Limit label
          Text(
            "Limit: ${limitMinutes.toInt()} min/day",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // BUTTON: Add App Limit
  Widget _buildAddLimitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SetAppLimitScreen(),
            ),
          );

          if (result != null) {
            final newLimit = AppLimit(
              packageName: result["packageName"],
              appName: result["appName"],
              iconBase64: result["iconBase64"],
              limitMinutes: result["limitMinutes"],
            );

            // Save to SQLite
            await AppLimitService.instance.saveLimit(newLimit);

            // Reload dashboard
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Add App Limit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format time like "2h 14m"
  String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}