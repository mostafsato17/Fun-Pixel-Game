import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:tutorial_game/src/collisions/jump_buttom.dart';
import 'package:tutorial_game/src/level.dart';
import 'package:tutorial_game/src/player.dart';

class MyGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  @override
  Color backgroundColor() => Color(0xFF211F30);

  late CameraComponent cam;
  late final JoystickComponent joystick;
  final bool isMobiel = true;
  late final World world;
  // Player player = Player(character: 'Mask Dude');
  final Player player = Player();
  bool showConsols = true;
  bool playSound = true;
  double soundVol = 1.0;
  List<String> levelnames = ['level_01', 'level_01'];
  int currentlevelindex = 0;

  @override
  Future<void> onLoad() async {
    await images.loadAllImages();
    loadlevel();

    if (showConsols) {
      addJoystick();
      add(JumpButtom());
    }
    // await world.loaded;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showConsols) {
      updateJoystick();
    }
    super.update(dt);
  }

  void reload() {
    removeAll(children);
    onLoad();
  }

  void loadnextlevel() {
        removeWhere((component) => component is Level);

    if (currentlevelindex < levelnames.length - 1) {
      currentlevelindex++;
      loadlevel();
    } else {
      currentlevelindex = 0;
      loadnextlevel();
    }
  }

  void loadlevel() {
    Future.delayed(const Duration(seconds: 1), () {
      Level world = Level(
        levelName: levelnames[currentlevelindex],
        player: player,
      );

      cam = CameraComponent.withFixedResolution(
        width: 640,
        height: 360,
        world: world,
      );
      cam.viewfinder.anchor = Anchor.topLeft;

      addAll([cam, world]);
    });
  }

  void addJoystick() {
    priority = 20;
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Knob.png'))),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }
}
