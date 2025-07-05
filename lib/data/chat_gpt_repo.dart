import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_flow/core/key.dart';
import 'package:task_flow/core/urls.dart';

class ChatGptRepo {
  Future<String> generateSubTasks(String task) async {
    try {
      final response = await http.post(
        Uri.parse(Urls.url),
        headers: {
          'Authorization': 'Bearer $apiKey2', 
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://taskflow.app',
          'X-Title': 'TaskFlow',
        },
        body: jsonEncode({
          "model": "mistralai/mistral-7b-instruct", 
          "messages": [
            {
              "role": "system",
              "content":
                  "You are an assistant that splits tasks into subtasks with priority."
            },
            {
              "role": "user",
              "content": "Split and prioritize this task: $task"
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }
}
