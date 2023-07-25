import 'package:flutter/material.dart';
import 'package:reels_editor/src/domain/models/ffmpeg_models/ffmpeg_model.dart';
import 'package:reels_editor/src/domain/models/ffmpeg_models/rotate_ffmpeg.dart';
import 'package:reels_editor/src/presentation/utils/Extensions/hexColor.dart';

class TextFfmpeg extends FfmpegModel {
  final String text;
  final double? fontSize;
  final double x;
  final double y;
  final Color? backgroundColor;
  final Color? fontColor;
  final double? backgroundWidth;
  final double rotationAngle;
  final String? nextEndName;
  final String? splitVariable;
  final String videoVariable;
  TextFfmpeg({
    required this.text,
    this.fontSize,
    this.x = 0,
    this.y = 0,
    this.backgroundColor,
    this.fontColor,
    this.backgroundWidth,
    this.rotationAngle = 0,
    required this.videoVariable,
    this.splitVariable,
    this.nextEndName,
  });

  @override
  String toFfmpeg() {
    return '''
        ${splitVariable != null ? '[$splitVariable]' : ''}drawtext=
        text=$text
        ${fontSize != null ? ':fontsize=$fontSize' : ''}
        :box=${backgroundColor != null ? 1 : 0}
        :y=$y
        :x=$x
        ${backgroundWidth != null ? ':boxborderw=$backgroundWidth' : ''}
        ${backgroundColor != null ? ':boxcolor=${backgroundColor!.toHex()}' : ''}
        ${fontColor != null ? ':fontcolor=${fontColor!.toHex()}' : ''},
        ${RotateFfmpeg(
      angle: rotationAngle,
      videoVariable: videoVariable,
      nextEndName: nextEndName,
    ).toFfmpeg()}
        ''';
  }
}
