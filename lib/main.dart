import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:task_flow/bloc/chatGpt/chat_gpt_cubit.dart';
import 'package:task_flow/bloc/taskBloc/task_bloc.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskPlanAdapter());
  Hive.registerAdapter(SubTaskAdapter());
  await Hive.openBox<TaskPlan>('taskPlans');
  await Hive.openBox<List>('taskOrder');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChatGptCubit()),
        BlocProvider(create: (context) => TaskBloc()..add(InitialEventEvent())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainScreen(),
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
      ),
    );
  }
}
