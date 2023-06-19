// Copyright 2023 Fredrick Allan Grott. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// ignore_for_file: avoid_classes_with_only_static_members
import 'dart:developer';
import 'package:logging/logging.dart';

/// Keep logger name private as the app designer routes
/// messages via the event bus.
// ignore: prefer-static-class
const _loggerName = 'Event Source Logger';

/// Keep the logger private as the app designer routes messages
/// via the event bus.
// ignore: prefer-static-class
final Logger _appEventSourceLogger = Logger(_loggerName);

/// Event Sourcing logger singleton with log appenders being decoupled.
///
/// @author Fredrick Allan Grott.
class EventSourceLogger {
  factory EventSourceLogger() {
    // Using logger to set logger levels
    _appEventSourceLogger.level = Level.ALL;

    // using logger to set listener to LogRecord log events
    _appEventSourceLogger.onRecord.listen((LogRecord rec) {
      if (rec.error != null && rec.stackTrace != null) {
        // if we have both error and stacktrace then log message with error and stacktrace
        log(
          'level: ${rec.level.name} loggerName: ${rec.loggerName} time: ${rec.time} message: ${rec.message} error: ${rec.error} exception: ${rec.stackTrace}',
        );
      } else if (rec.error != null) {
        // if we just have error then log message is with error
        log('level: ${rec.level.name} loggerName: ${rec.loggerName} time: ${rec.time} message: ${rec.message} error: ${rec.error}');
      } else {
        // if we have neither error or stacktrace then it is a normal LogRecord log event message
        log('level: ${rec.level.name} loggerName: ${rec.loggerName} time: ${rec.time} message: ${rec.message}');
      }
    });

    // event log initialize message
    _appEventSourceLogger.config('event sourcing initialized');

    return _singleton;
  }
  EventSourceLogger._();
  // Typical singleton declaration, the factory variation
  // 1. reference set to private instance
  // 2. factory set to reference
  // 3. constructor declared private

  static final _singleton = EventSourceLogger._();
}