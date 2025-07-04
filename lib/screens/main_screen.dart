import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:task_flow/screens/add_task.dart';
import 'package:task_flow/screens/add_task_gpt_screen.dart';
import 'package:task_flow/screens/my_task_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onTabChanged(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [MyTaskScreen(), AddTask(), AddTaskGptScreen()],
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
        child: GNav(
          backgroundColor: Colors.black,
          color: Colors.grey[400],
          activeColor: Colors.white,
          tabBackgroundColor: Colors.grey[850]!,
          gap: 8,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          selectedIndex: _selectedIndex,
          onTabChange: _onTabChanged,
          tabs: const [
            GButton(icon: Icons.task_alt, text: 'My Tasks'),
            GButton(icon: Icons.add_circle_outline_sharp, text: 'Add Task'),
            GButton(icon: Icons.gpp_good_outlined, text: 'Gpt'),
          ],
        ),
      ),
    );
  }
}
