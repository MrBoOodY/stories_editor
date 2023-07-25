class RotateFfmpeg {
  final String videoVariable;
  final double? x, y, angle;
  final bool isImage;
  final String? nextEndName;
  RotateFfmpeg({
    required this.videoVariable,
    this.x,
    this.y,
    this.angle = 0,
    this.nextEndName,
    this.isImage = false,
  });
  String toFfmpeg() {
    return '''
rotate=$angle*PI/180:
${isImage ? 'ow=rotw(iw+60):oh=roth(ih+60):' : ''}
c=black@0[rotate];
    [$videoVariable][rotate]overlay=${x == null ? '' : 'x=$x:'}${y == null ? '' : 'y=$y:'}shortest=1${nextEndName != null ? '[$nextEndName],' : ''}
        ''';
  }
}
