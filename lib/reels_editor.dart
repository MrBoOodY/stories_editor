// ignore_for_file: must_be_immutable
library reels_editor;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:reels_editor/src/domain/providers/notifiers/audio_provider.dart';
import 'package:reels_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:reels_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:reels_editor/src/domain/providers/notifiers/gradient_notifier.dart';
import 'package:reels_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:reels_editor/src/domain/providers/notifiers/scroll_notifier.dart';
import 'package:reels_editor/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:reels_editor/src/presentation/main_view/main_view.dart';
import 'package:reels_editor/src/presentation/utils/constants/app_enums.dart';

export 'package:reels_editor/reels_editor.dart';
export 'package:reels_editor/src/presentation/utils/constants/app_enums.dart'
    show EditorType;

class StoriesEditor extends StatefulWidget {
  /// editor custom font families
  final List<String>? fontFamilyList;

  /// editor custom font families package
  final bool? isCustomFontList;

  /// giphy api key
  final String giphyKey;

  /// editor custom color gradients
  final List<List<Color>>? gradientColors;

  /// editor custom logo
  final Widget? middleBottomWidget;

  /// on done
  final Function(String)? onDone;

  /// on done button Text
  final Widget? onDoneButtonStyle;

  /// on back pressed
  final Future<bool>? onBackPress;

  /// editor custom color palette list
  final List<Color>? colorList;

  /// editor background color
  final Color? editorBackgroundColor;

  /// Editor Type is the reel will be text or image or video?
  final EditorType editorType;

  /// File to edit on it
  final File? file;

  const StoriesEditor({
    Key? key,
    required this.giphyKey,
    required this.onDone,
    this.middleBottomWidget,
    this.colorList,
    this.gradientColors,
    this.fontFamilyList,
    this.isCustomFontList,
    this.onBackPress,
    this.onDoneButtonStyle,
    this.editorBackgroundColor,
    this.file,
    required this.editorType,
  }) : super(key: key);

  @override
  _StoriesEditorState createState() => _StoriesEditorState();
}

class _StoriesEditorState extends State<StoriesEditor> {
  @override
  void initState() {
    Paint.enableDithering = true;
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return false;
      },
      child: ScreenUtilInit(
        designSize: const Size(1080, 1920),
        builder: (_, __) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ControlNotifier()),
            ChangeNotifierProvider(create: (_) => ScrollNotifier()),
            ChangeNotifierProvider(create: (_) => DraggableWidgetNotifier()),
            ChangeNotifierProvider(create: (_) => GradientNotifier()),
            ChangeNotifierProvider(create: (_) => PaintingNotifier()),
            ChangeNotifierProvider(create: (_) => TextEditingNotifier()),
            ChangeNotifierProvider(create: (_) => AudioNotifier()),
          ],
          child: MainView(
            giphyKey: widget.giphyKey,
            onDone: widget.onDone,
            fontFamilyList: widget.fontFamilyList,
            isCustomFontList: widget.isCustomFontList,
            middleBottomWidget: widget.middleBottomWidget,
            gradientColors: widget.gradientColors,
            colorList: widget.colorList,
            onDoneButtonStyle: widget.onDoneButtonStyle,
            onBackPress: widget.onBackPress,
            editorBackgroundColor: widget.editorBackgroundColor,
            editorType: widget.editorType,
            file: widget.file,
          ),
        ),
      ),
    );
  }
}
