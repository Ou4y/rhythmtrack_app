import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/installed_app.dart';
import '../services/installed_apps_service.dart';

class SetAppLimitScreen extends StatefulWidget {
  const SetAppLimitScreen({super.key});

  @override
  State<SetAppLimitScreen> createState() => _SetAppLimitScreenState();
}

class _SetAppLimitScreenState extends State<SetAppLimitScreen> {
  List<InstalledApp> _apps = [];
  List<InstalledApp> _filteredApps = [];
  bool _loading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await InstalledAppsService.getInstalledApps();

    setState(() {
      _apps = apps;
      _filteredApps = apps;
      _loading = false;
    });
  }

  void _filterApps(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredApps = _apps.where((app) {
        return app.appName.toLowerCase().contains(_searchQuery) ||
            app.packageName.toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  void _openLimitPicker(InstalledApp app) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      context: context,
      builder: (_) {
        int selectedMinutes = 30;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Set Daily Limit for ${app.appName}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Time picker slider
                  Slider(
                    value: selectedMinutes.toDouble(),
                    min: 5,
                    max: 180,
                    divisions: 35,
                    label: "$selectedMinutes min",
                    activeColor: Colors.blue,
                    inactiveColor: Colors.white24,
                    onChanged: (value) {
                      setModalState(() {
                        selectedMinutes = value.round();
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  Text(
                    "$selectedMinutes minutes per day",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);

                        // Return selected app + limit to previous screen
                        Navigator.pop(context, {
                          "packageName": app.packageName,
                          "appName": app.appName,
                          "iconBase64": app.iconBase64,
                          "limitMinutes": selectedMinutes,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Save Limit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F1A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A20),
        elevation: 0,
        title: const Text(
          "Set App Limit",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: _filterApps,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search apps...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1A2530),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.separated(
                    itemCount: _filteredApps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final app = _filteredApps[index];

                      return ListTile(
                        onTap: () => _openLimitPicker(app),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: app.iconBase64.isNotEmpty
                              ? Image.memory(
                                  base64Decode(app.iconBase64),
                                  width: 30,
                                  height: 30,
                                )
                              : const Icon(Icons.apps,
                                  color: Colors.white, size: 26),
                        ),
                        title: Text(
                          app.appName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          app.packageName,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}