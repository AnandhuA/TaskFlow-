import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TaskProgressCard extends StatelessWidget {
  final int completed;
  final int total;

  const TaskProgressCard({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : completed / total;
    double progress = total == 0 ? 0 : completed / total;
    final maxHeight = 30.0; // max height for 100% progress
    final barHeights = List.generate(15, (index) {
      // Give each bar a base variation + scale by progress
      final base = [10, 14, 22, 18, 26, 20, 14, 12, 18, 22, 16, 10, 13, 14, 16];
      return (base[index] * progress).clamp(4.0, maxHeight);
    });

    return Container(
      height: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
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
                    "$completed/$total task",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(15, (index) {
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400),
                tween: Tween<double>(begin: 0, end: barHeights[index]),
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
}
