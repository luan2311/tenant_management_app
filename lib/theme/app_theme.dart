import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Bảng màu chủ đạo "The Ethereal Sanctuary" ───────────────────────────────

const kSurface                = Color(0xFFF7F9FB);
const kPrimary                = Color(0xFF2E6486);
const kPrimaryDim             = Color(0xFF1F5879);
const kPrimaryFixed           = Color(0xFFA5D8FF);
const kPrimaryFixedDim        = Color(0xFF97CAF0);
const kOnPrimary              = Color(0xFFF5F9FF);
const kOnPrimaryFixed         = Color(0xFF003853);
const kOnPrimaryFixedVariant  = Color(0xFF1C5577);
const kOnSurface              = Color(0xFF2C3437);
const kOnSurfaceVariant       = Color(0xFF596064);
const kOutline                = Color(0xFF747C80);
const kOutlineVariant         = Color(0xFFACB3B7);
const kSurfaceContainerLow    = Color(0xFFF0F4F7);
const kSurfaceContainerHigh   = Color(0xFFE3E9ED);
const kSecondaryContainer     = Color(0xFFD3E5F5);
const kTertiaryContainer      = Color(0xFFCBCEFE);
const kTertiaryFixed          = Color(0xFFCBCEFE);

// ─── Theme dùng chung toàn app ────────────────────────────────────────────────

ThemeData buildAppTheme() {
  return ThemeData(
    textTheme: GoogleFonts.beVietnamProTextTheme(),
    colorScheme: const ColorScheme.light(
      primary:          kPrimary,
      onPrimary:        kOnPrimary,
      primaryContainer: kPrimaryFixed,
      secondary:        Color(0xFF50616F),
      surface:          kSurface,
      onSurface:        kOnSurface,
      outline:          kOutline,
    ),
    useMaterial3: true,
  );
}
