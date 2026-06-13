import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Nút hành động chính với gradient, dùng chung toàn app.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final bool isLoading;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingIcon,
    this.isLoading = false,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: onPressed == null && !isLoading
                ? [kOutlineVariant, kOutline]
                : [kPrimaryFixed, kPrimary],
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withValues(alpha: 0.20),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: const StadiumBorder(),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: kOnPrimaryFixed,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kOnPrimaryFixed,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailingIcon, color: kOnPrimaryFixed, size: 20),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

/// Nút phụ kiểu outlined (viền, nền trong), dùng cho hành động thứ cấp.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kPrimary, width: 1.5),
          shape: const StadiumBorder(),
          foregroundColor: kPrimary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
