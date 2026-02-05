import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

/// Barra inferior de información corporativa
/// Muestra iconos RRSS + email + web
/// Fondo azul corporativo (#00AEC7)
class InfoBar extends StatelessWidget {
  const InfoBar({super.key});

  static const double height = 56.0;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'info@santiagovargas.com',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Iconos RRSS
              _SocialIcon(
                icon: Icons.camera_alt_outlined, // Instagram placeholder
                onTap: () => _launchUrl('https://instagram.com'),
              ),
              const SizedBox(width: 12),
              _SocialIcon(
                icon: Icons.facebook_outlined,
                onTap: () => _launchUrl('https://facebook.com'),
              ),
              const SizedBox(width: 12),
              _SocialIcon(
                icon: Icons.link, // LinkedIn placeholder
                onTap: () => _launchUrl('https://linkedin.com'),
              ),

              const Spacer(),

              // Info de contacto
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _launchEmail,
                      child: const Text(
                        'INFO@SANTIAGOVARGAS.COM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () => _launchUrl('https://www.santiagovargas.com'),
                      child: const Text(
                        'WWW.SANTIAGOVARGAS.COM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(40),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
