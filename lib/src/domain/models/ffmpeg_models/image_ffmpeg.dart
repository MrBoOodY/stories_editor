import 'package:reels_editor/src/domain/models/ffmpeg_models/ffmpeg_model.dart';
import 'package:reels_editor/src/domain/models/ffmpeg_models/rotate_ffmpeg.dart';

class ImageFfmpeg extends FfmpegModel {
  final double scale, x, y;
  final String? nextEndName;
  final String? imageVariable;
  final String videoVariable;
  final double rotationAngle;
  final bool isGIF;
  final String path;
  ImageFfmpeg({
    this.scale = 0,
    this.x = 0,
    this.y = 0,
    this.nextEndName,
    this.rotationAngle = 0,
    this.imageVariable,
    required this.videoVariable,
    required this.isGIF,
    required this.path,
  });

  @override
  String toFfmpeg() {
    return '''
        ${imageVariable == null ? '' : '[$imageVariable]'}scale=$scale:-1,
        ${RotateFfmpeg(
      angle: rotationAngle,
      videoVariable: videoVariable,
      nextEndName: nextEndName,
      x: x,
      y: y,
      isImage: true,
    ).toFfmpeg()}
        ''';
  }
}
