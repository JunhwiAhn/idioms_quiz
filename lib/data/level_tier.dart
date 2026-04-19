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
    label: '入門',
    text: Color(0xFF7A6A5E),
    border: Color(0xFFD5C9BE),
    bg: Color(0x14000000),
  ),
  LevelTier(
    min: 5,
    label: '初級',
    text: Color(0xFF2E557F),
    border: Color(0xFF4A6FA5),
    bg: Color(0x1A4A6FA5),
  ),
  LevelTier(
    min: 10,
    label: '中級',
    text: Color(0xFF406A28),
    border: Color(0xFF8CB369),
    bg: Color(0x1F8CB369),
  ),
  LevelTier(
    min: 20,
    label: '上級',
    text: Color(0xFF8A5800),
    border: Color(0xFFE6A817),
    bg: Color(0x1FE6A817),
  ),
  LevelTier(
    min: 40,
    label: '熟練',
    text: Color(0xFF8C2E22),
    border: Color(0xFFB03A2E),
    bg: Color(0x1FB03A2E),
  ),
  LevelTier(
    min: 70,
    label: '達人',
    text: Color(0xFF5B3A8D),
    border: Color(0xFF7E57C2),
    bg: Color(0x247E57C2),
  ),
];

LevelTier levelTierFor(int level) {
  var current = _tiers.first;
  for (final t in _tiers) {
    if (level >= t.min) current = t;
  }
  return current;
}
