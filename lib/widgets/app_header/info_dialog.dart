import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../controllers/theme_controller.dart';
import 'package:sudoku_flutter/l10n/app_localizations.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final colors = themeController.colors;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.info_app_bar_title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textMain,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textMain),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: colors.placeholder),
              const SizedBox(height: 12),

              // 앱 이름
              Text(
                AppLocalizations.of(context)!.info_app_name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colors.textMain,
                ),
              ),
              const SizedBox(height: 16),

              // 앱 버전
              _buildInfoRow(
                context,
                title: AppLocalizations.of(context)!.info_row_version_title,
                value: "1.0.0",
                icon: Icons.info_outline,
                colors: colors,
              ),

              // 개발자
              _buildInfoRow(
                context,
                title: AppLocalizations.of(context)!.info_row_developer_title,
                value: "LaonCode",
                icon: Icons.code,
                colors: colors,
              ),

              // 문의
              _buildInfoRow(
                context,
                title: AppLocalizations.of(context)!.info_row_email_title,
                value: "webmaster@koofy.co.kr",
                icon: Icons.email_outlined,
                colors: colors,
              ),

              const SizedBox(height: 20),

              Text(
                AppLocalizations.of(context)!.info_section_legal,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textMain,
                ),
              ),
              const SizedBox(height: 8),

              // 개인정보 처리방침
              _buildLegalLink(
                context,
                title: AppLocalizations.of(context)!.info_link_privacy,
                url: "https://www.koofy.co.kr/privacy",
                icon: Icons.privacy_tip_outlined,
                onTap: () => _launchUrl("https://www.koofy.co.kr/privacy"),
                colors: colors,
              ),

              // 이용 약관
              _buildLegalLink(
                context,
                title: AppLocalizations.of(context)!.info_link_terms,
                url: "https://www.koofy.co.kr/terms",
                icon: Icons.description_outlined,
                onTap: () => _launchUrl("https://www.koofy.co.kr/terms"),
                colors: colors,
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required dynamic colors,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.textMain, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title:',
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.textMain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '- $value',
                    style: TextStyle(fontSize: 15, color: colors.textSub),
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
      leading: Icon(icon, color: colors.textMain),
      title: Text(
        title,
        style: TextStyle(color: colors.textMain, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        url,
        style: TextStyle(color: colors.textSub, fontSize: 13),
      ),
      trailing: Icon(Icons.chevron_right, color: colors.textSub),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      onTap: onTap,
    );
  }
}