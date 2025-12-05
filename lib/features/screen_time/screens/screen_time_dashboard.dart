import 'package:flutter/material.dart';

class ScreenTimeDashboard extends StatelessWidget {
  const ScreenTimeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final apps = _mockApps;
    final totalMinutes = apps.fold<int>(
      0,
      (sum, app) => sum + app.usageMinutes,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F1A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1A20),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: const Text(
          'Screen Time Control',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top summary card
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF151F28),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's screen time",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatMinutes(totalMinutes),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Apps list
              Expanded(
                child: ListView.separated(
                  itemCount: apps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    return _AppUsageTile(app: app);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Add App Limit button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(0, 6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: navigate to Add App Limit screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ONE app row (icon + name + usage + progress bar)
class _AppUsageTile extends StatelessWidget {
  final _AppUsage app;

  const _AppUsageTile({required this.app});

  @override
  Widget build(BuildContext context) {
    final ratio =
        app.limitMinutes > 0 ? app.usageMinutes / app.limitMinutes : 0.0;
    final clampedRatio = ratio.clamp(0.0, 1.0);

    final Color barColor;
    if (ratio >= 1.0) {
      barColor = const Color(0xFFEF4444); // red
    } else if (ratio >= 0.8) {
      barColor = const Color(0xFFF97316); // orange
    } else {
      barColor = const Color(0xFF22C55E); // green
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + labels + usage text
          Row(
            children: [
              _AppIcon(color: app.iconColor, icon: app.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Limit: ${app.limitMinutes} min/day',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${app.usageMinutes} min today',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2933),
                borderRadius: BorderRadius.circular(999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: clampedRatio,
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Leading rounded app icon (to simulate the design)
class _AppIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _AppIcon({
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

/// Simple local model for the dashboard UI (for now)
class _AppUsage {
  final String name;
  final int usageMinutes;
  final int limitMinutes;
  final Color iconColor;
  final IconData icon;

  _AppUsage({
    required this.name,
    required this.usageMinutes,
    required this.limitMinutes,
    required this.iconColor,
    required this.icon,
  });
}

/// Mock data to visually match your design screenshot
final List<_AppUsage> _mockApps = [
  _AppUsage(
    name: 'Instagram',
    usageMinutes: 45,
    limitMinutes: 50,
    iconColor: const Color(0xFFFF5A5F),
    icon: Icons.camera_alt_rounded,
  ),
  _AppUsage(
    name: 'YouTube',
    usageMinutes: 75,
    limitMinutes: 60,
    iconColor: const Color(0xFFEF4444),
    icon: Icons.play_arrow_rounded,
  ),
  _AppUsage(
    name: 'TikTok',
    usageMinutes: 32,
    limitMinutes: 60,
    iconColor: const Color(0xFF0F766E),
    icon: Icons.music_note_rounded,
  ),
  _AppUsage(
    name: 'X',
    usageMinutes: 28,
    limitMinutes: 20,
    iconColor: const Color(0xFF4B5563),
    icon: Icons.chat_bubble_outline_rounded,
  ),
];

String _formatMinutes(int totalMinutes) {
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  final hPart = hours > 0 ? '${hours}h ' : '';
  final mPart = '${minutes}m';
  return '$hPart$mPart';
}