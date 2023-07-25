import 'package:reels_editor/src/domain/models/ffmpeg_models/ffmpeg_model.dart';

class AudioFfmpeg extends FfmpegModel {
  final double videoVolume;
  final double audioVolume;
  final String audioVariable;

  AudioFfmpeg({
    required this.videoVolume,
    required this.audioVolume,
    required this.audioVariable,
  });
  @override
  String toFfmpeg() {
    return '''
[0:a]volume=$videoVolume[a0];
         [$audioVariable]volume=$audioVolume[a1];
         [a0][a1]amerge
         ''';
  }
}
