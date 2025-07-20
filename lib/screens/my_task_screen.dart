import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:task_flow/bloc/taskBloc/task_bloc.dart';
import 'package:task_flow/core/helper_funtions.dart';
import 'package:task_flow/data/hive_repo.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/screens/view_task_screen.dart';

class MyTaskScreen extends StatelessWidget {
  final VoidCallback onAddTask;
  MyTaskScreen({super.key, required this.onAddTask});
  final hiveRepo = HiveRepo();
  bool _isAllCompleted(TaskPlan task) {
    return task.subtasks.isNotEmpty &&
        task.subtasks.every((subtask) => subtask.completed);
  }

  String _completedStatusText(TaskPlan task, double progress) {
    final total = task.subtasks.length;
    final completed = task.subtasks.where((s) => s.completed).length;

    return total == 0
        ? "No subtasks"
        : "$completed of $total subtasks completed    ${(progress * 100).toInt()}%";
  }

  double _calculateProgress(TaskPlan task) {
    final total = task.subtasks.length;
    if (total == 0) return 0;
    final completed = task.subtasks.where((s) => s.completed).length;
    return completed / total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("My Tasks"),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          //----- task loading ------
          if (state is TaskLoadingState) {
            return Center(child: CircularProgressIndicator());
          }
          // --------- task error ----------
          else if (state is TaskErrorState) {
            return Center(child: Text(state.error));
          }
          //-------- task success ---------
          else if (state is TaskSuccessState) {
            final List<TaskPlan>? tasks = state.resultModel.taskList;
            if (tasks != null) {
              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No Task Found",
                        style: TextStyle(color: Colors.white),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Lottie.asset(
                            "assets/animations/arrow_white.json",
                            height: 150,
                          ),
                          Positioned(
                            // adjust as needed
                            child: TextButton(
                              onPressed: onAddTask,
                              style: TextButton.styleFrom(
                                minimumSize: Size(100, 40),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                "Add Task",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final progress = _calculateProgress(task);
                    return Card(
                      color: Colors.grey[850],
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: _isAllCompleted(task)
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.radio_button_unchecked,
                                color: Colors.grey,
                              ),
                        title: Text(
                          task.title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _completedStatusText(task, progress),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 5),
                            LinearProgressIndicator(
                              value: progress,

                              minHeight: 3,
                              borderRadius: BorderRadius.circular(10),
                              backgroundColor: Colors.grey[700],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green.shade500,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Saved on: ${formatDate(task.createdAt ?? DateTime.now())}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditTitleDialog(context, task);
                            } else if (value == 'delete') {
                              _confirmDelete(context, task);
                            }
                          },
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          color: Colors.grey[900],
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text("Edit"),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text("Delete"),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 300),
                              pageBuilder: (_, _, _) =>
                                  ViewTaskScreen(task: task),
                              transitionsBuilder: (_, animation, _, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(-1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }
            } else {
              return Center(child: Text("Task null :$tasks"));
            }
          }
          return Center(child: Text("Unknown State:: $state"));
        },
      ),
    );
  }

  void _showEditTitleDialog(BuildContext context, TaskPlan task) {
    final controller = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Edit Title", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter new title",
            hintStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                final updatedTask = TaskPlan(
                  id: task.id,
                  title: newTitle,
                  subtasks: task.subtasks,
                  createdAt: task.createdAt,
                );
                context.read<TaskBloc>().add(
                  UpdateTaskEvent(updatedTask: updatedTask, taskId: task.id),
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TaskPlan task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Delete Task", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to delete this task?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTaskEvent(taskId: task.id));
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
