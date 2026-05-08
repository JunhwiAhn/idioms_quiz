import 'package:flutter/material.dart';

class LevelTier {
  final int min;
  final String label;
  final Color text;
  final Color border;
  final Color bg;

  const LevelTier({
    required this.min,
    required this.label,
    required this.text,
    required this.border,
    required this.bg,
  });
}

const List<LevelTier> _tiers = [
  LevelTier(
    min: 1,
    label: 'A1 Warm-up',
    text: Color(0xFF00796B),
    border: Color(0xFF4DB6AC),
    bg: Color(0x264DB6AC),
  ),
  LevelTier(
    min: 5,
    label: 'A1 Ready',
    text: Color(0xFF1565C0),
    border: Color(0xFF64B5F6),
    bg: Color(0x2664B5F6),
  ),
  LevelTier(
    min: 10,
    label: 'A2 Builder',
    text: Color(0xFF2E7D32),
    border: Color(0xFF81C784),
    bg: Color(0x2681C784),
  ),
  LevelTier(
    min: 20,
    label: 'B1 Runner',
    text: Color(0xFFF57C00),
    border: Color(0xFFFFB74D),
    bg: Color(0x33FFB74D),
  ),
  LevelTier(
    min: 40,
    label: 'B2 Speaker',
    text: Color(0xFFD84315),
    border: Color(0xFFFF8A65),
    bg: Color(0x33FF8A65),
  ),
  LevelTier(
    min: 70,
    label: 'DELE Master',
    text: Color(0xFF6A1B9A),
    border: Color(0xFFBA68C8),
    bg: Color(0x2EBA68C8),
  ),
];

LevelTier levelTierFor(int level) {
  var current = _tiers.first;
  for (final t in _tiers) {
    if (level >= t.min) current = t;
  }
  return current;
}
