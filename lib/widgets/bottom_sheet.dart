import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:task_flow/models/task_model.dart';

class AddSubTaskSheet extends StatefulWidget {
  final Function(SubTask) onSubtaskAdded;

  const AddSubTaskSheet({super.key, required this.onSubtaskAdded});

  @override
  State<AddSubTaskSheet> createState() => _AddSubTaskSheetState();
}

class _AddSubTaskSheetState extends State<AddSubTaskSheet> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController stepController = TextEditingController();

  String priority = 'Medium';
  List<String> steps = [];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add New Subtask',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,

                    decoration: InputDecoration(
                      hintText: 'Subtask Title',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  // DropdownButtonFormField<String>(
                  //   value: priority,
                  //   items: ['High', 'Medium', 'Low']
                  //       .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  //       .toList(),
                  //   onChanged: (val) {
                  //     if (val != null) setState(() => priority = val);
                  //   },
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: stepController,
                          decoration: InputDecoration(
                            hintText: 'Add a Step',
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.grey[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          if (stepController.text.trim().isNotEmpty) {
                            setState(() {
                              steps.add(stepController.text.trim());
                              stepController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (steps.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: steps.length,
                      itemBuilder: (context, index) {
                        final step = steps[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Text(
                                '- ',
                                style: TextStyle(color: Colors.white60),
                              ),
                              Expanded(
                                child: Text(
                                  step,
                                  style: const TextStyle(color: Colors.white60),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    steps.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;

                      final newSub = SubTask(
                        title: titleController.text.trim(),
                        priority: priority,
                        steps: steps,
                        completed: false,
                      );

                      widget.onSubtaskAdded(newSub);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      'Add Subtask',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
