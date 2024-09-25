import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';

class Score extends RiveComponent {
  late StateMachineController _controller;
  TextValueRun? _scoreText;
  SMITrigger? _bounceTrigger;
  int _pendingScore = 0;

  Score(Artboard artboard) : super(artboard: artboard);

  @override
  FutureOr<void> onLoad() {
    _controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1')!;
    anchor = Anchor.center;
    artboard.addController(_controller);
    _controller.addRuntimeEventListener(onRiveEvent);

    _scoreText = artboard.component<TextValueRun>('score');
    _bounceTrigger = _controller.findInput<bool>('bounce') as SMITrigger;

    return super.onLoad();
  }

  @override
  void onRemove() {
    _controller.removeRuntimeEventListener(onRiveEvent);
    super.onRemove();
  }

  void updateScore(int score) {
    _pendingScore = score;
    _bounceTrigger?.fire();
  }

  void onRiveEvent(Event event) {
    if (event.name == 'AnimationDone') {
      _scoreText?.text = _pendingScore.toString();
      _pendingScore = 0;
    }
  }

  void reset() {
    _scoreText?.text = '0';
    _pendingScore = 0;
  }
}
