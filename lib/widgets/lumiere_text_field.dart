import 'package:flutter/material.dart';
import 'package:tenant_management_app/theme/app_theme.dart';

/// Input dạng Glassmorphism — dùng trên nền tối/gradient (màn hình Đăng nhập).
class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? label;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: kOnSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: kOutline.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(prefixIcon, color: kOutline, size: 22),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.55),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.45)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.45)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: kPrimaryFixed, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Input dạng Neumorphism — dùng trên nền sáng (màn hình Đăng ký, Form).
class NeuTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? label;

  const NeuTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 6),
            child: Text(
              label!.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: kOnSurfaceVariant,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: kSurfaceContainerHigh.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(9999),
            boxShadow: [
              BoxShadow(
                color: kOnSurfaceVariant.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(4, 4),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.90),
                blurRadius: 8,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: kOnSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: kOutlineVariant, fontSize: 14),
              prefixIcon: Icon(prefixIcon, color: kOutline, size: 20),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9999),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9999),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9999),
                borderSide:
                    const BorderSide(color: kPrimaryFixedDim, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
