import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:task_flow/core/key.dart';
import 'package:task_flow/core/urls.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();
  String _response = '';
  bool _isLoading = false;
  Future<void> _generateSubTasks() async {
    final String task = _taskController.text.trim();
    if (task.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final res = await http.post(
        Uri.parse(Urls.url),
        headers: {
          'Authorization': 'Bearer $apiKey2',
          'Content-Type': 'application/json',
          'HTTP-Referer':
              'https://taskflow.app',
          'X-Title': 'TaskFlow',
        },
        body: jsonEncode({
          "model": "mistralai/mistral-7b-instruct",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are an assistant that helps users break down tasks into subtasks with priority.",
            },
            {
              "role": "user",
              "content": "Split and prioritize this task: $task",
            },
          ],
          "temperature": 0.7,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final content = data['choices'][0]['message']['content'];
        log(content);
        setState(() => _response = content);
      } else {
        log(res.body);
        setState(() => _response = 'Error: ${res.body}');
      }
    } catch (e) {
      log(e.toString());
      setState(() => _response = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Enter a task',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateSubTasks,
              icon: const Icon(Icons.play_arrow),
              label: const Text("Go"),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _response,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
