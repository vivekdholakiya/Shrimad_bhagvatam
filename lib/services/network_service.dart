import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Thrown when a network call fails after all retries. Screens catch this
/// specifically to show a friendly "You're offline" empty state instead of
/// a raw exception.
class NoConnectionException implements Exception {
  final String message;
  const NoConnectionException([this.message = 'No internet connection']);
  @override
  String toString() => message;
}

/// Thrown when a call exceeds [NetworkService.defaultTimeout] on every retry.
class RequestTimeoutException implements Exception {
  final String message;
  const RequestTimeoutException([this.message = 'Request timed out']);
  @override
  String toString() => message;
}

/// NetworkService — small dependency-free resilience wrapper used by
/// FirestoreService (and anything else doing network I/O).
///
/// Provides the three things the production spec calls for that the
/// original code didn't have:
///   1. Internet checking   — [hasConnection]
///   2. Timeout             — every call is wrapped in `.timeout(...)`
///   3. Retry (backoff)     — [run] retries transient failures
///
/// Deliberately has zero third-party dependencies (no connectivity_plus)
/// so it drops into the existing pubspec without a new package.
class NetworkService {
  NetworkService._();
  static final NetworkService instance = NetworkService._();

  static const Duration defaultTimeout = Duration(seconds: 12);
  static const int defaultRetries = 2;

  /// Cheap real connectivity probe. A DNS lookup is a better signal than
  /// `connectivity_plus`'s "connected to a router" check, because it also
  /// catches the "connected to WiFi but no internet" case.
  Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Runs [task], retrying transient failures with exponential backoff and
  /// enforcing [timeout] on every attempt.
  ///
  /// Usage:
  ///   final cantos = await NetworkService.instance.run(() => _fetchCantos());
  Future<T> run<T>(
    Future<T> Function() task, {
    Duration timeout = defaultTimeout,
    int retries = defaultRetries,
    String? debugLabel,
  }) async {
    // Fail fast with a clear, catchable error instead of letting Firestore's
    // internal retry/hang behavior surface a confusing low-level exception.
    if (!await hasConnection()) {
      throw const NoConnectionException();
    }

    Object? lastError;
    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        return await task().timeout(timeout);
      } on TimeoutException catch (e) {
        lastError = e;
      } catch (e) {
        lastError = e;
      }

      if (attempt < retries) {
        final backoff = Duration(milliseconds: 400 * (1 << attempt)); // 400ms, 800ms...
        if (kDebugMode && debugLabel != null) {
          debugPrint('[$debugLabel] attempt ${attempt + 1} failed, retrying in ${backoff.inMilliseconds}ms: $lastError');
        }
        await Future.delayed(backoff);
      }
    }

    if (lastError is TimeoutException) {
      throw const RequestTimeoutException();
    }
    throw lastError!;
  }
}
