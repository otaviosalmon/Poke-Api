import 'package:flutter/material.dart';

// Centralizar cores de tipo aqui significa que se precisar mudar uma cor,
// muda em UM lugar. Isso é o princípio DRY (Don't Repeat Yourself).
const Map<String, Color> kTypeColors = {
  'fire': Color(0xFFFF6B35),
  'water': Color(0xFF4FC3F7),
  'grass': Color(0xFF66BB6A),
  'electric': Color(0xFFFFD54F),
  'psychic': Color(0xFFF48FB1),
  'ice': Color(0xFF80DEEA),
  'dragon': Color(0xFF7E57C2),
  'dark': Color(0xFF5D4037),
  'fairy': Color(0xFFF8BBD9),
  'normal': Color(0xFFBDBDBD),
  'fighting': Color(0xFFEF5350),
  'flying': Color(0xFF90CAF9),
  'poison': Color(0xFFBA68C8),
  'ground': Color(0xFFFFCC80),
  'rock': Color(0xFFA1887F),
  'bug': Color(0xFFAED581),
  'ghost': Color(0xFF7986CB),
  'steel': Color(0xFF90A4AE),
};

Color typeColor(String type) =>
    kTypeColors[type.toLowerCase()] ?? const Color(0xFFBDBDBD);
