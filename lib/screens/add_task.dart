import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/bloc/taskBloc/task_bloc.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:uuid/uuid.dart';

class AddTask extends StatefulWidget {
  final VoidCallback onAddTask;
  const AddTask({super.key, required this.onAddTask});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final TextEditingController taskTitleController = TextEditingController();

  final TextEditingController subTitleController = TextEditingController();
  final TextEditingController stepController = TextEditingController();

  List<SubTask> subtasks = [];
  List<String> steps = [];
  String priority = 'Medium';

  void _addStep() {
    final text = stepController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        steps.add(text);
        stepController.clear();
      });
    }
  }

  void _addSubtask() {
    final title = subTitleController.text.trim();
    if (title.isEmpty) return;

    final sub = SubTask(
      title: title,
      priority: priority,
      steps: List<String>.from(steps),
      completed: false,
    );

    setState(() {
      subtasks.add(sub);
      subTitleController.clear();
      steps.clear();
      priority = 'Medium';
    });
  }

  void _saveTask()  {
    final title = taskTitleController.text.trim();
    if (title.isEmpty || subtasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add a title and at least one subtask."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newTask = TaskPlan(
      id: const Uuid().v4(),
      title: title,
      subtasks: subtasks,
      createdAt: DateTime.now(),
    );

    context.read<TaskBloc>().add(AddNewTaskEvent(newTask: newTask));
    taskTitleController.clear();
    subTitleController.clear();
    stepController.clear();
    widget.onAddTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Add Task"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Task added successfully!"),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Task title
                TextField(
                  controller: taskTitleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter task title",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Subtask title input
                TextField(
                  controller: subTitleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Subtask title",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // // Priority dropdown
                // DropdownButtonFormField<String>(
                //   value: priority,
                //   items: [
                //     'High',
                //     'Medium',
                //     'Low',
                //   ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                //   onChanged: (val) => setState(() => priority = val ?? 'Medium'),
                //   decoration: InputDecoration(
                //     filled: true,
                //     fillColor: Colors.grey[800],
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     labelText: 'Priority',
                //     labelStyle: const TextStyle(color: Colors.white70),
                //   ),
                //   dropdownColor: Colors.grey[900],
                //   style: const TextStyle(color: Colors.white),
                // ),
                const SizedBox(height: 12),

                // Step input row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stepController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a Step',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addStep,
                      icon: Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),

                // Step list preview
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps
                      .map(
                        (step) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "- $step",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() => steps.remove(step));
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),

                // Add subtask button
                ElevatedButton.icon(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text(
                    "Add Subtask",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Subtask list
                const Text("Subtasks", style: TextStyle(color: Colors.black)),
                const SizedBox(height: 8),
                ...subtasks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final sub = entry.value;
                  return Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      title: Text(
                        '${sub.title} (${sub.priority})',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: sub.steps
                            .map(
                              (s) => Text(
                                "- $s",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            )
                            .toList(),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            subtasks.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
