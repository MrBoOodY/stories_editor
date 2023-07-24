import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioNotifier extends ChangeNotifier {
  final player = AudioPlayer();
  final record = Record();

  double _actualVideoVolume = 1.0;

  /// actual video volume
  double get actualVideoVolume => _actualVideoVolume;
  set actualVideoVolume(double actualVideoVolume) {
    _actualVideoVolume = actualVideoVolume;
    notifyListeners();
  }

  double _virtualVideoVolume = 1.0;

  /// while editing video volume
  double get virtualVideoVolume => _virtualVideoVolume;
  set virtualVideoVolume(double virtualVideoVolume) {
    _virtualVideoVolume = virtualVideoVolume;
    notifyListeners();
  }

  double _actualAudioVolume = 1.0;

  /// actual selected audio volume
  double get actualAudioVolume => _actualAudioVolume;
  set actualAudioVolume(double actualAudioVolume) {
    _actualAudioVolume = actualAudioVolume;
    notifyListeners();
  }

  double _virtualAudioVolume = 1.0;

  /// while selected audio volume
  double get virtualAudioVolume => _virtualAudioVolume;
  set virtualAudioVolume(double virtualAudioVolume) {
    _virtualAudioVolume = virtualAudioVolume;
    player.setVolume(virtualAudioVolume);
    notifyListeners();
  }

  String? _actualSelectedAudio;

  /// selected audio volume
  String? get actualSelectedAudio => _actualSelectedAudio;
  set actualSelectedAudio(String? value) {
    _actualSelectedAudio = value;
    notifyListeners();
  }

  String? _virtualSelectedAudio;

  /// selected audio volume
  String? get virtualSelectedAudio => _virtualSelectedAudio;
  set virtualSelectedAudio(String? value) {
    _virtualSelectedAudio = value;
    if (value == null) {
      player.pause();
    }
    notifyListeners();
  }

  Future<bool> pickAudio(
      {required int maxDuration, required Duration currentPosition}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );
      if (result?.paths.isNotEmpty ?? false) {
        virtualSelectedAudio = result!.files.first.path;
        submit();
        _playAudio(maxDuration, currentPosition);
        return true;
      }
    } catch (e) {
      log(e.toString());
    }
    return false;
  }

  cancelEditing({required int maxDuration, required Duration currentPosition}) {
    virtualAudioVolume = actualAudioVolume;
    virtualVideoVolume = actualVideoVolume;
    virtualSelectedAudio = actualSelectedAudio;
    preparingRecording = false;
    if (actualSelectedAudio != null) {
      _playAudio(maxDuration, currentPosition);
      player.seek(currentPosition);
    } else {
      player.pause();
    }
  }

  submit() {
    actualAudioVolume = virtualAudioVolume;
    actualVideoVolume = virtualVideoVolume;
    actualSelectedAudio = virtualSelectedAudio;
    preparingRecording = false;
    if (actualSelectedAudio == null) {
      player.pause();
    }
  }

  _playAudio(int maxDuration, Duration currentPosition) async {
    if (actualSelectedAudio != null) {
      await player.play(
        DeviceFileSource(actualSelectedAudio!),
        position: currentPosition,
      );
      player.setReleaseMode(ReleaseMode.loop);
      player.onDurationChanged.listen((event) {
        if (event.inSeconds >= maxDuration) {
          player.seek(Duration.zero);
        }
      });
    }
  }

  playRecordedAudio(
      {required int maxDuration, required Duration currentPosition}) async {
    if (virtualSelectedAudio != null) {
      await player.play(
        DeviceFileSource(virtualSelectedAudio!),
        position: currentPosition,
      );
      player.setReleaseMode(ReleaseMode.loop);
      player.onDurationChanged.listen((event) {
        if (event.inSeconds >= maxDuration) {
          player.seek(Duration.zero);
        }
      });
    }
  }

  bool _preparingRecording = false;

  /// is recording sheet opened
  bool get preparingRecording => _preparingRecording;
  set preparingRecording(bool preparingRecording) {
    _preparingRecording = preparingRecording;
    notifyListeners();
  }

  toggleRecording() async {
    if (await record.isPaused()) {
      await record.resume();
    } else if (!await record.isRecording()) {
      _startRecording();
    } else {
      await record.stop();
    }
    notifyListeners();
  }

  _startRecording() async {
    // Check and request permission
    if (await record.hasPermission()) {
      virtualSelectedAudio =
          (await getTemporaryDirectory()).path + UniqueKey().toString();
      // Start recording
      await record.start(
        path: virtualSelectedAudio,
        encoder: AudioEncoder.aacLc, // by default
        bitRate: 128000, // by default
      );
    }
  }

  pauseRecording() async {
    await record.pause();
    notifyListeners();
  }

  deleteRecord() async {
    await record.stop();
    virtualSelectedAudio = null;
    notifyListeners();
  }
}
