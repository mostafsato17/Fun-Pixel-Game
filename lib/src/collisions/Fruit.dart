import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:tutorial_game/src/collisions/custom_hitbox.dart';
import 'package:tutorial_game/my_game.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  final String fruit;
  Fruit({this.fruit = 'Apple', poistion, size})
    : super(position: poistion, size: size);
  final double steptime = 0.05;
  final hitbox = CustomHitbox(offsetX: 10, offsetY: 10, width: 12, height: 11);
  bool collectedfruit = false;
  @override
  FutureOr<void> onLoad() {
    debugMode = false;
    priority = -1;
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ),
    );
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: steptime,
        textureSize: Vector2.all(32),
      ),
    );
    return super.onLoad();
  }

  void collisionWithplayer() async {
    if (!collectedfruit) {
      collectedfruit = true;
      if (game.playSound)
        FlameAudio.play('collect_fruit.wav', volume: game.soundVol);

      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: steptime,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      );
      await animationTicker?.completed;
      removeFromParent();
    }
  }
}
