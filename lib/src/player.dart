import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:tutorial_game/src/collisions/Chicken_jokey.dart';
import 'package:tutorial_game/src/collisions/Fruit.dart';
import 'package:tutorial_game/src/collisions/checkpoint.dart';
import 'package:tutorial_game/src/collisions/collision_block.dart';
import 'package:tutorial_game/src/collisions/collision_utils.dart';
import 'package:tutorial_game/src/collisions/custom_hitbox.dart';
import 'package:tutorial_game/src/collisions/saw.dart';
import 'package:tutorial_game/my_game.dart';

enum PlayerState { idle, run, jump, fall, hit, appering, disappearing }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<MyGame>, KeyboardHandler, CollisionCallbacks {
  String character;
  Player({position, this.character = 'Pink Guy'}) : super(position: position);

  late final Vector2 startingPosition;
  late final SpriteAnimation idleanime;
  late final SpriteAnimation runniganiume;
  late final SpriteAnimation jumpinganime;
  late final SpriteAnimation fallinganime;
  late final SpriteAnimation hitinganime;
  late final SpriteAnimation apperinganime;
  late final SpriteAnimation disappearinganime;
  final double _gravity = 9.8;
  final double steptime = 0.05;
  final double _jumpForce = 260;
  final double moveSpeed = 100.0;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0.0;
  double verticalMovement = 0.0;
  double fixeddelaTime = 1 / 60;
  double accumulatedTime = 0;
  Vector2 velocity = Vector2.zero();
  Vector2 startPos = Vector2.zero();
  bool reachcheckpoint = false;
  bool isOnGround = false;
  bool hasJumped = false;
  bool gohit = false;
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox = const CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  @override
  FutureOr<void> onLoad() {
    debugMode = false;

    startingPosition = position;

    _loadAllAnimations();
    startPos = Vector2(position.x, position.y);

    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixeddelaTime) {
      if (!gohit && !reachcheckpoint) {
        _updatePlayerState();
        _updatePlayerPosition(fixeddelaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixeddelaTime);
        _checkVerticalCollisions();
      }
      accumulatedTime -= fixeddelaTime;
    }
    super.update(dt);
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.run;

    if (velocity.y > 0) playerState = PlayerState.fall;

    if (velocity.y < 0) playerState = PlayerState.jump;

    current = playerState;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (!reachcheckpoint) {
      if (other is Fruit) {
        other.collisionWithplayer();
      }
      if (other is Saw) {
        respawn();
      }
      if (other is Chicken) {
        other.collidedWithPlayer();
      }
      if (other is Checkpoint) {
        reachCheckpoints();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    verticalMovement = 0;

    final isLeftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;
    hasJumped = keysPressed.contains(LogicalKeyboardKey.arrowRight);

    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerPosition(double dt) {
    if (hasJumped && isOnGround) {
      jumpPlayer(dt);
    }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void jumpPlayer(double dt) {
    if (game.playSound) FlameAudio.play('jump.wav', volume: game.soundVol);
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _loadAllAnimations() {
    idleanime = animefunction("Idle", 11);
    runniganiume = animefunction("Run", 12);
    jumpinganime = animefunction("Jump", 1);
    fallinganime = animefunction("Fall", 1);
    hitinganime = animefunction("Hit", 7)..loop = false;
    apperinganime = spectialanimefunction("Appearing", 7);
    disappearinganime = spectialanimefunction("Desappearing", 7);
    animations = {
      PlayerState.idle: idleanime,
      PlayerState.run: runniganiume,
      PlayerState.jump: jumpinganime,
      PlayerState.fall: fallinganime,
      PlayerState.hit: hitinganime,
      PlayerState.appering: apperinganime,
      PlayerState.disappearing: disappearinganime,
    };
    current = PlayerState.idle;
  }

  SpriteAnimation animefunction(String method, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/Ninja Frog/$method (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: steptime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  SpriteAnimation spectialanimefunction(String method, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$method (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: steptime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void respawn() async {
    if (game.playSound) FlameAudio.play('hit.wav', volume: game.soundVol);
    const canMoveDuration = Duration(milliseconds: 400);
    gohit = true;
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = startPos - Vector2.all(32);
    current = PlayerState.appering;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = startPos;
    _updatePlayerState();
    Future.delayed(canMoveDuration, () => gohit = false);
  }

  void reachCheckpoints() async {
    reachcheckpoint = true;
    if (game.playSound) FlameAudio.play('disappear.wav', volume: game.soundVol);
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position - Vector2(32, -32);
    }
    current = PlayerState.disappearing;
    await animationTicker?.completed;
    animationTicker?.reset();

    reachcheckpoint = false;
    position = Vector2.all(-640);
    const waittochangeDuration = Duration(seconds: 3);
    Future.delayed(waittochangeDuration, () {
      game.loadnextlevel();
    });
  }

  void collidedWithEnemy() {
    respawn();
  }
}
