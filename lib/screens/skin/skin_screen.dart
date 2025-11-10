import 'package:flutter/material.dart';
import 'components/skin_list.dart';

class SkinScreen extends StatelessWidget {
  const SkinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SkinList(),
      ),
    );
  }
}