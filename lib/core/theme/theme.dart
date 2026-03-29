import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ThemeTokens {
  final Map<String, dynamic> _root;
  ThemeTokens(this._root);

  /// Static cache to avoid reloading/parsing JSON multiple times
  static final Map<String, ThemeTokens> _cache = {};

  dynamic call(String path) {
    final parts = path.split(".");
    dynamic result = _root;
    for (final p in parts) {
      if (result is Map<String, dynamic>) {
        result = result[p];
      } else {
        return null;
      }
    }

    // Convert Color(...) strings into real Color
    if (result is String && result.startsWith("Color(")) {
      return _parseColor(result);
    }

    // Convert hex, 0x, or rgba into Color
    if (result is String &&
        (result.startsWith("#") ||
            result.startsWith("0x") ||
            result.startsWith("rgba"))) {
      return _parseColor(result);
    }

    // Convert numbers into double
    if (result is String && double.tryParse(result) != null) {
      return double.parse(result);
    }

    return result;
  }

  static Color _parseColor(String colorString) {
    final s = colorString.trim();

    if (s.startsWith("Color(")) {
      final hex = s.replaceAll("Color(", "").replaceAll(")", "");
      return Color(int.parse(hex));
    }

    if (s.startsWith("0x")) {
      return Color(int.parse(s));
    }

    if (s.startsWith("#")) {
      final hex = s.substring(1);
      if (hex.length == 6) {
        return Color(int.parse("0xFF$hex"));
      } else if (hex.length == 8) {
        return Color(int.parse("0x$hex"));
      }
    }

    if (s.toLowerCase().startsWith("rgba")) {
      final parts = s.replaceAll(RegExp(r'rgba|\(|\)|\s'), "").split(",");
      if (parts.length == 4) {
        final r = int.parse(parts[0]);
        final g = int.parse(parts[1]);
        final b = int.parse(parts[2]);
        final a = (double.parse(parts[3]) * 255).round();
        return Color.fromARGB(a, r, g, b);
      }
    }

    return Colors.transparent;
  }

  static Future<ThemeTokens> fromAsset(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path]!;
    }
    final str = await rootBundle.loadString(path);
    final data = json.decode(str);
    final tokens = ThemeTokens(data);
    _cache[path] = tokens;
    return tokens;
  }
}
