import 'package:flutter/material.dart';

class AppTextStyle {
  /// Header besar, misal "Invengo"
  static TextStyle header(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
    );
  }

  /// Subheader, misal "Welcome back, Admin"
  static TextStyle subHeader(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface.withOpacity(0.8),
    );
  }

  /// Judul kecil di dalam card
  static TextStyle cardTitle(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface.withOpacity(0.9),
    );
  }

  /// Nilai utama di card (angka besar)
  static TextStyle cardValue(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
    );
  }

  /// Teks pertumbuhan, misal "+12%"
  static TextStyle growth(BuildContext context) {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF12B76A), // hijau growth (tetap sama di kedua mode)
    );
  }

  /// Section title, misal “Revenue Overview”
  static TextStyle sectionTitle(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );
  }

  /// Section subtitle, misal “Last 30 days”
  static TextStyle sectionSubtitle(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface.withOpacity(0.7),
    );
  }

  /// Heading 1
  static TextStyle h1(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );
  }

  /// Heading 2
  static TextStyle h2(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );
  }

  /// Heading 3
  static TextStyle h3(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface,
    );
  }

  /// Heading 4
  static TextStyle h4(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface,
    );
  }

  /// Paragraf umum
  static TextStyle p(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 16,
      color: theme.colorScheme.onSurface,
    );
  }

  /// Harga atau teks dengan warna utama
  static TextStyle pPrice(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 16,
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
    );
  }

  /// Label kecil (seperti caption)
  static TextStyle label(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 12,
      color: theme.colorScheme.onSurface.withOpacity(0.7),
    );
  }

  /// Tombol (teks di atas button)
  static TextStyle button(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onPrimary,
    );
  }
}
