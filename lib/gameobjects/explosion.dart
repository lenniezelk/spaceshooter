import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';

class Explosion extends RiveComponent {
  late StateMachineController _controller;
  Vector2 spawnPosition;
  bool _isDone = false;
  bool get isDone => _isDone;

  Explosion(Artboard artboard, this.spawnPosition) : super(artboard: artboard);

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;
    _controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1')!;
    anchor = Anchor.center;
    _controller.addEventListener(_onRiveEvent);
    artboard.addController(_controller);
    position = spawnPosition;

    return super.onLoad();
  }

  _onRiveEvent(RiveEvent event) {
    if (event.name == 'ExplosionEnd') {
      _isDone = true;
    }
  }

  @override
  void onRemove() {
    _controller.removeEventListener(_onRiveEvent);
    super.onRemove();
  }
}
