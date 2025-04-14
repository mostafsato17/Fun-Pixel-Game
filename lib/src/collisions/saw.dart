import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:tutorial_game/my_game.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<MyGame> {
  final bool isVertical;
  final double offNeg;
  final double offPos;
  Saw({
    this.isVertical = false,
    this.offNeg = 0,
    this.offPos = 0,
    poistion,
    size,
  }) : super(position: poistion, size: size);
  static const double stepTime = 0.03;
  static const movespeed = 50;
  static const tileSize = 16;
  double moveDirection = 1;
  double rangNeg = 0;
  double rangPos = 0;

  @override
  FutureOr<void> onLoad() {
    add(CircleHitbox());

    priority = -1;

    if (isVertical) {
      rangNeg = position.y - offNeg * tileSize;
      rangPos = position.y + offPos * tileSize;
    } else {
      rangNeg = position.x - offNeg * tileSize;
      rangPos = position.x + offPos * tileSize;
    }
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: stepTime,
        textureSize: Vector2.all(38),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      moveVertical(dt);
    } else {
      moveHorizantil(dt);
    }
    super.update(dt);
  }

  void moveVertical(double dt) {
    if (position.y >= rangPos) {
      moveDirection = -1;
    } else if (position.y <= rangNeg) {
      moveDirection = 1;
    }
    position.y += moveDirection * movespeed * dt;
  }

  void moveHorizantil(double dt) {
    if (position.x >= rangPos)
      moveDirection = -1;
    else if (position.x <= rangNeg)
      moveDirection = 1;
    position.x += moveDirection * movespeed * dt;
  }
}
