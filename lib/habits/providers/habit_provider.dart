import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../services/db_helper.dart';
import '../repository/habit_repository.dart';
import '../models/habit_view.dart';

// DB + repository providers
final dbProvider = Provider<DBHelper>((ref) => DBHelper());

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.read(dbProvider);
  return HabitRepository(db);
});

// Completion provider: returns a HabitCompletion for a given habitId and date string (yyyy-MM-dd)
final habitCompletionProvider = FutureProvider.family<HabitCompletion?, Map<String, dynamic>>((ref, params) async {
  final repo = ref.read(habitRepositoryProvider);
  final habitId = params['habitId'] as int;
  final dateStr = params['date'] as String;
  final date = DateTime.parse(dateStr);
  return repo.getCompletion(habitId, date);
});

// HabitView provider: aggregated data for UI cards
final habitViewProvider = FutureProvider.family<HabitView?, int>((ref, habitId) async {
  final repo = ref.read(habitRepositoryProvider);
  final habit = await repo.getHabit(habitId);
  if (habit == null) return null;

  final completion = await repo.getCompletion(habitId, DateTime.now());
  final isDoneToday = completion?.completed ?? false;
  final current = await repo.currentStreak(habitId);
  final longest = await repo.longestStreak(habitId);

  return HabitView(habit: habit, isDoneToday: isDoneToday, currentStreak: current, longestStreak: longest);
});

// HabitViewList: aggregated list for home screen (compute in parallel)
final habitViewListProvider = FutureProvider<List<HabitView>>((ref) async {
  final repo = ref.read(habitRepositoryProvider);
  final habits = await repo.getAllHabits();
  final futures = habits.map((h) async {
    final completion = await repo.getCompletion(h.id!, DateTime.now());
    final isDoneToday = completion?.completed ?? false;
    final current = await repo.currentStreak(h.id!);
    final longest = await repo.longestStreak(h.id!);
    return HabitView(habit: h, isDoneToday: isDoneToday, currentStreak: current, longestStreak: longest);
  });
  return await Future.wait(futures);
});

class HabitState {
  final bool isLoading;
  final List<Habit> habits;
  final Map<int, int> streaks;
  final Map<int, bool> completedToday;

  HabitState({
    this.isLoading = false,
    this.habits = const [],
    Map<int, int>? streaks,
    Map<int, bool>? completedToday,
  })  : streaks = streaks ?? const {},
        completedToday = completedToday ?? const {};

  HabitState copyWith({
    bool? isLoading,
    List<Habit>? habits,
    Map<int, int>? streaks,
    Map<int, bool>? completedToday,
  }) {
    return HabitState(
      isLoading: isLoading ?? this.isLoading,
      habits: habits ?? this.habits,
      streaks: streaks ?? this.streaks,
      completedToday: completedToday ?? this.completedToday,
    );
  }
}

class HabitNotifier extends StateNotifier<HabitState> {
  final HabitRepository repo;
  HabitNotifier(this.repo) : super(HabitState()) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    state = state.copyWith(isLoading: true);
    final habits = await repo.getAllHabits();

    final Map<int, int> streaks = {};
    final Map<int, bool> completed = {};

    for (var h in habits) {
      if (h.id == null) continue;
      final s = await repo.currentStreak(h.id!);
      streaks[h.id!] = s;
      final c = await repo.getCompletion(h.id!, DateTime.now());
      completed[h.id!] = c?.completed ?? false;
    }

    state = state.copyWith(isLoading: false, habits: habits, streaks: streaks, completedToday: completed);
  }

  Future<void> toggleHabit(Habit habit) async {
    // Optimistic update: flip the completed flag in local state immediately
    // so the UI updates without showing a full reload. Persist in background
    // and refresh only the affected habit's streak when done.
    if (habit.id == null) return;
    final id = habit.id!;
    final now = DateTime.now();

    final current = state.completedToday[id] ?? false;
    final newVal = !current;

    // Update local state optimistically
    final updatedCompleted = Map<int, bool>.from(state.completedToday);
    updatedCompleted[id] = newVal;
    state = state.copyWith(completedToday: updatedCompleted);

    try {
      await repo.toggleCompletion(id, now, completed: newVal);
      // Recompute streak for this habit and update state.streaks for just this id
      final s = await repo.currentStreak(id);
      final updatedStreaks = Map<int, int>.from(state.streaks);
      updatedStreaks[id] = s;
      state = state.copyWith(streaks: updatedStreaks);
    } catch (e) {
      // Revert optimistic update on error
      final reverted = Map<int, bool>.from(state.completedToday);
      reverted[id] = current;
      state = state.copyWith(completedToday: reverted);
      rethrow;
    }
  }

  Future<void> addHabit(Habit habit) async {
    await repo.createHabit(habit);
    await loadHabits();
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, HabitState>((ref) {
  final repo = ref.read(habitRepositoryProvider);
  return HabitNotifier(repo);
});
