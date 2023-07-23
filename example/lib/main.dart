import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:reels_editor/reels_editor.dart';
import 'package:reels_editor/src/presentation/utils/constants/app_enums.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter stories editor Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Example(),
    );
  }
}

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform
                .pickFiles(allowMultiple: false, type: FileType.video);

            if (result?.files.single.path != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StoriesEditor(
                            giphyKey: 'C4dMA7Q19nqEGdpfj82T8ssbOeZIylD4',
                            editorType: EditorType.video,
                            file: File(result!.files.single.path!),
                            onDone: (uri) {
                              log(uri);
                              Share.shareFiles([uri]);
                            },
                          )));
            }
          },
          child: const Text('Open Stories Editor'),
        ),
      ),
    );
  }
}
