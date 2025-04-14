import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:tutorial_game/my_game.dart';

class JumpButtom extends SpriteComponent with HasGameRef<MyGame>, TapCallbacks {
  JumpButtom();

  final margin = 32;
  final buttomsize = 64;
  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));
    position = Vector2(
      game.size.x - margin - buttomsize,
      game.size.y - margin - buttomsize,
    );
    priority = 10;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
