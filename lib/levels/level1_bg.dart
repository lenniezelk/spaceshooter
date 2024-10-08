import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/painting.dart';
import 'package:rive_game_flutter/game/game.dart';

class Level1Bg extends RiveComponent with HasGameRef<SpaceshooterGame> {
  late SMINumber _xInput;
  late SMINumber _yInput;
  late StateMachineController _controller;
  double _x = 0; // percentage
  double _y = 0; // percentage
  double _prevX = 0;
  double _prevY = 0;

  Level1Bg(Artboard artboard)
      : super(
          artboard: artboard,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        );

  @override
  FutureOr<void> onLoad() {
    _controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1')!;
    anchor = Anchor.center;
    size = gameRef.size;
    artboard.frameOrigin = false;
    position = gameRef.size / 2;
    artboard.addController(_controller);

    _xInput = _controller.findInput<double>('x') as SMINumber;
    _yInput = _controller.findInput<double>('y') as SMINumber;

    return super.onLoad();
  }

  void move(double x, double y) {
    _x = x;
    _y = y;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final newX = lerpDouble(_prevX, _x, dt);
    final newY = lerpDouble(_prevY, _y, dt);

    if (newX != null) {
      _xInput.value = newX;
      _prevX = _x;
      _x = newX;
    }

    if (newY != null) {
      _yInput.value = newY;
      _prevY = _y;
      _y = newY;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    position = size / 2;
  }
}
