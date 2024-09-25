import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';

class Vitals extends RiveComponent {
  late StateMachineController _controller;
  Vitals(Artboard artboard) : super(artboard: artboard);
  SMINumber? _health;
  SMINumber? _lives;
  TextValueRun? _healthText;

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;
    _controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1')!;
    anchor = Anchor.center;
    artboard.addController(_controller);

    _health = _controller.findInput<double>('health') as SMINumber;
    _lives = _controller.findInput<double>('lives') as SMINumber;

    _healthText = artboard.component<TextValueRun>('healthTextRun');

    return super.onLoad();
  }

  void setHealth(int health) {
    if (_health != null) {
      _health?.value = health.toDouble();
    }
  }

  void setLives(int lives) {
    if (_lives != null) {
      _lives?.value = lives.toDouble();
    }
  }

  void setHealthText(String text) {
    if (_healthText != null) {
      _healthText?.text = text;
    }
  }

  void reset() {
    setHealth(100);
    setLives(3);
    setHealthText('100%');
  }
}
