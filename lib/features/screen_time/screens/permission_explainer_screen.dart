import 'package:flutter/material.dart';
import '../services/usage_permission_channel.dart';

class PermissionExplainerScreen extends StatelessWidget {
  const PermissionExplainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ICON SURFACE
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer,
                  size: 64,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: 32),

              // TITLE
              Text(
                'Enable Usage Access',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // DESCRIPTION
              Text(
                'RhythmTrack needs Usage Access to track your screen time '
                'and help you build better daily habits.\n\n'
                'Your data stays private and is never shared.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 36),

              // PRIMARY ACTION
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    UsagePermissionChannel.openUsageSettings();
                  },
                  child: Text(
                    'Open Settings',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // SECONDARY ACTION
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Not now',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}