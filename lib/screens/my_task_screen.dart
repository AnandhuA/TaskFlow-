import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_flow/data/hive_repo.dart';
import 'package:task_flow/models/task_model.dart';

class MyTaskScreen extends StatelessWidget {
  const MyTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hiveRepo = HiveRepo();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("My Tasks"),
        actions: [],
      ),
      body: ValueListenableBuilder<Box<TaskPlan>>(
        valueListenable: Hive.box<TaskPlan>('taskPlans').listenable(),
        builder: (context, box, _) {
          final tasks = hiveRepo.getAllTasks().reversed.toList();

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                "No tasks found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              return Card(
                color: Colors.grey[850],
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    task.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Subtasks: ${task.subtasks.length}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "Saved on: ${task.createdAt}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
