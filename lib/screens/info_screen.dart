import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // 실제 앱 환경에서는 사용자에게 오류를 알리는 스낵바 등을 사용하는 것이 좋습니다.
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final colors = themeController.colors;

    return Scaffold(
      backgroundColor: colors.background, // 💡 다크 배경 적용
      appBar: AppBar(
        title: const Text('앱 정보'),
        centerTitle: true,
        backgroundColor: colors.appBar,
        elevation: 0,
        foregroundColor: colors.textPrimary, // 뒤로가기 버튼 색상
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card( // 💡 정보를 Card로 감싸 GuideScreen과 통일감 부여
          color: colors.appBar,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              shrinkWrap: true, // Card 내 ListView 크기 제한
              children: [
                Text(
                  "모두의 즐거움! Koofy",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary, // 💡 앱 이름 강조
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: colors.placeholder),
                const SizedBox(height: 8),

                // 1. 앱 버전
                _buildInfoRow(
                  title: "앱 버전",
                  value: "1.0.0",
                  icon: Icons.info_outline,
                  colors: colors,
                ),
                // 2. 개발자
                _buildInfoRow(
                  title: "개발자",
                  value: "LaonCode",
                  icon: Icons.code,
                  colors: colors,
                ),
                // 3. 문의
                _buildInfoRow(
                  title: "문의 이메일",
                  value: "koofylab@gmail.com",
                  icon: Icons.email_outlined,
                  colors: colors,
                ),

                const SizedBox(height: 20),
                Text(
                  "법적 고지",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // 4. 개인정보 처리방침
                _buildLegalLink(
                  context,
                  title: "개인정보 처리방침",
                  url: "https://www.koofy.co.kr/privacy",
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => _launchUrl("https://www.koofy.co.kr/privacy"),
                  colors: colors,
                ),

                // 5. 이용 약관
                _buildLegalLink(
                  context,
                  title: "이용 약관",
                  url: "https://www.koofy.co.kr/terms",
                  icon: Icons.description_outlined,
                  onTap: () => _launchUrl("https://www.koofy.co.kr/terms"),
                  colors: colors,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String value,
    required IconData icon,
    required dynamic colors,
  }) {
    // 💡 수정: Row 내부에 Column을 사용하여 제목과 내용을 줄바꿈 처리
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.textPrimary, size: 24),
          const SizedBox(width: 12),
          Expanded( // 텍스트가 공간을 모두 차지하도록 하여 오버플로우 방지
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title:',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                // 💡 내용에 들여쓰기와 하이픈 적용
                Padding(
                  padding: const EdgeInsets.only(left: 8.0), 
                  child: Text(
                    '- $value', // 하이픈 추가
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalLink(
      BuildContext context, {
        required String title,
        required String url,
        required IconData icon,
        required VoidCallback onTap,
        required dynamic colors,
      }) {
    return ListTile(
      leading: Icon(icon, color: colors.textPrimary),
      title: Text(
        title,
        style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        url,
        style: TextStyle(color: colors.textPrimary, fontSize: 13), // 💡 링크 색상 강조
      ),
      trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      onTap: onTap,
    );
  }
}
