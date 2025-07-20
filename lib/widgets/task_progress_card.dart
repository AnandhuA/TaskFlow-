import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:task_flow/core/helper_funtions.dart';
import 'package:task_flow/models/task_model.dart';

class TaskProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final SubTask? selectedSubTask;
  final Duration? workElapsed;
  final Duration? breakElapsed;
  final bool isRunning;
  final VoidCallback? onToggleTimer;
  final VoidCallback? onCompleted;
  final bool isOnBreak;

  const TaskProgressCard({
    super.key,
    required this.completed,
    required this.total,
    this.selectedSubTask,
    this.workElapsed,
    this.breakElapsed,
    this.isRunning = false,
    this.onToggleTimer,
    this.isOnBreak = false,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : completed / total;
    final maxHeight = 30.0;
    final progress = total == 0 ? 0 : completed / total;

    final barHeights = List.generate(15, (index) {
      final base = [10, 14, 22, 18, 26, 20, 14, 12, 18, 22, 16, 10, 13, 14, 16];
      return (base[index] * progress).clamp(4.0, maxHeight);
    });

    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          selectedSubTask != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Working on: ${selectedSubTask!.title}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTimerBox(
                          label: "Work",
                          time: formatDuration(workElapsed ?? Duration.zero),
                          isActive: isRunning,
                          icon: Icons.work,
                        ),
                        _buildTimerBox(
                          label: "Break",
                          time: formatDuration(breakElapsed ?? Duration.zero),
                          isActive: isOnBreak,
                          icon: Icons.coffee,
                        ),
                        IconButton(
                          onPressed: onToggleTimer,
                          icon: Icon(
                            isRunning ? Icons.pause_circle : Icons.play_circle,
                            color: Colors.pinkAccent,
                            size: 40,
                          ),
                        ),
                        IconButton(
                          onPressed: onCompleted,
                          icon: Icon(
                            Icons.check_circle,
                            size: 40,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 24.0,
                      lineWidth: 6.0,
                      percent: percent.clamp(0.0, 1.0),
                      center: Text(
                        "${(percent * 100).round()}%",
                        style: const TextStyle(color: Colors.white),
                      ),
                      progressColor: Colors.pinkAccent,
                      backgroundColor: Colors.grey[800]!,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Completed",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$completed/$total tasks",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 12),
          if (selectedSubTask == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(15, (index) {
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  tween: Tween<double>(
                    begin: 0,
                    end: barHeights[index].toDouble(),
                  ),
                  builder: (context, value, child) {
                    return Container(
                      width: 10,
                      height: value,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.shade400,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  },
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildTimerBox({
    required String label,
    required String time,
    required bool isActive,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isActive ? Colors.pinkAccent.withOpacity(0.2) : Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.pinkAccent : Colors.grey[700]!,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: isActive ? Colors.pinkAccent : Colors.grey[400]),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 13)),
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
