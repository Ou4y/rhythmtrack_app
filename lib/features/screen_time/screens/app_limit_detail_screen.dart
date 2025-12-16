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
  State<AppLimitDetailScreen> createState() =>
      _AppLimitDetailScreenState();
}

class _AppLimitDetailScreenState
    extends State<AppLimitDetailScreen> {
  late int _selectedMinutes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.limit.limitMinutes;
  }

  Future<void> _saveLimit() async {
    setState(() => _saving = true);

    final updated = AppLimit(
      packageName: widget.limit.packageName,
      appName: widget.limit.appName,
      iconBase64: widget.limit.iconBase64,
      limitMinutes: _selectedMinutes,
    );

    await AppLimitService.instance.saveLimit(updated);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _deleteLimit() async {
    final deletedLimit = widget.limit;

    await AppLimitService.instance
        .deleteLimit(widget.limit.packageName);

    if (!mounted) return;

    // Return deleted limit to dashboard
    Navigator.pop(context, deletedLimit);
  }

  @override
  Widget build(BuildContext context) {
    final used = widget.usage.totalMinutes;
    final ratio =
        (used / _selectedMinutes).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A20),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "App Limit",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 216, 49, 37)),
            onPressed: _saving ? null : _deleteLimit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(24),
              ),
              child: widget.limit.iconBase64.isEmpty
                  ? const Icon(Icons.apps,
                      color: Colors.white, size: 40)
                  : Image.memory(
                      base64Decode(widget.limit.iconBase64),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.limit.appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "$used min used today",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: Colors.white12,
                color: ratio >= 1
                    ? Colors.red
                    : ratio >= 0.8
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Daily limit: $_selectedMinutes min",
              style: const TextStyle(color: Colors.white),
            ),
            Slider(
              value: _selectedMinutes.toDouble(),
              min: 5,
              max: 180,
              divisions: 35,
              onChanged: _saving
                  ? null
                  : (v) =>
                      setState(() => _selectedMinutes = v.round()),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveLimit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _saving
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
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
}