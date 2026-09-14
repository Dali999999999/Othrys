/// Functional Result type representing either a successful computation [Success]
/// or an error [Failure].
sealed class Result<T> {
  const Result();

  /// Returns `true` if this instance is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns `true` if this instance is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Returns the failure instance if this is a [Failure], otherwise `null`.
  Failure<T>? get failureOrNull => this is Failure<T> ? this as Failure<T> : null;

  /// Returns the data if this is a [Success], otherwise `null`.
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;

  /// Transforms this result using [onSuccess] or [onFailure].
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, Object? exception, StackTrace? stackTrace) onFailure,
  }) {
    final current = this;
    if (current is Success<T>) {
      return onSuccess(current.data);
    } else if (current is Failure<T>) {
      return onFailure(current.message, current.exception, current.stackTrace);
    }
    throw StateError('Unhandled Result subtype: $runtimeType');
  }

  /// Maps the success value using [transform].
  Result<R> map<R>(R Function(T data) transform) {
    final current = this;
    if (current is Success<T>) {
      return Success(transform(current.data));
    } else if (current is Failure<T>) {
      return Failure(current.message, current.exception, current.stackTrace);
    }
    throw StateError('Unhandled Result subtype: $runtimeType');
  }

  /// Returns the value if success, otherwise returns [fallback].
  T getOrElse(T Function() fallback) {
    final current = this;
    if (current is Success<T>) {
      return current.data;
    }
    return fallback();
  }

  /// Returns the value if success, otherwise throws the exception or a [StateError].
  T getOrThrow() {
    final current = this;
    if (current is Success<T>) {
      return current.data;
    } else if (current is Failure<T>) {
      if (current.exception != null) {
        throw current.exception!;
      }
      throw StateError(current.message);
    }
    throw StateError('Unhandled Result subtype: $runtimeType');
  }
}

/// A successful computation containing [data].
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T> && other.data == data;

  @override
  int get hashCode => data.hashCode;
}

/// A failed computation containing an error [message], optional [exception] and [stackTrace].
final class Failure<T> extends Result<T> {
  final String message;
  final Object? exception;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.exception, this.stackTrace]);

  @override
  String toString() =>
      'Failure(message: $message, exception: $exception, stackTrace: $stackTrace)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          other.message == message &&
          other.exception == exception;

  @override
  int get hashCode => Object.hash(message, exception);
}
