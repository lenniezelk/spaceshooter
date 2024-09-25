import 'package:flame/components.dart';
import 'package:rive_game_flutter/game/game.dart';

class Level extends World with HasGameRef<SpaceshooterGame> {
  void addBullet(position, angle) {
    throw UnimplementedError();
  }

  void reset() {
    throw UnimplementedError();
  }

  void updateVitals(int health, int lives, String healthText) {
    throw UnimplementedError();
  }
}
