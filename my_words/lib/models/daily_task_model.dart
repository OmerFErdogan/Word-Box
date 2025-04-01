import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DailyTask {
  String title;
  int currentProgress;
  int targetProgress;
  bool isCompleted;

  DailyTask({
    required this.title,
    required this.targetProgress,
    this.currentProgress = 0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'currentProgress': currentProgress,
        'targetProgress': targetProgress,
        'isCompleted': isCompleted,
      };

  factory DailyTask.fromJson(Map<String, dynamic> json) => DailyTask(
        title: json['title'],
        currentProgress: json['currentProgress'],
        targetProgress: json['targetProgress'],
        isCompleted: json['isCompleted'],
      );
}

class DailyTaskModel extends ChangeNotifier {
  List<DailyTask> _tasks = [];
  int _streak = 0;
  DateTime? _lastCompletionDate;

  List<DailyTask> get tasks => _tasks;
  int get streak => _streak;

  DailyTaskModel() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString('dailyTasks');
    if (tasksJson != null) {
      List<dynamic> decodedTasks = json.decode(tasksJson);
      _tasks = decodedTasks.map((task) => DailyTask.fromJson(task)).toList();
    }
    _streak = prefs.getInt('streak') ?? 0;
    String? lastCompletionString = prefs.getString('lastCompletionDate');
    if (lastCompletionString != null) {
      _lastCompletionDate = DateTime.parse(lastCompletionString);
    }
    await _checkAndResetTasks();
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> encodedTasks =
        _tasks.map((task) => task.toJson()).toList();
    await prefs.setString('dailyTasks', json.encode(encodedTasks));
    await prefs.setInt('streak', _streak);
    if (_lastCompletionDate != null) {
      await prefs.setString(
          'lastCompletionDate', _lastCompletionDate!.toIso8601String());
    }
  }

  Future<void> _checkAndResetTasks() async {
    DateTime now = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastResetDateString = prefs.getString('lastResetDate');

    if (lastResetDateString == null) {
      await prefs.setString('lastResetDate', now.toIso8601String());
      _generateNewTasks();
      return;
    }

    DateTime lastResetDate = DateTime.parse(lastResetDateString);
    if (now.day != lastResetDate.day ||
        now.month != lastResetDate.month ||
        now.year != lastResetDate.year) {
      _updateStreak();
      _generateNewTasks();
      await prefs.setString('lastResetDate', now.toIso8601String());
      await _saveTasks();
    }
  }

  void _generateNewTasks() {
    Random random = Random();
    _tasks = [
      DailyTask(
          title: 'Learn new words', targetProgress: random.nextInt(3) + 3),
      DailyTask(title: 'Review words', targetProgress: random.nextInt(5) + 5),
      DailyTask(
          title: 'Complete quizzes', targetProgress: random.nextInt(2) + 1),
    ];
  }

  void _updateStreak() {
    if (_lastCompletionDate != null) {
      DateTime now = DateTime.now();
      if (now.difference(_lastCompletionDate!).inDays == 1) {
        _streak++;
      } else if (now.difference(_lastCompletionDate!).inDays > 1) {
        _streak = 0;
      }
    }
  }

  Future<void> updateTaskProgress(String taskTitle, int progress) async {
    int index = _tasks.indexWhere((task) => task.title == taskTitle);
    if (index != -1) {
      DailyTask task = _tasks[index];
      if (!task.isCompleted) {
        task.currentProgress =
            min(task.currentProgress + progress, task.targetProgress);
        if (task.currentProgress >= task.targetProgress) {
          task.isCompleted = true;
        }
        if (_allTasksCompleted()) {
          _lastCompletionDate = DateTime.now();
        }
        await _saveTasks();
        notifyListeners();
      }
    }
  }

  bool _allTasksCompleted() {
    return _tasks.every((task) => task.isCompleted);
  }

  bool isTaskCompleted(String taskTitle) {
    int index = _tasks.indexWhere((task) => task.title == taskTitle);
    return index != -1 ? _tasks[index].isCompleted : false;
  }

  double get overallProgress {
    if (_tasks.isEmpty) return 0.0;
    int totalCompleted =
        _tasks.fold(0, (sum, task) => sum + task.currentProgress);
    int totalTarget = _tasks.fold(0, (sum, task) => sum + task.targetProgress);
    return totalTarget > 0 ? totalCompleted / totalTarget : 0.0;
  }

  int get completedTaskCount => _tasks.where((task) => task.isCompleted).length;

  Future<void> resetTasks() async {
    _generateNewTasks();
    await _saveTasks();
    notifyListeners();
  }
}
