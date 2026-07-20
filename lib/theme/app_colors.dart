import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────
///  AppColors — Devotional Palette
///  Deep Maroon + Saffron + Gold on Warm Cream base
/// ─────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Brand / Primary ────────────────────────────
  static const maroon = Color(0xFF6B1A1A);      // Deep temple maroon
  static const maroonLight = Color(0xFF9B3A3A);
  static const maroonDark = Color(0xFF4A0E0E);

  // ── Accent ─────────────────────────────────────
  static const saffron = Color(0xFFE8832A);     // Saffron orange
  static const saffronLight = Color(0xFFF5A855);
  static const gold = Color(0xFFCB9B1E);        // Gold accent
  static const goldLight = Color(0xFFE8C040);
  static const goldGlow = Color(0xFFF5D56E);

  // ── Light Mode Backgrounds ──────────────────────
  static const cream = Color(0xFFFAF6F0);       // Soft cream base
  static const warmWhite = Color(0xFFFFFDF8);
  static const cardLight = Color(0xFFFFF9F0);

  // ── Dark Mode Backgrounds ───────────────────────
  static const darkBase = Color(0xFF1A0E0E);    // Deep charcoal-maroon
  static const darkSurface = Color(0xFF251515);
  static const darkCard = Color(0xFF2E1A1A);
  static const darkElevated = Color(0xFF3A2020);

  // ── Sepia Backgrounds ──────────────────────────
  static const sepiaBg = Color(0xFFF4EDDC);
  static const sepiaCard = Color(0xFFEEE4CA);
  static const sepiaText = Color(0xFF3D2B0E);

  // ── Text ───────────────────────────────────────
  static const textDark = Color(0xFF2F1B0E);
  static const textMedium = Color(0xFF6B4E35);
  static const textLight = Color(0xFF9E7A5C);

  // ── Borders & Dividers ──────────────────────────
  static const border = Color(0xFFE6D5B8);
  static const divider = Color(0xFFF0E5CF);
  static const borderDark = Color(0xFF3D2020);

  // ── Status ─────────────────────────────────────
  static const success = Color(0xFF4E8B52);
  static const error = Color(0xFFC94A42);
  static const warning = Color(0xFFC9762E); // Warm orange — added for redesign

  // ── Surface (redesign) ──────────────────────────
  // "Soft Beige" surface distinct from `warmWhite`/`cardLight` — used by the
  // new AppCard/AppHeader so redesigned screens have one consistent surface
  // tone instead of each screen picking its own off-white.
  static const surfaceBeige = Color(0xFFF3E9D8);
  static const surfaceBeigeDark = Color(0xFF2A1E14);

  // ── Semantic aliases (redesign) ──────────────────
  // The redesign brief speaks in terms of primary/secondary/accent rather
  // than maroon/saffron/gold. Rather than rename the underlying tokens
  // (which every existing screen already references), we alias them so new
  // components read semantically while old screens keep working untouched.
  static const primary = saffron;
  static const primaryDark = Color(0xFFC96A1A);
  static const secondary = gold;
  static const accent = maroon;

  // ── Glass effect (redesign) ─────────────────────
  static const glassLight = Color(0xCCFFFDF8); // warmWhite @ 80%
  static const glassDark = Color(0xCC251515); // darkSurface @ 80%

  // ── Shadow ─────────────────────────────────────
  static const shadow = Color(0x20000000);
  static const shadowGold = Color(0x30CB9B1E);
}