import 'dart:async';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:tutorial_game/my_game.dart';
import 'package:tutorial_game/src/player.dart';

enum State { idle, run, hit }

class Chicken extends SpriteAnimationGroupComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  final double offNeg;
  final double offPos;
  Chicken({super.position, super.size, this.offNeg = 0, this.offPos = 0});
  static const steptime = 0.05;
  static const runSpeed = 80;
  static const tileSize = 16;
  static const bounceHeight = 260.0;
  final texturesize = Vector2(32, 34);

  Vector2 velocity = Vector2.zero();
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;
  bool gotStoped = false;

  late final Player player;
  late final SpriteAnimation idleAnime;
  late final SpriteAnimation runAnime;
  late final SpriteAnimation hitAnime;
  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    player = game.player;
    add(RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 26)));
    loadallanime();
    calculateRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStoped) {
      upfateState();
      movmentChicken(dt);
    }
    super.update(dt);
  }

  void loadallanime() {
    idleAnime = spriteAnimation('Idle', 13);
    runAnime = spriteAnimation('Run', 14);
    hitAnime = spriteAnimation('Hit', 15)..loop = false;

    animations = {
      State.idle: idleAnime,
      State.run: runAnime,
      State.hit: hitAnime,
    };

    current = State.idle;
  }

  SpriteAnimation spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Chicken/$state (32x34).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: steptime,
        textureSize: texturesize,
      ),
    );
  }

  void calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void movmentChicken(dt) {
    velocity.x = 0;
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double chickenOffset = (scale.x > 0) ? 0 : -width;

    if (PlayerRange()) {
      targetDirection =
          (player.x + playerOffset < position.x + chickenOffset) ? -1 : 1;
      velocity.x = targetDirection * runSpeed;
    }
    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
    position.x += velocity.x * dt;
  }

  bool PlayerRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    return player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void upfateState() {
    current = (velocity.x != 0) ? State.run : State.idle;
    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSound) FlameAudio.play('bounce.wav', volume: game.soundVol);
      gotStoped = true;
      current = State.hit;
      player.velocity.y = -bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedWithEnemy();
    }
  }
}
