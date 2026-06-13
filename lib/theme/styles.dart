import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF7997B5);
  static const Color accent = Color(0xFFE7D9EA);
  static const Color backgroundStart = Color(0xFFF7FBFF);
  static const Color backgroundMiddle = Color(0xFFEAF3FA);
  static const Color backgroundEnd = Color(0xFFFFF6FA);

  static const Color sanctuaryBlue = Color(0xFFD9EAF5);
  static const Color sanctuaryLight = Color(0xFFF8FBFF);
  static const Color sanctuaryDark = Color(0xFF34536D);
  static const Color sanctuaryInk = Color(0xFF22384B);

  static const Color textPrimary = Color(0xFF263445);
  static const Color textSecondary = Color(0xFF728195);
  static const Color textMuted = Color(0xFF9AA8B7);

  static const Color badgeEmptyBg = Color(0xFFE6F4EE);
  static const Color badgeEmptyText = Color(0xFF2F7D65);

  static const Color badgeRentedBg = Color(0xFFE8F1FF);
  static const Color badgeRentedText = Color(0xFF426DAA);

  static const Color badgeMaintenanceBg = Color(0xFFFFECE7);
  static const Color badgeMaintenanceText = Color(0xFFC1664E);
}

class AppStyles {
  // Be Vietnam Pro Font styles
  static TextStyle headline(BuildContext context, {Color? color, double? fontSize, FontWeight? fontWeight}) {
    return GoogleFonts.beVietnamPro(
      textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: color ?? AppColors.textPrimary,
        fontSize: fontSize ?? 24,
        fontWeight: fontWeight ?? FontWeight.bold,
      ),
    );
  }

  static TextStyle title(BuildContext context, {Color? color, double? fontSize, FontWeight? fontWeight}) {
    return GoogleFonts.beVietnamPro(
      textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: color ?? AppColors.textPrimary,
        fontSize: fontSize ?? 18,
        fontWeight: fontWeight ?? FontWeight.w600,
      ),
    );
  }

  static TextStyle body(BuildContext context, {Color? color, double? fontSize, FontWeight? fontWeight}) {
    return GoogleFonts.beVietnamPro(
      textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: color ?? AppColors.textPrimary,
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
    );
  }

  static TextStyle caption(BuildContext context, {Color? color, double? fontSize, FontWeight? fontWeight}) {
    return GoogleFonts.beVietnamPro(
      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: color ?? AppColors.textSecondary,
        fontSize: fontSize ?? 12,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
    );
  }

  // Ethereal Sanctuary Glassmorphic decoration
  static BoxDecoration glassmorphic({
    double blur = 15.0,
    double opacity = 0.65,
    double borderRadius = 20.0,
    Color color = Colors.white,
  }) {
    return BoxDecoration(
      color: color.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.62),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6A8BAB).withOpacity(0.10),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ],
    );
  }

  // Neumorphic decoration (soft dual shadow)
  static BoxDecoration neumorphic({
    double borderRadius = 20.0,
    Color color = const Color(0xFFF3F8F2),
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          offset: const Offset(-5, -5),
          blurRadius: 10,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          offset: const Offset(5, 5),
          blurRadius: 10,
        ),
      ],
    );
  }
}

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color color;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.blur = 15.0,
    this.opacity = 0.65,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: AppStyles.glassmorphic(
              blur: blur,
              opacity: opacity,
              borderRadius: borderRadius,
              color: color,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class EtherealBackground extends StatelessWidget {
  final Widget child;

  const EtherealBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundStart,
            AppColors.backgroundMiddle,
            AppColors.backgroundEnd,
          ],
        ),
      ),
      child: child,
    );
  }
}

class SanctuaryHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const SanctuaryHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyles.headline(
                  context,
                  color: AppColors.sanctuaryInk,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppStyles.body(
                  context,
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class SoftIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const SoftIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = AppColors.sanctuaryDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 48,
          height: 48,
          decoration: AppStyles.glassmorphic(opacity: 0.72, borderRadius: 18),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusPill({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppStyles.caption(
          context,
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
