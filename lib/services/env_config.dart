import 'package:flutter/services.dart' show rootBundle;

class EnvConfig {
  EnvConfig._();

  static final Map<String, String> _values = {};
  static bool _isLoaded = false;

  static Future<void> load({String fileName = '.env'}) async {
    if (_isLoaded) return;

    final content = await rootBundle.loadString(fileName);
    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final separatorIndex = line.indexOf('=');
      if (separatorIndex <= 0) continue;

      final key = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 1).trim();
      _values[key] = _stripQuotes(value);
    }

    _isLoaded = true;
  }

  static String requireValue(String key) {
    final value = _values[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing required environment variable: $key');
    }
    return value;
  }

  static String _stripQuotes(String value) {
    if (value.length < 2) return value;
    final startsAndEndsWithSingleQuote =
        value.startsWith("'") && value.endsWith("'");
    final startsAndEndsWithDoubleQuote =
        value.startsWith('"') && value.endsWith('"');
    if (startsAndEndsWithSingleQuote || startsAndEndsWithDoubleQuote) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }
}
