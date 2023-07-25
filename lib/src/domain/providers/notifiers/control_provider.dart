import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:reels_editor/src/domain/models/editable_items.dart';
import 'package:reels_editor/src/domain/models/ffmpeg_models/ffmpeg_model.dart';
import 'package:reels_editor/src/domain/models/ffmpeg_models/image_ffmpeg.dart';
import 'package:reels_editor/src/domain/models/ffmpeg_models/text_ffmpeg.dart';
import 'package:reels_editor/src/domain/providers/notifiers/audio_provider.dart';
import 'package:reels_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:reels_editor/src/domain/sevices/convert_paint_to_image.dart';
import 'package:reels_editor/src/domain/sevices/download_gif.dart';
import 'package:reels_editor/src/domain/sevices/export_service.dart';
import 'package:reels_editor/src/presentation/utils/constants/app_colors.dart';
import 'package:reels_editor/src/presentation/utils/constants/app_enums.dart';
import 'package:reels_editor/src/presentation/utils/constants/filter_constants.dart';
import 'package:reels_editor/src/presentation/utils/constants/font_family.dart';
import 'package:video_editor/video_editor.dart';

class ControlNotifier extends ChangeNotifier {
  String _giphyKey = '';

  /// is required add your giphy API KEY
  String get giphyKey => _giphyKey;
  set giphyKey(String key) {
    _giphyKey = key;
    notifyListeners();
  }

  bool _isFfmpegInProgress = false;

  /// is required add your giphy API KEY
  bool get isFfmpegInProgress => _isFfmpegInProgress;
  set isFfmpegInProgress(bool key) {
    _isFfmpegInProgress = key;
    notifyListeners();
  }

  EditorType _editorType = EditorType.video;

  /// is required add editor type
  EditorType get editorType => _editorType;
  set editorType(EditorType key) {
    _editorType = key;
    notifyListeners();
  }

  int _filterIndex = 0;

  /// current filter index
  int get filterIndex => _filterIndex;
  set filterIndex(int index) {
    _filterIndex = index;
    notifyListeners();
  }

  int _gradientIndex = 0;

  /// current gradient index
  int get gradientIndex => _gradientIndex;

  /// get current gradient index
  set gradientIndex(int index) {
    /// set new current gradient index
    _gradientIndex = index;
    notifyListeners();
  }

  bool _isTextEditing = false;

  /// is text editor open
  bool get isTextEditing => _isTextEditing;

  /// get bool if is text editing
  set isTextEditing(bool val) {
    /// set bool if is text editing
    _isTextEditing = val;
    notifyListeners();
  }

  bool _isTrimming = false;

  /// is editor trimming
  bool get isTrimming => _isTrimming;

  set isTrimming(bool val) {
    _isTrimming = val;
    notifyListeners();
  }

  double _trimStart = 0.0;

  /// get trim start position
  double get trimStart => _trimStart;

  /// set trim start position
  set trimStart(double val) {
    _trimStart = val;
    notifyListeners();
  }

  double _trimEnd = 40.0;

  /// get trim end position
  double get trimEnd => _trimEnd;

  /// set trim end position
  set trimEnd(double val) {
    _trimEnd = val;
    notifyListeners();
  }

  bool _isEffecting = false;

  /// is effect options opened
  bool get isEffecting => _isEffecting;
  set isEffecting(bool isEffecting) {
    _isEffecting = isEffecting;
    notifyListeners();
  }

  bool _isManagingAudio = false;

  /// is audio options opened
  bool get isManagingAudio => _isManagingAudio;
  set isManagingAudio(bool isManagingAudio) {
    _isManagingAudio = isManagingAudio;
    notifyListeners();
  }

  bool _isPainting = false;

  /// is painter sketcher open
  bool get isPainting => _isPainting;
  set isPainting(bool painting) {
    _isPainting = painting;
    notifyListeners();
  }

  List<String>? _fontList = AppFonts.fontFamilyList;

  /// here you can define your own font family list
  List<String>? get fontList => _fontList;
  set fontList(List<String>? fonts) {
    _fontList = fonts;
    notifyListeners();
  }

  bool _isCustomFontList = false;

  /// if you add your custom list is required to specify your app package
  bool get isCustomFontList => _isCustomFontList;
  set isCustomFontList(bool key) {
    _isCustomFontList = key;
    notifyListeners();
  }

  List<List<Color>>? _gradientColors = AppColors.gradientBackgroundColors;

  /// here you can define your own background gradients
  List<List<Color>>? get gradientColors => _gradientColors;
  set gradientColors(List<List<Color>>? color) {
    _gradientColors = color;
    notifyListeners();
  }

  Widget? _middleBottomWidget;

  /// you can add a custom widget on the bottom
  Widget? get middleBottomWidget => _middleBottomWidget;
  set middleBottomWidget(Widget? widget) {
    _middleBottomWidget = widget;
    notifyListeners();
  }

  Future<bool>? _exitDialogWidget;

  /// you can create you own exit window
  Future<bool>? get exitDialogWidget => _exitDialogWidget;
  set exitDialogWidget(Future<bool>? widget) {
    _exitDialogWidget = widget;
    notifyListeners();
  }

  List<Color>? _colorList = AppColors.defaultColors;

  /// you can add your own color palette list
  List<Color>? get colorList => _colorList;
  set colorList(List<Color>? value) {
    _colorList = value;
    notifyListeners();
  }

  /// get image path
  String _mediaPath = '';
  String get mediaPath => _mediaPath;
  set mediaPath(String media) {
    _mediaPath = media;
    notifyListeners();
  }

  bool _isPhotoFilter = false;
  bool get isPhotoFilter => _isPhotoFilter;
  set isPhotoFilter(bool filter) {
    _isPhotoFilter = filter;
    notifyListeners();
  }

  shareFile({
    required BuildContext context,
    required EditorType editorType,
    required paintKey,
    required VideoEditorController? controller,
  }) async {
    final draggableWidgets =
        Provider.of<DraggableWidgetNotifier>(context, listen: false)
            .draggableWidget;
    if (paintKey != null) {
      final path =
          await convertPaintToImage(contentKey: paintKey, context: context);
      if (path != null) {
        draggableWidgets.add(
          EditableItem()
            ..text = path
            ..type = ItemType.image,
        );
      }
    }
    final audioPath =
        Provider.of<AudioNotifier>(context, listen: false).actualSelectedAudio;
    final List<FfmpegModel> ffmpegList =
        await _getFfmpegList(draggableWidgets, editorType);

    /// images and gif inputs
    final String mediaInputs = ffmpegList
        .whereType<ImageFfmpeg>()
        .map((e) =>
            (e.isGIF ? '-ignore_loop 0' : '-loop 1') + ' -i \'${e.path}\' ')
        .join();

    /// audio input if exist
    final String audioInput = audioPath != null ? '-i "$audioPath" ' : '';
    if (controller != null) {
      final config = VideoFFmpegVideoEditorConfig(
        controller,
        // format: VideoExportFormat.gif,
        commandBuilder: (config, videoPath, outputPath) {
          String startTrimCmd = "-ss ${controller.startTrim}";
          String toTrimCmd = "-t ${controller.trimmedDuration}";

          final List<String> filters = config.getExportFilters();
          final String startVideEditorFilter =
              '${(filters.isEmpty ? '' : '[0]') + _filtersCmd(filters)}${filters.isEmpty ? '' : '[v];'}';
          final String? effectColor =
              FilterConstants.filters[filterIndex].join(':');
          final String colorChannelFilter = effectColor == null
              ? ''
              : (filters.isEmpty ? '[0]' : '[v]') +
                  'colorchannelmixer=$effectColor[v];';
          final splitLength =
              ffmpegList.whereType<TextFfmpeg>().toList().length;
          final splitFilter = splitLength == 0
              ? ''
              : 'split=$splitLength${List.generate(splitLength, (index) => '[t$index]').join('')};';
          final ffmpegFilterList = ffmpegList.map((e) => e.toFfmpeg()).join('');
          final finalFilters = '''
-filter_complex "
        $startVideEditorFilter
$colorChannelFilter
        color=black[c];
        [c][v]scale2ref[t][v];
        [t]setsar=1,
        colorkey=black,
        $splitFilter
        $ffmpegFilterList
        "''';
          return '-i $videoPath $mediaInputs $audioInput $finalFilters $startTrimCmd $toTrimCmd -preset ultrafast -y $outputPath';
        },
      );
      _exportByFfmpeg(config, context);
    }
  }

  Future<void> _exportByFfmpeg(
      VideoFFmpegVideoEditorConfig config, BuildContext context) async {
    await ExportService.runFFmpegCommand(
      await config.getExecuteConfig(),
      onProgress: (stats) {
        isFfmpegInProgress = true;
      },
      onError: (e, s) {
        log(e.toString());
        Fluttertoast.showToast(
          msg: "Error on export video :(",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        isFfmpegInProgress = false;
      },
      onCompleted: (file) async {
        ExportService.dispose();
        isFfmpegInProgress = false;

        Navigator.pop(context, file.path);
      },
    );
  }

  /// Returns the `-filter:v` (-vf alias) command to use in FFmpeg execution
  String _filtersCmd(List<String> filters) {
    filters.removeWhere((item) => item.isEmpty);
    return filters.isNotEmpty ? filters.join(',') : '';
  }

  Future<List<FfmpegModel>> _getFfmpegList(
      List<EditableItem> draggableWidget, EditorType editorType) async {
    final List<FfmpegModel> ffmpegList = [];
    for (int i = 0; i < draggableWidget.length; i++) {
      final item = draggableWidget[i];
      final String? nextEndNumber =
          i + 1 == draggableWidget.length ? null : 'v';
      switch (item.type) {
        case ItemType.gif:
        case ItemType.image:
          final images = ffmpegList.whereType<ImageFfmpeg>().toList();
          final isGif = item.type == ItemType.gif;
          final path = !isGif
              ? item.text
              : await downloadGIF(id: item.gif.id, url: item.gif.url ?? '');
          if (path == null) {
            break;
          }
          ffmpegList.add(
            ImageFfmpeg(
              path: path,
              isGIF: isGif,
              videoVariable: 'v',
              scale: item.scale,
              imageVariable: '${images.length + 1}:v',
              nextEndName: nextEndNumber,
              rotationAngle: item.rotation,
              x: item.position.dx,
              y: item.position.dy,
            ),
          );
          break;
        case ItemType.text:
          final texts = ffmpegList.whereType<TextFfmpeg>().toList();

          ffmpegList.add(
            TextFfmpeg(
              text: item.text,
              videoVariable: 'v',
              backgroundColor: item.backGroundColor,
              backgroundWidth: 20,
              fontColor: item.textColor,
              fontSize: item.fontSize,
              splitVariable: 't${texts.length + 1}',
              nextEndName: nextEndNumber,
              rotationAngle: item.rotation,
              x: item.position.dx,
              y: item.position.dy,
            ),
          );
          break;
        default:
          break;
      }
    }
    return ffmpegList;
  }
}
