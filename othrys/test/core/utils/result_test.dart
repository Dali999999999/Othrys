import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/utils/result.dart';

void main() {
  group('Result<T>', () {
    test('Success.fold executes onSuccess callback', () {
      const result = Success<int>(42);
      final value = result.fold(
        onSuccess: (data) => data * 2,
        onFailure: (msg, e, st) => -1,
      );
      expect(value, 84);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });

    test('Failure.fold executes onFailure callback', () {
      const result = Failure<int>('Network error');
      final value = result.fold(
        onSuccess: (data) => data * 2,
        onFailure: (msg, e, st) => msg,
      );
      expect(value, 'Network error');
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
    });

    test('map transforms Success value and preserves Failure', () {
      const success = Success<int>(10);
      final mappedSuccess = success.map((d) => 'Number: $d');
      expect(mappedSuccess, isA<Success<String>>());
      expect((mappedSuccess as Success<String>).data, 'Number: 10');

      const failure = Failure<int>('Disk full');
      final mappedFailure = failure.map((d) => 'Number: $d');
      expect(mappedFailure, isA<Failure<String>>());
      expect((mappedFailure as Failure<String>).message, 'Disk full');
    });

    test('getOrElse returns value for Success and fallback for Failure', () {
      const success = Success<String>('hello');
      expect(success.getOrElse(() => 'default'), 'hello');

      const failure = Failure<String>('error');
      expect(failure.getOrElse(() => 'default'), 'default');
    });

    test('getOrThrow returns value for Success and throws for Failure', () {
      const success = Success<int>(100);
      expect(success.getOrThrow(), 100);

      const failureWithoutEx = Failure<int>('Not found');
      expect(() => failureWithoutEx.getOrThrow(), throwsA(isA<StateError>()));

      final formatEx = const FormatException('Bad format');
      final failureWithEx = Failure<int>('Parsing error', formatEx);
      expect(() => failureWithEx.getOrThrow(), throwsA(isA<FormatException>()));
    });
  });
}
