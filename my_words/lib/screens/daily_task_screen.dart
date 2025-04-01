import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import '../models/daily_task_model.dart';
import '../models/theme_model.dart';

class DailyTaskScreen extends StatefulWidget {
  @override
  _DailyTaskScreenState createState() => _DailyTaskScreenState();
}

class _DailyTaskScreenState extends State<DailyTaskScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final taskModel = Provider.of<DailyTaskModel>(context);
    final theme = themeModel.currentTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Daily Quests',
            style: TextStyle(color: theme.appBarTheme.titleTextStyle?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildOverallProgress(taskModel, theme),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return _buildTaskItem(taskModel.tasks[index], theme, context);
              },
              childCount: taskModel.tasks.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(DailyTaskModel taskModel, ThemeData theme) {
    final completedCount = taskModel.completedTaskCount;
    final totalCount = taskModel.tasks.length;
    final progress = completedCount / totalCount;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Quest Progress',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.secondary),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.headlineMedium?.color,
                    ),
                  ),
                  Text(
                    '$completedCount/$totalCount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Streak: ${taskModel.streak} days',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(DailyTask task, ThemeData theme, BuildContext context) {
    final progress = task.currentProgress / task.targetProgress;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: InkWell(
        onTap: () => _showTaskDetails(context, task, theme),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.textTheme.titleLarge?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (task.isCompleted) _buildCompletionIndicator(theme),
                ],
              ),
              const SizedBox(height: 12),
              FAProgressBar(
                currentValue: (progress * 100).toDouble(),
                displayText: '%',
                progressColor: task.isCompleted
                    ? Colors.green
                    : theme.colorScheme.secondary,
                backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                animatedDuration: const Duration(milliseconds: 300),
                direction: Axis.horizontal,
                verticalDirection: VerticalDirection.up,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              Text(
                '${task.currentProgress}/${task.targetProgress} completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionIndicator(ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  void _showTaskDetails(BuildContext context, DailyTask task, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.dialogBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.headlineSmall?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Progress: ${task.currentProgress}/${task.targetProgress}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Status: ${task.isCompleted ? "Completed" : "In Progress"}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: task.isCompleted
                          ? Colors.green
                          : theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Keep up the great work! Complete this quest to earn XP and level up.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (!task.isCompleted) {
                        Provider.of<DailyTaskModel>(context, listen: false)
                            .updateTaskProgress(task.title, 1);
                        setModalState(() {}); // ModalBottomSheet'i güncelle
                        setState(() {}); // Ana ekranı güncelle
                        if (task.isCompleted) {
                          Future.delayed(Duration(seconds: 2), () {
                            Navigator.pop(context);
                          });
                        }
                      }
                    },
                    child:
                        Text(task.isCompleted ? 'Completed!' : 'Complete Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: task.isCompleted
                          ? Colors.green
                          : theme.colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
}
