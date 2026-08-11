import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/golden_tolerance.dart';

class CanvasGoldenComparator extends LocalFileComparator {
  CanvasGoldenComparator() : super(Uri.parse('test/golden_test.dart'));
  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    // Linux/Chrome Canvas text rasterization differs slightly from the local VM.
    // Keep the bound tight enough to catch layout changes while allowing the
    // measured Linux/VM platform noise (observed CI maximum: 3.63%).
    if (acceptsCanvasGoldenDiff(
      exactMatch: result.passed,
      diffPercent: result.diffPercent,
    )) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  goldenFileComparator = CanvasGoldenComparator();
  await testMain();
}
