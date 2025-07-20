import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:task_flow/bloc/chatGpt/chat_gpt_cubit.dart';
import 'package:task_flow/screens/result_screen.dart';

class AddTaskGptScreen extends StatefulWidget {
  final VoidCallback onReturnToMyTasks;
  const AddTaskGptScreen({super.key, required this.onReturnToMyTasks});

  @override
  State<AddTaskGptScreen> createState() => _AddTaskGptScreenState();
}

class _AddTaskGptScreenState extends State<AddTaskGptScreen> {
  final TextEditingController _taskController = TextEditingController();
  String _version = "";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  @override
  void dispose() {
    super.dispose();
    _taskController.dispose();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = "v${info.version}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("AddTask-Gpt"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            TextField(
              controller: _taskController,
              minLines: 1,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: 'Enter a task',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),

                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 15),
            BlocConsumer<ChatGptCubit, ChatGptState>(
              listener: (context, state) {
                //---------- chat loaded state ----------------
                if (state is ChatGptLoadedState) {
                  if (state.resultModel.taskList != null &&
                      state.resultModel.taskList!.isNotEmpty) {
                    _taskController.clear();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(
                          parsedTask: state.resultModel.taskList!.first,
                          onSaveAndReturn: widget.onReturnToMyTasks,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(milliseconds: 500),
                        content: Text(
                          "Failed to parse task response.",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
                // ------------ chat error state -------------
                else if (state is ChatGptErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(milliseconds: 500),
                      content: Text(
                        state.resultModel.message,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ChatGptLoadingState) {
                  return TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      minimumSize: Size(70, 40),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(5),
                      ),
                    ),
                    child: Lottie.asset(
                      "assets/animations/loading.json",
                      height: 30,
                      width: 20,
                    ),
                  );
                }
                return TextButton(
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      context.read<ChatGptCubit>().chatButtonClick(
                        task: _taskController.text,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(milliseconds: 500),
                          content: Text(
                            "Type Task.....",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size(70, 40),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(5),
                    ),
                  ),
                  child: Text("Go", style: TextStyle(color: Colors.black)),
                );
              },
            ),
            const SizedBox(height: 16),
            Spacer(),
            Text(
              _version,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
