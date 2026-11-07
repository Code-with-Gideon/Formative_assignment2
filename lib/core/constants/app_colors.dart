import 'package:flutter/material.dart';

/// ALU brand palette.
///
/// The three core values were sampled pixel-by-pixel from the official
/// African Leadership University logo files (lossless PNG):
///   ALU Navy  #002E6D
///   ALU Red   #D00D2D
///   ALU Grey  #77818D  (from the light-background logo variant)
///
/// Every other value below is derived from those three so the whole app
/// stays inside the ALU colour family.
class AppColors {
  // ---- Official ALU brand values (sampled from logo) ----
  static const Color aluNavy = Color(0xFF002E6D);
  static const Color aluRed = Color(0xFFD00D2D);
  static const Color aluGrey = Color(0xFF77818D);
  static const Color aluWhite = Color(0xFFFFFFFF);

  // ---- Brand roles ----
  static const Color primary = aluNavy;
  // Lighter navy tint for icons, links and focus rings. Plain ALU navy
  // disappears on dark surfaces, this tint keeps 5:1 on white and 3.5:1 on
  // the dark navy background.
  static const Color primaryLight = Color(0xFF3D6DB5);
  static const Color accent = aluRed;
  static const Color accentSoft = Color(0xFFFBE7EA);

  // ---- Status colours (semantic, kept distinct from brand red) ----
  static const Color statusSubmitted = Color(0xFFD97706); // Amber
  static const Color statusSubmittedBg = Color(0xFFFEF3C7);
  static const Color statusInProgress = Color(0xFF2563EB); // Blue
  static const Color statusInProgressBg = Color(0xFFDBEAFE);
  static const Color statusResolved = Color(0xFF059669); // Green
  static const Color statusResolvedBg = Color(0xFFD1FAE5);
  static const Color statusDismissed = aluGrey;
  static const Color statusDismissedBg = Color(0xFFEEF0F3);

  // ---- Category badge tints ----
  static const Color catFacilities = aluNavy;
  static const Color catWater = Color(0xFF0284C7);
  static const Color catElectricity = Color(0xFFD97706);
  static const Color catSafety = aluRed;
  static const Color catSanitation = Color(0xFF059669);
  static const Color catFurniture = Color(0xFF7C3AED);

  // ---- Light mode neutrals (navy-tinted, not generic slate) ----
  static const Color lightBackground = Color(0xFFF4F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0B1A33);
  // ALU grey darkened just enough to pass WCAG AA (4.5:1) for body text.
  static const Color lightTextSecondary = Color(0xFF5C6672);
  static const Color lightBorder = Color(0xFFE1E6EE);

  // ---- Dark mode neutrals (built from ALU navy) ----
  static const Color darkBackground = Color(0xFF00132F);
  static const Color darkSurface = Color(0xFF0A2550);
  static const Color darkTextPrimary = Color(0xFFF2F5FA);
  static const Color darkTextSecondary = Color(0xFFA3AEBD);
  static const Color darkBorder = Color(0xFF1C3A6B);
}
