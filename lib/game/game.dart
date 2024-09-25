import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:rive_game_flutter/levels/level1.dart';

class SpaceshooterGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late RouterComponent _router;

  @override
  Future<void> onLoad() async {
    _router = RouterComponent(
      initialRoute: 'home',
      routes: {
        'home': Route(Level1.new),
      },
    );
    add(_router);

    camera.viewfinder.anchor = Anchor.topLeft;

    return super.onLoad();
  }

  @override
  Color backgroundColor() {
    return const Color(0xff230038);
  }
}
