import 'package:flutter/material.dart';
import 'package:task_flow/data/hive_repo.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:uuid/uuid.dart';

class ResultScreen extends StatefulWidget {
  final VoidCallback onSaveAndReturn;

  final TaskPlan parsedTask;
  const ResultScreen({
    super.key,
    required this.parsedTask,
    required this.onSaveAndReturn,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late List<SubTaskWrapper> _wrappedTasks;

  @override
  void initState() {
    super.initState();
    _wrappedTasks = widget.parsedTask.subtasks.map((sub) {
      return SubTaskWrapper(
        subtask: SubTask(
          title: sub.title,
          priority: sub.priority,
          steps: sub.steps,
          completed: false,
        ),
      );
    }).toList();
  }

  void _saveSelectedTasks() async {
    final selected = _wrappedTasks
        .where((w) => w.selected)
        .map((w) => w.subtask)
        .toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one task to save."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final taskToSave = TaskPlan(
      id: const Uuid().v4(),
      title: widget.parsedTask.title,
      subtasks: selected,
      createdAt: DateTime.now(),
    );

    await HiveRepo().saveTask(taskToSave);
    widget.onSaveAndReturn();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Selected tasks saved to Hive!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Task"),
        actions: [
          TextButton(
            onPressed: _saveSelectedTasks,
            style: TextButton.styleFrom(
              minimumSize: Size(70, 40),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(5),
              ),
            ),
            child: Text("Save", style: TextStyle(color: Colors.black)),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: ListView.builder(
          itemCount: widget.parsedTask.subtasks.length,
          itemBuilder: (context, index) {
            final wrapper = _wrappedTasks[index];
            final sub = wrapper.subtask;
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      wrapper.selected = !wrapper.selected;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: wrapper.selected,
                            onChanged: (val) {
                              setState(() {
                                wrapper.selected = val ?? false;
                              });
                            },
                          ),

                          Expanded(
                            child: Text(
                              '${sub.title} (${sub.priority})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...sub.steps.map(
                        (step) => Padding(
                          padding: const EdgeInsets.only(left: 16.0, bottom: 4),
                          child: Text('- $step'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
