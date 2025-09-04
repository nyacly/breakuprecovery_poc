import 'package:flutter/material.dart';
import 'package:breakup_recovery/screens/plan_overview_screen.dart';
import 'package:breakup_recovery/screens/journal_home_screen.dart';
import 'package:breakup_recovery/screens/library_screen.dart';
import 'package:breakup_recovery/screens/coach_chat_screen.dart';
import 'package:breakup_recovery/widgets/br_components.dart';
import 'package:breakup_recovery/theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PlanOverviewScreen(),
    const JournalHomeScreen(),
    const LibraryScreen(),
    const CoachChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BRColors.background,
      body: Column(
        children: [
          Expanded(child: _screens[_currentIndex]),
          // Add subtle shadow above navigation
          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: BRTabBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}