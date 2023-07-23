// ignore_for_file: must_be_immutable

import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:reels_editor/src/domain/models/editable_items.dart';
import 'package:reels_editor/src/domain/models/painting_model.dart';
import 'package:reels_editor/src/domain/providers/notifiers/audio_provider.dart';
import 'package:reels_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:reels_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:reels_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:reels_editor/src/presentation/bar_tools/top_tools.dart';
import 'package:reels_editor/src/presentation/draggable_items/delete_item.dart';
import 'package:reels_editor/src/presentation/draggable_items/draggable_widget.dart';
import 'package:reels_editor/src/presentation/painting_view/painting.dart';
import 'package:reels_editor/src/presentation/painting_view/widgets/sketcher.dart';
import 'package:reels_editor/src/presentation/text_editor_view/TextEditor.dart';
import 'package:reels_editor/src/presentation/utils/constants/app_enums.dart';
import 'package:reels_editor/src/presentation/utils/constants/filter_constants.dart';
import 'package:reels_editor/src/presentation/utils/modal_sheets.dart';
import 'package:reels_editor/src/presentation/widgets/tool_button.dart';
import 'package:video_editor/video_editor.dart';

class MainView extends StatefulWidget {
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

  /// editor background color
  Color? editorBackgroundColor;

  /// Editor Type is the reel will be text or image or video?
  final EditorType editorType;

  /// editor custom color palette list
  List<Color>? colorList;

  /// File to edit on it
  final File? file;
  MainView({
    Key? key,
    required this.giphyKey,
    required this.onDone,
    this.middleBottomWidget,
    this.colorList,
    this.isCustomFontList,
    this.fontFamilyList,
    this.gradientColors,
    this.onBackPress,
    this.onDoneButtonStyle,
    this.editorBackgroundColor,
    this.file,
    required this.editorType,
  })  : assert((editorType == EditorType.text && file == null) ||
            (editorType != EditorType.text && file != null)),
        super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  /// content container key
  final GlobalKey contentKey = GlobalKey();

  ///Editable item
  EditableItem? _activeItem;

  /// Gesture Detector listen changes
  Offset _initPos = const Offset(0, 0);
  Offset _currentPos = const Offset(0, 0);
  double _currentScale = 1;
  double _currentRotation = 0;

  /// delete position
  bool _isDeletePosition = false;
  bool _inAction = false;
  late final VideoEditorController _videoEditorController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var _control = Provider.of<ControlNotifier>(context, listen: false);

      /// initialize control variable provider
      _control.giphyKey = widget.giphyKey;
      _control.editorType = widget.editorType;
      _control.middleBottomWidget = widget.middleBottomWidget;
      _control.isCustomFontList = widget.isCustomFontList ?? false;
      if (widget.gradientColors != null) {
        _control.gradientColors = widget.gradientColors;
      }
      if (widget.fontFamilyList != null) {
        _control.fontList = widget.fontFamilyList;
      }
      if (widget.colorList != null) {
        _control.colorList = widget.colorList;
      }
    });
    if (Platform.isAndroid && widget.editorType != EditorType.text) {
      FFmpegKitConfig.setFontDirectory('/system/fonts');
    }
    super.initState();
    if (widget.editorType == EditorType.video && widget.file != null) {
      _videoEditorController = VideoEditorController.file(
        widget.file!,
        minDuration: const Duration(seconds: 1),
        maxDuration: const Duration(seconds: 40),
      )
        ..initialize(aspectRatio: 9 / 16)
        ..video.play().then((_) => setState(() {})).catchError((error) {
          log(error.toString());
          // handle minimum duration bigger than video duration error
          Navigator.pop(context);
        }, test: (e) => e is VideoMinDurationError);
    }
  }

  @override
  void dispose() {
    _videoEditorController.dispose();
    _videoEditorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screenUtil = ScreenUtil();
    return WillPopScope(
      onWillPop: _popScope,
      child: Material(
        color: widget.editorBackgroundColor == Colors.transparent
            ? Colors.black
            : widget.editorBackgroundColor ?? Colors.black,
        child: Consumer<ControlNotifier>(
          builder: (context, controlNotifier, child) {
            return SafeArea(
              //top: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onScaleStart: _onScaleStart,
                    onScaleUpdate: _onScaleUpdate,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: SizedBox(
                          width: screenUtil.screenWidth,
                          child: RepaintBoundary(
                            key: contentKey,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                gradient: controlNotifier.editorType ==
                                        EditorType.text
                                    ? LinearGradient(
                                        colors: controlNotifier.gradientColors![
                                            controlNotifier.gradientIndex],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                              ),
                              child: GestureDetector(
                                onScaleStart: _onScaleStart,
                                onScaleUpdate: _onScaleUpdate,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    /// Video Widget if Set
                                    if (widget.editorType == EditorType.video)
                                      ColorFiltered(
                                        colorFilter: ColorFilter.matrix(
                                          FilterConstants.filters[
                                              controlNotifier.filterIndex],
                                        ),
                                        child: IgnorePointer(
                                          ignoring: true,
                                          child: CropGridViewer.preview(
                                            controller: _videoEditorController,
                                          ),
                                        ),
                                      ),

                                    /// in this case photo view works as a main background container to manage
                                    /// the gestures of all movable items.
                                    PhotoView.customChild(
                                      child: const SizedBox(
                                        height: double.infinity,
                                        width: double.infinity,
                                      ),
                                      backgroundDecoration: const BoxDecoration(
                                          color: Colors.transparent),
                                    ),

                                    Consumer<DraggableWidgetNotifier>(builder:
                                        (context, itemProvider, child) {
                                      ///list items
                                      return AspectRatio(
                                        aspectRatio: _videoEditorController
                                            .video.value.aspectRatio,
                                        child: Stack(
                                          children: [
                                            ...itemProvider.draggableWidget
                                                .map((editableItem) {
                                              return DraggableWidget(
                                                context: context,
                                                draggableWidget: editableItem,
                                                onPointerDown: (details) {
                                                  _updateItemPosition(
                                                    editableItem,
                                                    details,
                                                  );
                                                },
                                                onPointerUp: (details) {
                                                  _deleteItemOnCoordinates(
                                                    editableItem,
                                                    details,
                                                  );
                                                },
                                                onPointerMove: (details) {
                                                  _deletePosition(
                                                    editableItem,
                                                    details,
                                                  );
                                                },
                                              );
                                            }),
                                          ],
                                        ),
                                      );
                                    }),

                                    /// finger paint
                                    Consumer<PaintingNotifier>(builder:
                                        (context, paintingProvider, _) {
                                      return IgnorePointer(
                                        ignoring: true,
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: RepaintBoundary(
                                              child: SizedBox(
                                                width: screenUtil.screenWidth,
                                                child: StreamBuilder<
                                                    List<PaintingModel>>(
                                                  stream: paintingProvider
                                                      .linesStreamController
                                                      .stream,
                                                  builder: (context, snapshot) {
                                                    return CustomPaint(
                                                      painter: Sketcher(
                                                        lines: paintingProvider
                                                            .lines,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// top tools
                  Visibility(
                    visible: !controlNotifier.isTextEditing &&
                        !controlNotifier.isPainting &&
                        !controlNotifier.isEffecting &&
                        !controlNotifier.isManagingAudio &&
                        !controlNotifier.isTrimming,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.topStart,
                          child:

                              /// close button
                              ToolButton(
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  backGroundColor: Colors.black12,
                                  onTap: () async {
                                    var res = await exitDialog(
                                        context: context,
                                        contentKey: contentKey);
                                    if (res) {
                                      Navigator.pop(context);
                                    }
                                  }),
                        ),
                        Align(
                            alignment: AlignmentDirectional.topEnd,
                            child: TopTools(
                              contentKey: contentKey,
                              context: context,
                            )),
                      ],
                    ),
                  ),

                  /// trim event
                  Visibility(
                    visible: controlNotifier.isTrimming,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      Colors.black.withOpacity(0.5),
                                ),
                                onPressed: () {
                                  controlNotifier.isTrimming = false;
                                  _videoEditorController.updateTrim(
                                      controlNotifier.trimStart,
                                      controlNotifier.trimEnd >
                                              _videoEditorController.maxTrim
                                          ? _videoEditorController.maxTrim
                                          : controlNotifier.trimEnd);
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      Colors.black.withOpacity(0.5),
                                ),
                                onPressed: () {
                                  controlNotifier.isTrimming = false;
                                  controlNotifier.trimStart =
                                      _videoEditorController.minTrim;
                                  controlNotifier.trimEnd =
                                      _videoEditorController.maxTrim;
                                },
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin:
                                const EdgeInsets.symmetric(vertical: 60 / 4),
                            child: TrimSlider(
                              controller: _videoEditorController,
                              height: 60,
                              horizontalMargin: 60 / 4,
                              child: TrimTimeline(
                                controller: _videoEditorController,
                                padding: const EdgeInsets.only(top: 10),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  /// effect event
                  Visibility(
                    visible: controlNotifier.isEffecting,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      Colors.black.withOpacity(0.5),
                                ),
                                onPressed: () {
                                  controlNotifier.isEffecting = false;
                                },
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: FilterConstants.filterTitle.length,
                              padding: const EdgeInsets.all(10),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 10),
                              itemBuilder: ((context, index) {
                                return GestureDetector(
                                  onTap: (() {
                                    controlNotifier.filterIndex = index;
                                  }),
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.matrix(
                                        FilterConstants.filters[index]),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          controlNotifier.filterIndex == index
                                              ? Colors.white
                                              : Colors.transparent,
                                      radius: 40,
                                      child: CircleAvatar(
                                        backgroundColor: index == 0
                                            ? Colors.grey
                                            : Colors.transparent,
                                        radius: 37,
                                        child: index == 0
                                            ? const Icon(
                                                Icons.block,
                                                size: 37,
                                                color: Colors.white,
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(37),
                                                child: const Image(
                                                  image: AssetImage(
                                                      'assets/images/filter_sample.jpeg',
                                                      package: 'reels_editor'),
                                                  fit: BoxFit.cover,
                                                  height: double.infinity,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// audio event
                  Visibility(
                    visible: controlNotifier.isManagingAudio,
                    child: Consumer<AudioNotifier>(
                        builder: (context, audioProvider, _) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      Colors.black.withOpacity(0.5),
                                ),
                                onPressed: () {
                                  controlNotifier.isManagingAudio = false;
                                  audioProvider.cancelEditing(
                                    currentPosition: Duration(
                                      seconds: _videoEditorController
                                              .endTrim.inSeconds -
                                          _videoEditorController
                                              .videoPosition.inSeconds,
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      Colors.black.withOpacity(0.5),
                                ),
                                onPressed: () {
                                  controlNotifier.isManagingAudio = false;
                                  audioProvider.submit();
                                  _videoEditorController.video.setVolume(
                                      audioProvider.actualAudioVolume);
                                },
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Text(
                                  'Mix you audio',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Divider(
                                  height: 20,
                                  color: Colors.grey[500],
                                ),

                                /// Video volume slider
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        audioProvider.virtualVideoVolume =
                                            audioProvider.virtualVideoVolume !=
                                                    0.0
                                                ? 0.0
                                                : 1.0;
                                        _videoEditorController.video.setVolume(
                                            audioProvider.virtualVideoVolume);
                                      },
                                      padding: EdgeInsets.zero,
                                      icon: CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.grey[600],
                                        child: Icon(
                                          audioProvider.virtualVideoVolume !=
                                                  0.0
                                              ? Icons.volume_up_rounded
                                              : Icons.volume_off_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: audioProvider.virtualVideoVolume,
                                        onChanged: (value) {
                                          audioProvider.virtualVideoVolume =
                                              value;
                                          _videoEditorController.video
                                              .setVolume(value);
                                        },
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        audioProvider.virtualVideoVolume =
                                            audioProvider.virtualVideoVolume !=
                                                    0.0
                                                ? 0.0
                                                : 1.0;
                                        _videoEditorController.video.setVolume(
                                            audioProvider.virtualVideoVolume);
                                      },
                                      child: Text(
                                          audioProvider.virtualVideoVolume !=
                                                  0.0
                                              ? 'Mute'
                                              : 'Un Mute'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                if (audioProvider.virtualSelectedAudio != null)

                                  ///Audio volume Slider
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'External Audio',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              audioProvider.virtualAudioVolume =
                                                  audioProvider
                                                              .virtualAudioVolume !=
                                                          0.0
                                                      ? 0.0
                                                      : 1.0;
                                            },
                                            padding: EdgeInsets.zero,
                                            icon: CircleAvatar(
                                              radius: 40,
                                              backgroundColor: Colors.grey[600],
                                              child: Icon(
                                                audioProvider
                                                            .virtualAudioVolume !=
                                                        0.0
                                                    ? Icons.volume_up_rounded
                                                    : Icons.volume_off_rounded,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Slider(
                                              value: audioProvider
                                                  .virtualAudioVolume,
                                              onChanged: (value) {
                                                audioProvider
                                                    .virtualAudioVolume = value;
                                              },
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              audioProvider
                                                  .virtualSelectedAudio = null;
                                            },
                                            child: const Text('Remove'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                else
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      fixedSize: Size(
                                        screenUtil.screenWidth,
                                        55,
                                      ),
                                    ),
                                    onPressed: () async {
                                      final success =
                                          await audioProvider.pickAudio(
                                        currentPosition:
                                            _videoEditorController.endTrim,
                                        maxDuration: _videoEditorController
                                                .endTrim.inSeconds -
                                            _videoEditorController
                                                .startTrim.inSeconds,
                                      );
                                      if (success) {
                                        controlNotifier.isManagingAudio = false;
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.music_note_rounded,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Add Audio',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),

                  /// delete item when the item is in position
                  DeleteItem(
                    activeItem: _activeItem,
                    animationsDuration: const Duration(milliseconds: 300),
                    isDeletePosition: _isDeletePosition,
                  ),

                  /// show text editor
                  Visibility(
                    visible: controlNotifier.isTextEditing,
                    child: TextEditor(
                      context: context,
                    ),
                  ),

                  /// show painting sketch
                  Visibility(
                    visible: controlNotifier.isPainting,
                    child: const Painting(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// validate pop scope gesture
  Future<bool> _popScope() async {
    final controlNotifier =
        Provider.of<ControlNotifier>(context, listen: false);

    /// change to false text editing
    if (controlNotifier.isTextEditing) {
      controlNotifier.isTextEditing = !controlNotifier.isTextEditing;
      return false;
    }

    /// change to false painting
    else if (controlNotifier.isPainting) {
      controlNotifier.isPainting = !controlNotifier.isPainting;
      return false;
    }

    /// show close dialog
    else if (!controlNotifier.isTextEditing && !controlNotifier.isPainting) {
      return widget.onBackPress ??
          exitDialog(context: context, contentKey: contentKey);
    }
    return false;
  }

  /// start item scale
  void _onScaleStart(ScaleStartDetails details) {
    if (_activeItem == null) {
      return;
    }
    _initPos = details.focalPoint;
    _currentPos = _activeItem!.position;
    _currentScale = _activeItem!.scale;
    _currentRotation = _activeItem!.rotation;
  }

  /// update item scale
  void _onScaleUpdate(ScaleUpdateDetails details) {
    final ScreenUtil screenUtil = ScreenUtil();
    if (_activeItem == null) {
      return;
    }
    final delta = details.focalPoint - _initPos;

    final left = (delta.dx / screenUtil.screenWidth) + _currentPos.dx;
    final top = (delta.dy / screenUtil.screenHeight) + _currentPos.dy;

    setState(() {
      _activeItem!.position = Offset(left, top);
      _activeItem!.rotation = details.rotation + _currentRotation;
      _activeItem!.scale = details.scale * _currentScale;
    });
  }

  /// active delete widget with offset position
  void _deletePosition(EditableItem item, PointerMoveEvent details) {
    if (item.type == ItemType.text &&
        item.position.dy >= 0.75.h &&
        item.position.dx >= -0.4.w &&
        item.position.dx <= 0.2.w) {
      setState(() {
        _isDeletePosition = true;
        item.deletePosition = true;
      });
    } else if (item.type == ItemType.gif &&
        item.position.dy >= 0.62.h &&
        item.position.dx >= -0.35.w &&
        item.position.dx <= 0.15) {
      setState(() {
        _isDeletePosition = true;
        item.deletePosition = true;
      });
    } else {
      setState(() {
        _isDeletePosition = false;
        item.deletePosition = false;
      });
    }
  }

  /// delete item widget with offset position
  void _deleteItemOnCoordinates(EditableItem item, PointerUpEvent details) {
    var _itemProvider =
        Provider.of<DraggableWidgetNotifier>(context, listen: false)
            .draggableWidget;
    _inAction = false;
    if (item.type == ItemType.image) {
    } else if (item.type == ItemType.text &&
            item.position.dy >= 0.75.h &&
            item.position.dx >= -0.4.w &&
            item.position.dx <= 0.2.w ||
        item.type == ItemType.gif &&
            item.position.dy >= 0.62.h &&
            item.position.dx >= -0.35.w &&
            item.position.dx <= 0.15) {
      setState(() {
        _itemProvider.removeAt(_itemProvider.indexOf(item));
        HapticFeedback.heavyImpact();
      });
    } else {
      setState(() {
        _activeItem = null;
      });
    }
    setState(() {
      _activeItem = null;
    });
  }

  /// update item position, scale, rotation
  void _updateItemPosition(EditableItem item, PointerDownEvent details) {
    if (_inAction) {
      return;
    }

    _inAction = true;
    _activeItem = item;
    _initPos = details.position;
    _currentPos = item.position;
    _currentScale = item.scale;
    _currentRotation = item.rotation;

    /// set vibrate
    HapticFeedback.lightImpact();
  }
}
