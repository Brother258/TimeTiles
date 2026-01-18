import 'package:flutter/services.dart';
import '../models/background_settings.dart';

class WallpaperChannelService {
  static const String _channelName = 'year_wallpaper_channel';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static Future<bool> saveColors({
    required int pastColor,
    required int currentColor,
    required int emptyColor,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('saveColors', {
        'pastColor': pastColor,
        'currentColor': currentColor,
        'emptyColor': emptyColor,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to save colors: ${e.message}',
        e.code,
      );
    }
  }

  static Future<bool> saveQuote(String quoteText) async {
    try {
      final result = await _channel.invokeMethod<bool>('saveQuote', quoteText);
      return result ?? false;
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to save quote: ${e.message}',
        e.code,
      );
    }
  }

  static Future<bool> openWallpaperChooser() async {
    try {
      final result = await _channel.invokeMethod<bool>('openWallpaperChooser');
      return result ?? false;
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to open wallpaper chooser: ${e.message}',
        e.code,
      );
    }
  }

  static Future<Map<String, int>> getColors() async {
    try {
      final result = await _channel.invokeMethod<Map>('getColors');
      if (result == null) {
        return _defaultColors;
      }
      return {
        'pastColor':
            result['pastColor'] as int? ?? _defaultColors['pastColor']!,
        'currentColor':
            result['currentColor'] as int? ?? _defaultColors['currentColor']!,
        'emptyColor':
            result['emptyColor'] as int? ?? _defaultColors['emptyColor']!,
      };
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to get colors: ${e.message}',
        e.code,
      );
    }
  }

  static Future<String> getQuote() async {
    try {
      final result = await _channel.invokeMethod<String>('getQuote');
      return result ?? defaultQuote;
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to get quote: ${e.message}',
        e.code,
      );
    }
  }

  static Future<bool> saveColumnCount(int columnCount) async {
    try {
      final result =
          await _channel.invokeMethod<bool>('saveColumnCount', columnCount);
      return result ?? false;
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to save column count: ${e.message}',
        e.code,
      );
    }
  }

  static Future<int> getColumnCount() async {
    try {
      final result = await _channel.invokeMethod<int>('getColumnCount');
      return result ?? defaultColumnCount;
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to get column count: ${e.message}',
        e.code,
      );
    }
  }

  static Future<bool> saveCustomQuote(String quote, int days) async {
    try {
      final result = await _channel.invokeMethod<bool>('saveCustomQuote', {
        'quote': quote,
        'days': days,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to save custom quote: ${e.message}',
        e.code,
      );
    }
  }

  static Future<bool> clearCustomQuote() async {
    try {
      final result = await _channel.invokeMethod<bool>('clearCustomQuote');
      return result ?? false;
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to clear custom quote: ${e.message}',
        e.code,
      );
    }
  }

  static Future<CustomQuoteInfo> getCustomQuote() async {
    try {
      final result = await _channel.invokeMethod<Map>('getCustomQuote');
      if (result == null) {
        return CustomQuoteInfo(quote: '', remainingDays: 0, isPermanent: false);
      }
      return CustomQuoteInfo(
        quote: result['quote'] as String? ?? '',
        remainingDays: result['remainingDays'] as int? ?? 0,
        isPermanent: result['isPermanent'] as bool? ?? false,
      );
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to get custom quote: ${e.message}',
        e.code,
      );
    }
  }

  static const Map<String, int> _defaultColors = {
    'pastColor': 0xFF4CAF50,
    'currentColor': 0xFFFF9800,
    'emptyColor': 0xFF424242,
  };

  static const String defaultQuote = 'Make every day count';
  static const int defaultColumnCount = 7;
  static const int minColumnCount = 4;
  static const int maxColumnCount = 20;
  static const double defaultTopMargin = 20.0;
  static const double defaultBottomMargin = 20.0;

  static Map<String, int> get defaultColors => Map.from(_defaultColors);

  static Future<bool> saveMargins({
    required double topMargin,
    required double bottomMargin,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('saveMargins', {
        'topMargin': topMargin,
        'bottomMargin': bottomMargin,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to save margins: ${e.message}',
        e.code,
      );
    }
  }

  static Future<Map<String, double>> getMargins() async {
    try {
      final result = await _channel.invokeMethod<Map>('getMargins');
      if (result == null) {
        return {
          'topMargin': defaultTopMargin,
          'bottomMargin': defaultBottomMargin
        };
      }
      return {
        'topMargin':
            (result['topMargin'] as num?)?.toDouble() ?? defaultTopMargin,
        'bottomMargin':
            (result['bottomMargin'] as num?)?.toDouble() ?? defaultBottomMargin,
      };
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to get margins: ${e.message}',
        e.code,
      );
    }
  }

  static Future<bool> saveBackgroundSettings(
      BackgroundSettings settings) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'saveBackgroundSettings',
        settings.toMap(),
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to save background settings: ${e.message}',
        e.code,
      );
    }
  }

  static Future<BackgroundSettings> getBackgroundSettings() async {
    try {
      final result = await _channel.invokeMethod<Map>('getBackgroundSettings');
      if (result == null) {
        return const BackgroundSettings();
      }
      return BackgroundSettings.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to get background settings: ${e.message}',
        e.code,
      );
    }
  }

  static Future<bool> refreshWallpaper() async {
    try {
      final result = await _channel.invokeMethod<bool>('refreshWallpaper');
      return result ?? false;
    } on PlatformException catch (e) {
      throw WallpaperChannelException(
        'Failed to refresh wallpaper: ${e.message}',
        e.code,
      );
    }
  }
}

class WallpaperChannelException implements Exception {
  final String message;
  final String? code;

  WallpaperChannelException(this.message, [this.code]);

  @override
  String toString() => 'WallpaperChannelException: $message (code: $code)';
}

class CustomQuoteInfo {
  final String quote;
  final int remainingDays;
  final bool isPermanent;

  CustomQuoteInfo({
    required this.quote,
    required this.remainingDays,
    required this.isPermanent,
  });

  bool get hasCustomQuote =>
      quote.isNotEmpty && (isPermanent || remainingDays > 0);
  bool get isExpired => !isPermanent && remainingDays <= 0 && quote.isNotEmpty;
}
