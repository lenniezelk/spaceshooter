import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';

class Stage extends RiveComponent {
  late StateMachineController _controller;
  TextValueRun? _stageText;
  SMITrigger? _bounceTrigger;
  SMINumber? _stageNumber;

  Stage(Artboard artboard) : super(artboard: artboard);

  @override
  FutureOr<void> onLoad() {
    _controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1')!;
    anchor = Anchor.center;
    artboard.addController(_controller);

    _stageText = artboard.component<TextValueRun>('stageText');
    _bounceTrigger = _controller.findInput<bool>('bounce') as SMITrigger;
    _stageNumber = _controller.findInput<double>('stage') as SMINumber;

    return super.onLoad();
  }

  void updateStage(int stage) {
    _stageNumber?.value = (stage / 10) * 100;
    _stageText?.text = 'Stage: $stage / 10';
    _bounceTrigger?.fire();
  }

  void reset() {
    _stageText?.text = 'Stage: 1 / 10';
    _stageNumber?.value = (1 / 10) * 100;
  }
}
