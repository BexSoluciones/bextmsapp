/// Dart and Flutter packages.
import 'dart:developer' as dart;
import 'dart:async' show Zone;
import 'package:flutter/foundation.dart' as flutter;
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:intl/intl.dart' show NumberFormat;

/// Number formatter.
final _formatter = NumberFormat('#,##0.0', "en_US");

/// Supported log levels.
enum LogLevel {
  debugFinest,
  debugFiner,
  debugFine,
  debug,
  info,
  success,
  warning,
  error,
  fatal,
}

/// Value of each log level.
const Map<LogLevel, int> _number = {
  LogLevel.debugFinest: 100,
  LogLevel.debugFiner: 200,
  LogLevel.debugFine: 300,
  LogLevel.debug: 400,
  LogLevel.info: 500,
  LogLevel.success: 500,
  LogLevel.warning: 750,
  LogLevel.error: 1000,
  LogLevel.fatal: 2000,
};

/// Output color for each log level.
Map<LogLevel, String> _color = {
  LogLevel.debugFinest: _ansi[_Color.darkGray]!,
  LogLevel.debugFiner: _ansi[_Color.lightGray]!,
  LogLevel.debugFine: _ansi[_Color.white]!,
  LogLevel.debug: _ansi[_Color.defaultForeground]!,
  LogLevel.info: _ansi[_Color.cyan]!,
  LogLevel.success: _ansi[_Color.green]!,
  LogLevel.warning: _ansi[_Color.yellow]!,
  LogLevel.error: _ansi[_Color.red]!,
  LogLevel.fatal: _ansi[_Color.redBold]!,
};

/// Header symbol for each log level.
const Map<LogLevel, String> _symbol = {
  LogLevel.debugFinest: '\u2192', // Rightwards arrow.
  LogLevel.debugFiner: '\u2192', // Rightwards arrow.
  LogLevel.debugFine: '\u2192', // Rightwards arrow.
  LogLevel.debug: '\u2192', // Rightwards arrow.
  LogLevel.info: '\u2139', // Information source.
  LogLevel.success: '\u2713', // Check mark.
  LogLevel.warning: '!', // Exclamation point.
  LogLevel.error: '\u2718', // Heavy ballot X.
  LogLevel.fatal: '\u2718', // Heavy ballot X.
};

/// Supported ANSI colors.
enum _Color {
  defaultForeground,
  black,
  red,
  redBold,
  green,
  yellow,
  purple,
  magenta,
  cyan,
  lightGray,
  lightGrayBold,
  darkGray,
  darkGrayBold,
  lightRed,
  lightGreen,
  lightYellow,
  lightPurple,
  lightMagenta,
  lightCyan,
  white,
  whiteBold,
  reset,
}

/// ANSI escape codes.
const Map<_Color, String> _ansi = {
  _Color.defaultForeground: '\x1B[39m',
  _Color.black: '\x1B[30m',
  _Color.red: '\x1B[31m',
  _Color.redBold: '\x1B[31;1m',
  _Color.green: '\x1B[32m',
  _Color.yellow: '\x1B[33m',
  _Color.purple: '\x1B[34m',
  _Color.magenta: '\x1B[35m',
  _Color.cyan: '\x1B[36m',
  _Color.lightGray: '\x1B[37m',
  _Color.lightGrayBold: '\x1B[37;1m',
  _Color.darkGray: '\x1B[90m',
  _Color.darkGrayBold: '\x1B[90;1m',
  _Color.lightRed: '\x1B[91m',
  _Color.lightGreen: '\x1B[92m',
  _Color.lightYellow: '\x1B[93m',
  _Color.lightPurple: '\x1B[94m',
  _Color.lightMagenta: '\x1B[95m',
  _Color.lightCyan: '\x1B[96m',
  _Color.white: '\x1B[97m',
  _Color.whiteBold: '\x1B[97;1m',
  _Color.reset: '\x1B[0m',
};

/// Logger singleton.
class LoggerService {
  /// Minimum log level to show. Defaults to `LogLevel.debugFinest`.
  LogLevel _minLogLevel = LogLevel.debugFinest;

  /// Header width.
  int _headerWidth = 15;

  /// Header right-alignment.
  bool _headerRightAlign = true;

  /// Option to log to DevTools only.
  bool _logDevToolsOnly = false;

  /// Singleton which is returned every time this class is called.
  static final LoggerService _singleton = LoggerService._create();

  /// Private constructor. Called once to instantiate the singleton object.
  LoggerService._create();

  /// Public constructor. Returns a reference to the singleton object.
  factory LoggerService() {
    return _singleton;
  }

  /// Get minimum log level to show.
  LogLevel get logLevel => _minLogLevel;

  /// Set minimum log level to show.
  void setLogLevel(LogLevel level) => _minLogLevel = level;

  /// Get width of the full header string.
  int get headerWidth => _headerWidth;

  /// Set width of the full header string.
  void setHeaderWidth(int width) => _headerWidth = width;

  /// Get header alignment.
  bool get headerRightAlign => _headerRightAlign;

  /// Set header alignment.
  void setHeaderRightAlign(bool rightAlign) => _headerRightAlign = rightAlign;

  /// Get option to log to DevTools only.
  bool get logDevToolsOnly => _logDevToolsOnly;

  /// Set option to log to DevTools only.
  void setLogDevToolsOnly(bool option) => _logDevToolsOnly = option;
}

/// Reference to the [Logger] singleton.
LoggerService _logger = LoggerService();

/// Private log method that returns immediately when in release mode.
void __log(
    String? header,
    String message,
    LogLevel level, {
      Object? object,
    }) {
  // Break if in release mode:
  if (flutter.kReleaseMode) return;
  // Break if this message level is lower than minimum level to show:
  if (_number[level]! < _number[_logger.logLevel]!) return;
  // Otherwise, log the message to DevTools if option has been set:
  if (_logger.logDevToolsOnly) {
    dart.log(
      message,
      time: null,
      sequenceNumber: null,
      level: _number[level]!,
      name: header ?? '',
      zone: null,
      error: object,
      stackTrace: null,
    );
    // And break out of function to not print to terminal:
    return;
  }
  // From here on, print to terminal and to DevTools:
  String headerFull = '';
  if (header != null) {
    if (_logger.headerRightAlign) {
      headerFull =
          '${_symbol[level]!} ${header.padLeft(_logger.headerWidth)} : ';
    } else {
      headerFull =
          '${_symbol[level]!} ${header.padRight(_logger.headerWidth)} : ';
    }
  } else {
    headerFull =
        '${_symbol[level]!} ${' '.padLeft(_logger.headerWidth)} : ';
  }
  flutter.debugPrint('${_color[level]!}$headerFull$message\x1B[0m');
  if (object != null) {
    // If log call passed an object to print:
    try {
      // Try to print object.
      flutter.debugPrint('${_color[level]!}$object\x1B[0m');
    } catch (error) {
      // Otherwise, print error.
      flutter.debugPrint('${_color[level]!}$error\x1B[0m');
    }
  }
}

/// Implements the behavior of the log function from the dart:developer package.
void log(
    String message, {
      DateTime? time,
      int? sequenceNumber,
      int level = 0,
      String name = '',
      Zone? zone,
      Object? error,
      StackTrace? stackTrace,
    }) {
  dart.log(
    message,
    time: time,
    sequenceNumber: sequenceNumber,
    level: level,
    name: name,
    zone: zone,
    error: error,
    stackTrace: stackTrace,
  );
}

void logDebugFinest(String h, String message) {
  __log(h, message, LogLevel.debugFinest);
}

void logDebugFiner(String h, String message) {
  __log(h, message, LogLevel.debugFiner);
}

void logDebugFine(String h, String message) {
  __log(h, message, LogLevel.debugFine);
}

void logDebug(String h, String message) {
  __log(h, message, LogLevel.debug);
}

void logInfo(String h, String message) {
  __log(h, message, LogLevel.info);
}

void logSuccess(String h, String message) {
  __log(h, message, LogLevel.success);
}

void logWarning(String h, String message) {
  __log(h, message, LogLevel.warning);
}

void logError(String h, String message) {
  __log(h, message, LogLevel.error);
}

void logErrorObject(String h, Object error, String message) {
  __log(h, message, LogLevel.error, object: error);
}

void logFatal(String h, Object? error, String message) {
  __log(h, message, LogLevel.fatal, object: error);
}

void logBuild(String h, {LogLevel level = LogLevel.debugFinest}) {
  final timer = logTimerStart(h, 'Building...', level: level);
  SchedulerBinding.instance.addPostFrameCallback(
        (_) => logTimerStop(h, timer, 'Built', level: level),
  );
}

Stopwatch logTimerStart(
    String h,
    String message, {
      LogLevel level = LogLevel.debugFinest,
    }) {
  Stopwatch timer = Stopwatch()..start();
  __log(h, message, level);
  return timer;
}

void logTimerStop(
    String h,
    Stopwatch timer,
    String message, {
      LogLevel level = LogLevel.debugFiner,
    }) {
  timer.stop();
  final timerMilliseconds = _formatter.format(timer.elapsedMilliseconds);
  message = '$message in ${timerMilliseconds}ms';
  __log(h, message, level);
}
