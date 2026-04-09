import 'dart:async';

import 'package:unseen_scout/core/services/monitor_service/monitor.service.dart';

/// Error Wrapper that automatically handles the errors behind the scenes.
///
/// > * _@wrap_ => Wrap callbacks to auto handle errors.
///
class ErrorWrapper {
  /// Wrapper for sync methods/functions. Returns [T].
  ///
  /// > * _@param: (required)_ __[Function()]__
  ///
  /// > * _@param: (required)_ __[String]__ library => This is the library/Module from where the function is called.
  ///
  /// > * _@param: (required)_ __[String]__ description => This is the description of the method's functionality, should be very simple. Use keyword `while`
  /// then followed with the description. `E.g while converting string to int`.
  ///
  /// Example:
  /// ```
  /// final status = ErrorWrapper.sync<int>(
  ///          () => testFunction(),
  ///          context: 'Component Test',
  ///          description: 'while testing component',
  ///        );
  /// ```
  @pragma('vm:notify-debugger-on-exception')
  static T? sync<T>(
    T Function() callback, {
    required String library,
    required String description,
    T? Function(Object error)? onError,
  }) {
    try {
      return callback();
    } catch (error, stack) {
      // * This will dump the error to the console and also report it for monitoring.
      MonitorService.report(
        ex: error,
        library: library,
        description: description,
        stack: stack,
      );

      if (onError != null) return onError(error);
      return null;
    }
  }

  /// Wrapper for async methods or [Future] methods. Returns a [Future of T].
  ///
  /// > * _@param: (required)_ __[Function()]__
  ///
  /// > * _@param: (required)_ __[String]__ library => This is the library/Module from where the function is called.
  ///
  /// > * _@param: (required)_ __[String]__ description => This is the description of the method's functionality, should be very simple. Use keyword `while`
  /// then followed with the description. `E.g while converting string to int`.
  ///
  /// Example:
  /// ```
  /// final status = ErrorWrapper.async<int>(
  ///          () async => await testFunction(),
  ///          context: 'Component Test',
  ///          description: 'while testing component',
  ///        );
  /// ```
  @pragma('vm:notify-debugger-on-exception')
  static Future<T?> async<T>(
    Future<T> Function() callback, {
    required String library,
    required String description,
    T? Function(Object error)? onError,
  }) async {
    try {
      return await callback();
    } catch (error, stack) {
      // * This will dump the error to the console and also report it for monitoring.
      MonitorService.report(
        ex: error,
        library: library,
        description: description,
        stack: stack,
      );

      if (onError != null) return onError(error);
      return null;
    }
  }

  @pragma('vm:notify-debugger-on-exception')
  static Stream<T?> stream<T>(
    Stream<T> Function() callback, {
    required String library,
    required String description,
    T? Function(Object error)? onError,
  }) async* {
    try {
      yield* callback();
    } catch (error, stack) {
      // * This will dump the error to the console and also report it for monitoring.
      MonitorService.report(
        ex: error,
        library: library,
        description: description,
        stack: stack,
      );

      if (onError != null) yield onError(error);
      yield null;
    }
  }
}
