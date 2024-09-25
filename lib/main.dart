import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:rive_game_flutter/game/game.dart';

void main() {
  runApp(const GameWidget.controlled(
    gameFactory: SpaceshooterGame.new,
  ));
}
