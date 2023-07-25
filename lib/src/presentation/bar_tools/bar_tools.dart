import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:reels_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:reels_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:reels_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:reels_editor/src/presentation/utils/constants/app_enums.dart';
import 'package:reels_editor/src/presentation/utils/modal_sheets.dart';
import 'package:reels_editor/src/presentation/widgets/animated_onTap_button.dart';
import 'package:reels_editor/src/presentation/widgets/bar_button.dart';

class BarTools extends StatefulWidget {
  final GlobalKey contentKey;
  final BuildContext context;
  const BarTools({Key? key, required this.contentKey, required this.context})
      : super(key: key);

  @override
  _BarToolsState createState() => _BarToolsState();
}

class _BarToolsState extends State<BarTools> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<ControlNotifier, PaintingNotifier,
        DraggableWidgetNotifier>(
      builder: (_, controlNotifier, paintingNotifier, itemNotifier, __) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.w),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (controlNotifier.editorType == EditorType.text)
                  _selectColor(
                      controlProvider: controlNotifier,
                      onTap: () {
                        if (controlNotifier.gradientIndex >=
                            controlNotifier.gradientColors!.length - 1) {
                          setState(() {
                            controlNotifier.gradientIndex = 0;
                          });
                        } else {
                          setState(() {
                            controlNotifier.gradientIndex += 1;
                          });
                        }
                      }),
                /*   ToolButton(
                    child: const ImageIcon(
                      AssetImage('assets/icons/download.png',
                          package: 'reels_editor'),
                      color: Colors.white,
                      size: 20,
                    ),
                    backGroundColor: Colors.black12,
                    onTap: () async {
                      if (paintingNotifier.lines.isNotEmpty ||
                          itemNotifier.draggableWidget.isNotEmpty) {
                        await takePicture(
                            contentKey: widget.contentKey,
                            context: context,
                            saveToGallery: true);
                      }
                    }), */
                BarButton(
                    child: const ImageIcon(
                      AssetImage('assets/icons/stickers.png',
                          package: 'reels_editor'),
                      color: Colors.white,
                      size: 20,
                    ),
                    backGroundColor: Colors.black12,
                    onTap: () => createGiphyItem(
                        context: context, giphyKey: controlNotifier.giphyKey)),
                BarButton(
                    child: const ImageIcon(
                      AssetImage('assets/icons/draw.png',
                          package: 'reels_editor'),
                      color: Colors.white,
                      size: 20,
                    ),
                    backGroundColor: Colors.black12,
                    onTap: () {
                      controlNotifier.isPainting = true;
                      //createLinePainting(context: context);
                    }),
                BarButton(
                  child: ImageIcon(
                    const AssetImage('assets/icons/photo_filter.png',
                        package: 'reels_editor'),
                    color: controlNotifier.isPhotoFilter
                        ? Colors.black
                        : Colors.white,
                    size: 20,
                  ),
                  backGroundColor: controlNotifier.isPhotoFilter
                      ? Colors.white70
                      : Colors.black12,
                  onTap: () => controlNotifier.isEffecting =
                      !controlNotifier.isEffecting,
                ),
                BarButton(
                  child: const ImageIcon(
                    AssetImage('assets/icons/text.png',
                        package: 'reels_editor'),
                    color: Colors.white,
                    size: 20,
                  ),
                  backGroundColor: Colors.black12,
                  onTap: () => controlNotifier.isTextEditing =
                      !controlNotifier.isTextEditing,
                ),
                BarButton(
                  child: const Icon(
                    Icons.content_cut,
                    color: Colors.white,
                    size: 20,
                  ),
                  backGroundColor: Colors.black12,
                  onTap: () => controlNotifier.isTrimming = true,
                ),
                BarButton(
                  child: const Icon(
                    Icons.volume_down_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  backGroundColor: Colors.black12,
                  onTap: () => controlNotifier.isManagingAudio = true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// gradient color selector
  Widget _selectColor({onTap, controlProvider}) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 8),
      child: AnimatedOnTapButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: controlProvider
                      .gradientColors![controlProvider.gradientIndex]),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
