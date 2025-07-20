import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/bloc/taskBloc/task_bloc.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/widgets/add_sub_task_bottom_sheet.dart';
import 'package:task_flow/widgets/task_progress_card.dart';

class ViewTaskScreen extends StatefulWidget {
  final TaskPlan task;

  const ViewTaskScreen({super.key, required this.task});

  @override
  State<ViewTaskScreen> createState() => _ViewTaskScreenState();
}

class _ViewTaskScreenState extends State<ViewTaskScreen> {
  late List<SubTask> subtasks;
  late List<bool> _expandedStates;
  late int pendingCount;
  late int completedCount;
  late int total;
  SubTask? _activeSubTask;
  final Stopwatch _taskStopwatch = Stopwatch();
  final Stopwatch _breakStopwatch = Stopwatch();
  late final Ticker _ticker;
  Duration _taskElapsed = Duration.zero;
  Duration _breakElapsed = Duration.zero;
  bool _isRunning = false;
  bool _isOnBreak = false;

  @override
  void initState() {
    super.initState();
    subtasks = widget.task.subtasks
        .map(
          (e) => SubTask(
            title: e.title,
            priority: e.priority,
            steps: e.steps,
            completed: e.completed,
            breakTaken: e.breakTaken,
          ),
        )
        .toList();
    _sortSubtasks();
    _expandedStates = List.generate(subtasks.length, (_) => false);
    _findCount();
    _ticker = Ticker((_) {
      if (_taskStopwatch.isRunning) {
        setState(() => _taskElapsed = _taskStopwatch.elapsed);
      }
      if (_breakStopwatch.isRunning) {
        setState(() => _breakElapsed = _breakStopwatch.elapsed);
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _findCount() {
    completedCount = subtasks.where((t) => t.completed).length;
    pendingCount = subtasks.where((t) => !t.completed).length;
    total = subtasks.length;
  }

  void _sortSubtasks() {
    subtasks.sort((a, b) {
      if (a.completed == b.completed) return 0;
      return a.completed ? 1 : -1;
    });
  }

  Future<void> _updateTaskInHive() async {
    final updatedTask = TaskPlan(
      id: widget.task.id,
      title: widget.task.title,
      subtasks: subtasks,
      createdAt: widget.task.createdAt,
    );
    context.read<TaskBloc>().add(
      UpdateTaskEvent(updatedTask: updatedTask, taskId: widget.task.id),
    );
  }

  void _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = subtasks.removeAt(oldIndex);
      subtasks.insert(newIndex, item);
    });
    await _updateTaskInHive();
  }

  void _resetAll() {
    _taskStopwatch
      ..stop()
      ..reset();
    _breakStopwatch
      ..stop()
      ..reset();
    _taskElapsed = Duration.zero;
    _breakElapsed = Duration.zero;
  }

  void _toggleTimer() {
    if (_activeSubTask != null && !_activeSubTask!.completed) {
      setState(() {
        if (_isRunning) {
          // Pausing work, starting break (do NOT reset)
          _taskStopwatch.stop();
          if (!_breakStopwatch.isRunning) _breakStopwatch.start();
          _isRunning = false;
          _isOnBreak = true;
        } else {
          // Resuming work, pausing break (do NOT reset)
          _breakStopwatch.stop();
          _taskStopwatch.start();
          _isRunning = true;
          _isOnBreak = false;
        }
      });
    }
  }

  void _selectSubtask(SubTask sub) {
    if (!sub.completed) {
      setState(() {
        if (_activeSubTask?.title != sub.title) {
          _resetAll(); // resets both timers
          _activeSubTask = sub;
          _taskStopwatch.start();
          _isRunning = true;
          _isOnBreak = false;
        } else {
          _toggleTimer();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.task.title),
        actions: [
          TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddSubTaskSheet(
                  onSubtaskSaved: (subtask) {
                    setState(() {
                      subtasks.insert(0, subtask);
                      _expandedStates.insert(0, false);
                      _findCount();
                    });
                    _updateTaskInHive();
                  },
                ),
              );
            },
            style: TextButton.styleFrom(
              minimumSize: Size(70, 40),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            icon: Icon(Icons.add, color: Colors.black),
            label: Text("New Task", style: TextStyle(color: Colors.black)),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TaskProgressCard(
              completed: completedCount,
              total: total,
              selectedSubTask: _activeSubTask,
              workElapsed:  _taskElapsed,
              breakElapsed: _breakElapsed,
              isRunning: _isRunning,
              isOnBreak: _isOnBreak,
              onToggleTimer: _toggleTimer,
              onCompleted: () async {
                if (_activeSubTask != null && !_activeSubTask!.completed) {
                  setState(() {
                    _activeSubTask!.completed = true;
                    _findCount();

                    // Stop both timers
                    _taskStopwatch.stop();
                    _breakStopwatch.stop();
                    _isRunning = false;
                    _isOnBreak = false;

                    // Optionally reset durations
                    // _taskElapsed = Duration.zero;
                    // _breakElapsed = Duration.zero;
                  });

                  await _updateTaskInHive();

                  await _updateTaskInHive();
                } else {
                  log("message");
                }
              },
            ),

            SizedBox(height: 15),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: subtasks.length,
                onReorder: _onReorder,
                buildDefaultDragHandles: true,
                itemBuilder: (context, index) {
                  final sub = subtasks[index];
                  return card(sub: sub, index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget card({required SubTask sub, required int index}) {
    return SizedBox(
      key: ValueKey(sub.title + index.toString()),
      child: Card(
        color: _activeSubTask == sub
            ? Colors.pinkAccent.withOpacity(0.2)
            : Colors.grey[900],
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: InkWell(
          onTap: () => _selectSubtask(sub),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Row(
                  children: [
                    Checkbox(
                      value: sub.completed,
                      onChanged: (val) async {
                        setState(() {
                          sub.completed = val ?? false;
                          _findCount();
                        });
                        await _updateTaskInHive();
                      },
                      activeColor: Colors.green,
                    ),
                    Expanded(
                      child: Text(
                        sub.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decorationThickness: 2,
                          decoration: sub.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (sub.steps.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          _expandedStates[index]
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _expandedStates[index] = !_expandedStates[index];
                          });
                        },
                      ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: Colors.grey[900],
                      onSelected: (value) {
                        if (value == 'edit') {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => AddSubTaskSheet(
                              existingSubTask: subtasks[index],
                              onSubtaskSaved: (updatedSubtask) {
                                setState(() {
                                  subtasks[index] = updatedSubtask;
                                });
                                _updateTaskInHive();
                              },
                            ),
                          );
                        } else if (value == 'delete') {
                          _confirmDeleteSubtask(context, index);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text("Edit")),
                        PopupMenuItem(value: 'delete', child: Text("Delete")),
                      ],
                    ),
                  ],
                ),
              ),
              if (_expandedStates[index])
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sub.steps
                        .map(
                          (step) => Padding(
                            padding: const EdgeInsets.only(left: 24, top: 4),
                            child: Text(
                              '- $step',
                              style: TextStyle(
                                color: Colors.white70,
                                decorationThickness: 1,
                                decoration: sub.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteSubtask(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Delete Subtask",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to delete this subtask?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              setState(() {
                subtasks.removeAt(index);
                _expandedStates.removeAt(index);
                _findCount();
              });
              await _updateTaskInHive();
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
