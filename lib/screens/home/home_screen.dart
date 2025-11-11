import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/theme_controller.dart';
import 'components/difficulty_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showDifficulties = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return FractionallySizedBox(
                    heightFactor: 0.6,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: const DifficultySection(),
                    ),
                  );
                },
              );
            },
            child: Container(
              width: 200,
              height: 80,
              margin: const EdgeInsets.only(bottom: 40),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/button.png'),
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }
}