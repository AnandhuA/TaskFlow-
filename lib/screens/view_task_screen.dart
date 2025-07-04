import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:task_flow/data/hive_repo.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/widgets/add_sub_task_bottom_sheet.dart';

class ViewTaskScreen extends StatefulWidget {
  final TaskPlan task;

  const ViewTaskScreen({super.key, required this.task});

  @override
  State<ViewTaskScreen> createState() => _ViewTaskScreenState();
}

class _ViewTaskScreenState extends State<ViewTaskScreen> {
  late List<SubTask> subtasks;
  late List<bool> _expandedStates;

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
          ),
        )
        .toList();
    _sortSubtasks();
    _expandedStates = List.generate(subtasks.length, (_) => false);
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
    await HiveRepo().updateTask(widget.task.id, updatedTask);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = subtasks.removeAt(oldIndex);
      subtasks.insert(newIndex, item);
    });
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
                borderRadius: BorderRadiusGeometry.circular(5),
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
    );
  }

  Widget card({required SubTask sub, required int index}) {
    return Card(
      key: ValueKey(sub.title + index.toString()),
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () async {
          setState(() {
            sub.completed = !sub.completed;
          });
          await _updateTaskInHive();
        },
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
