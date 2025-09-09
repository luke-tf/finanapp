import 'dart:async';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // This is a simple test configuration file
  // It will run before any test and can setup global test settings
  return testMain();
}
