import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final int streak;
  final bool isCompletedToday;
  final Color color;
  final IconData icon;
  final VoidCallback onToggle;
  final VoidCallback? onNameTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.streak,
    required this.isCompletedToday,
    required this.color,
    required this.icon,
    required this.onToggle,
    this.onNameTap, 
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  late bool isCompleted;

  @override
  void initState() {
    super.initState();
    isCompleted = widget.isCompletedToday;
  }

  void _toggleCompletion() {
    setState(() {
      isCompleted = !isCompleted;
    });
    widget.onToggle();
  }

  void _openHabitDetails() {
    if (widget.onNameTap != null) {
      widget.onNameTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary.withOpacity(0.08), colorScheme.secondary.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 56,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Icon(widget.icon, color: colorScheme.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _openHabitDetails,
                  child: Text(
                    widget.habit.name,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.local_fire_department, size: 14, color: colorScheme.secondary),
                    const SizedBox(width: 6),
                    Text('${widget.streak}-day streak', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleCompletion,
              customBorder: const CircleBorder(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? colorScheme.primary : theme.cardColor,
                  border: Border.all(color: colorScheme.secondary.withOpacity(0.18)),
                  boxShadow: [
                    if (isCompleted)
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, color: colorScheme.onPrimary, size: 20)
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
