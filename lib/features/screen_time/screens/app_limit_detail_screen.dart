import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/app_limit.dart';
import '../models/app_usage.dart';
import '../services/app_limit_service.dart';

class AppLimitDetailScreen extends StatefulWidget {
  final AppLimit limit;
  final AppUsage usage;

  const AppLimitDetailScreen({
    super.key,
    required this.limit,
    required this.usage,
  });

  @override
  State<AppLimitDetailScreen> createState() => _AppLimitDetailScreenState();
}

class _AppLimitDetailScreenState extends State<AppLimitDetailScreen> {
  late int _selectedMinutes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.limit.limitMinutes;
  }

  Future<void> _saveLimit() async {
    setState(() => _saving = true);

    await AppLimitService.instance.saveLimit(
      AppLimit(
        packageName: widget.limit.packageName,
        appName: widget.limit.appName,
        iconBase64: widget.limit.iconBase64,
        limitMinutes: _selectedMinutes,
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _deleteLimit() async {
    final deleted = widget.limit;

    await AppLimitService.instance
        .deleteLimit(widget.limit.packageName);

    if (!mounted) return;
    Navigator.pop(context, deleted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final int used = widget.usage.totalMinutes;

    // ✅ FIXED: force double type
    final double ratio = _selectedMinutes == 0
        ? 0.0
        : (used / _selectedMinutes).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('App Limit'),
        shape: theme.appBarTheme.shape,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: cs.error),
            onPressed: _saving ? null : _deleteLimit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ---------- APP INFO ----------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _surface(context),
              child: Column(
                children: [
                  widget.limit.iconBase64.isEmpty
                      ? Icon(
                          Icons.apps,
                          size: 42,
                          color: theme.iconTheme.color,
                        )
                      : Image.memory(
                          base64Decode(widget.limit.iconBase64),
                          width: 42,
                          height: 42,
                        ),
                  const SizedBox(height: 12),
                  Text(
                    widget.limit.appName,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$used min used today',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------- PROGRESS ----------
            LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: cs.primary.withOpacity(0.2),
              color: ratio >= 1
                  ? cs.error
                  : ratio >= 0.8
                      ? cs.secondary
                      : cs.primary,
            ),

            const SizedBox(height: 24),

            // ---------- LIMIT ----------
            Text(
              'Daily limit: $_selectedMinutes min',
              style: theme.textTheme.bodyMedium,
            ),

            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: cs.primary,
                inactiveTrackColor: cs.primary.withOpacity(0.3),
                thumbColor: cs.primary,
                overlayColor: cs.primary.withOpacity(0.15),
              ),
              child: Slider(
                value: _selectedMinutes.toDouble(),
                min: 5,
                max: 180,
                divisions: 35,
                onChanged: _saving
                    ? null
                    : (v) =>
                        setState(() => _selectedMinutes = v.round()),
              ),
            ),

            const Spacer(),

            // ---------- SAVE ----------
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                ),
                onPressed: _saving ? null : _saveLimit,
                child: _saving
                    ? CircularProgressIndicator(
                        color: cs.onPrimary,
                      )
                    : Text(
                        'Save Changes',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- SHARED SURFACE ----------
  BoxDecoration _surface(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: cs.primary.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}