import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playTap() async {
    await _player.play(AssetSource('sounds/tick_sound.mp3'));
  }
}
