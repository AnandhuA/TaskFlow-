import 'package:task_flow/models/task_model.dart';

TaskPlan parseAiResponse(String rawText) {
  final lines = rawText.trim().split('\n');
  String taskTitle = '';
  final List<SubTask> subtasks = [];

  String? currentTitle;
  String priority = 'Medium';
  List<String> currentSteps = [];

  for (var line in lines) {
    line = line.trim();

    if (line.startsWith('Task:')) {
      taskTitle = line.replaceFirst('Task:', '').trim();
    } else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
      if (currentTitle != null) {
        subtasks.add(SubTask(
          title: currentTitle,
          priority: priority,
          steps: currentSteps,
        ));
      }

      final priorityMatch = RegExp(r'\[(High|Medium|Low)\]').firstMatch(line);
      priority = priorityMatch?.group(1) ?? 'Medium';

      currentTitle = line
          .replaceAll(RegExp(r'\d+\.\s|\[(High|Medium|Low)\]'), '')
          .trim();
      currentSteps = [];
    } else if (line.startsWith('-')) {
      currentSteps.add(line.replaceFirst('-', '').trim());
    }
  }

  if (currentTitle != null) {
    subtasks.add(SubTask(
      title: currentTitle,
      priority: priority,
      steps: currentSteps,
    ));
  }

  return TaskPlan(title: taskTitle, subtasks: subtasks);
}
