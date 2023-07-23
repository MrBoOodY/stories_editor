import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AudioNotifier extends ChangeNotifier {
  final player = AudioPlayer();

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

  cancelEditing({required Duration currentPosition}) {
    virtualAudioVolume = actualAudioVolume;
    virtualVideoVolume = actualVideoVolume;
    virtualSelectedAudio = actualSelectedAudio;
    if (actualSelectedAudio != null) {
      player.resume();
      player.seek(currentPosition);
    }
  }

  submit() {
    actualAudioVolume = virtualAudioVolume;
    actualVideoVolume = virtualVideoVolume;
    actualSelectedAudio = virtualSelectedAudio;
    if (actualSelectedAudio == null) {
      player.dispose();
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
}
