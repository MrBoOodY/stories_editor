import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> convertPaintToImage({
  required contentKey,
  required BuildContext context,
}) async {
  try {
    /// converter widget to image
    RenderRepaintBoundary boundary =
        contentKey.currentContext.findRenderObject();
    if (boundary.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 20));
    }
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    Uint8List pngBytes = byteData!.buffer.asUint8List();

    /// create file
    final String dir = (await getTemporaryDirectory()).path;
    String imagePath = '$dir/paint${DateTime.now()}.png';
    File capturedFile = File(imagePath);
    await capturedFile.writeAsBytes(pngBytes);

    return imagePath;
  } catch (e) {
    debugPrint('exception => $e');
    return null;
  }
}
