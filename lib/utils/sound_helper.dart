import 'package:audioplayers/audioplayers.dart';

class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();

  static final List<Map<String, String>> availableSounds = [
    {'name': 'Alarma Crítica', 'file': 'alarm_1.mp3'},
    {'name': 'Bip Digital', 'file': 'alarm_2.mp3'},
    {'name': 'Campana Suave', 'file': 'alarm_3.mp3'},
  ];

  static Future<void> playAlarm(String fileName) async {
    await stop();

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setSource(AssetSource('sounds/$fileName'));
    await _player.resume();
  }

  static Future<void> stop() async {
    await _player.stop();
  }

  static Future<void> preview(String fileName) async {
    await stop();
    await _player.setReleaseMode(ReleaseMode.release);
    await _player.setSource(AssetSource('sounds/$fileName'));
    await _player.resume();
  }
}