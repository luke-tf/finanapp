import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Initialize golden toolkit for consistent golden tests
  return GoldenToolkit.runWithConfiguration(
    () async {
      // Setup test environment
      TestWidgetsFlutterBinding.ensureInitialized();

      // Initialize Hive for testing (in-memory)
      await Hive.initFlutter();

      // Load test fonts for consistent rendering
      await loadAppFonts();

      return testMain();
    },
    config: GoldenToolkitConfiguration(
      skipGoldenAssertion: () => !isCI(), // Skip in CI if needed
      defaultDevices: const [Device.phone, Device.tabletPortrait],
    ),
  );
}

bool isCI() => const bool.fromEnvironment('CI', defaultValue: false);
