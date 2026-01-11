import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/installed_app.dart';
import '../services/installed_apps_service.dart';

class SetAppLimitScreen extends StatefulWidget {
  final String? preselectedPackageName;

  const SetAppLimitScreen({
    super.key,
    this.preselectedPackageName,
  });

  @override
  State<SetAppLimitScreen> createState() => _SetAppLimitScreenState();
}

class _SetAppLimitScreenState extends State<SetAppLimitScreen> {
  List<InstalledApp> _apps = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await InstalledAppsService.getInstalledApps();

    setState(() {
      _apps = apps;
      _loading = false;
    });
  }

  void _openLimitPicker(InstalledApp app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        int selectedMinutes = 30;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Set limit for ${app.appName}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: selectedMinutes.toDouble(),
                    min: 5,
                    max: 180,
                    divisions: 35,
                    label: "$selectedMinutes min",
                    onChanged: (v) =>
                        setModalState(() => selectedMinutes = v.round()),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, {
                          "packageName": app.packageName,
                          "appName": app.appName,
                          "iconBase64": app.iconBase64,
                          "limitMinutes": selectedMinutes,
                        });
                      },
                      child: const Text("Save Limit"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (_loading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final initialApp = widget.preselectedPackageName == null
        ? null
        : _apps.firstWhere(
            (a) => a.packageName == widget.preselectedPackageName,
            orElse: () => _apps.first,
          );

    if (initialApp != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openLimitPicker(initialApp);
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? colorScheme.primary,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.iconTheme,
        title: Text(
          "Set App Limit",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        shape: theme.appBarTheme.shape,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary.withOpacity(0.08), colorScheme.secondary.withOpacity(0.08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: _apps.length,
          itemBuilder: (_, index) {
            final app = _apps[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: theme.cardColor.withOpacity(0.85),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                onTap: () => _openLimitPicker(app),
                leading: app.iconBase64.isEmpty
                    ? Icon(Icons.apps, color: theme.iconTheme.color)
                    : Image.memory(
                        base64Decode(app.iconBase64),
                        width: 30,
                        height: 30,
                      ),
                title: Text(
                  app.appName,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}