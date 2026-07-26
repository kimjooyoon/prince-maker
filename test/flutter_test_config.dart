import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class CanvasGoldenComparator extends LocalFileComparator {
  CanvasGoldenComparator() : super(Uri.parse('test/golden_test.dart'));
  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(imageBytes, await getGoldenBytes(golden));
    // Linux/Chrome Canvas text rasterization differs slightly from the local VM.
    // Keep the bound tight enough to catch layout changes while allowing that
    // deterministic platform noise (observed CI maximum: 1.48%).
    if (result.passed || result.diffPercent <= .02) {
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
