import 'dart:io';
import 'package:flutter/material.dart';

/// Modern traveler avatar with initials and deterministic pastel color palettes.
class TravelerAvatar extends StatelessWidget {
  final String name;
  final String? avatarPath;
  final double radius;
  final double? fontSize;
  final bool showBorder;

  const TravelerAvatar({
    super.key,
    required this.name,
    this.avatarPath,
    this.radius = 18,
    this.fontSize,
    this.showBorder = true,
  });

  static const List<Color> _avatarColors = [
    Color(0xFF0F766E), // Teal
    Color(0xFF0284C7), // Sky Blue
    Color(0xFF7C3AED), // Violet
    Color(0xFFD97706), // Amber
    Color(0xFFBE185D), // Pink
    Color(0xFF059669), // Emerald
    Color(0xFF4F46E5), // Indigo
    Color(0xFFEA580C), // Orange
    Color(0xFF0D9488), // Cyan/Teal
    Color(0xFF9333EA), // Purple
  ];

  Color _getDeterministicColor(String text) {
    if (text.isEmpty) return _avatarColors[0];
    final hash = text.codeUnits.fold<int>(0, (prev, curr) => prev + curr);
    return _avatarColors[hash % _avatarColors.length];
  }

  String _getInitials(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getDeterministicColor(name);
    final initials = _getInitials(name);
    final effectiveFontSize = fontSize ?? (radius * 0.75);

    if (avatarPath != null && avatarPath!.isNotEmpty) {
      final file = File(avatarPath!);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: bgColor.withValues(alpha: 0.15),
          backgroundImage: FileImage(file),
        );
      }
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: bgColor.withValues(alpha: 0.35),
                width: 1.5,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: bgColor,
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
