import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("앱 정보")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "모두의 즐거움! Koofy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text("앱 버전: 1.0.0"),
            const SizedBox(height: 16),
            const Text("개발자: LaonCode"),
            const SizedBox(height: 16),
            const Text("문의: koofylab@gmail.com"),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("개인정보 처리방침"),
              subtitle: const Text(
                "https://www.koofy.co.kr/privacy",
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () => _launchUrl("https://www.koofy.co.kr/privacy"),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("이용 약관"),
              subtitle: const Text(
                "https://www.koofy.co.kr/terms",
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () => _launchUrl("https://www.koofy.co.kr/terms"),
            ),
          ],
        ),
      ),
    );
  }
}