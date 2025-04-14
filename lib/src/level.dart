import 'dart:async';

import 'package:flame/components.dart';
 
import 'package:flame_tiled/flame_tiled.dart';
import 'package:tutorial_game/src/collisions/Chicken_jokey.dart';
import 'package:tutorial_game/src/collisions/Fruit.dart';
import 'package:tutorial_game/src/collisions/background_tile.dart';
import 'package:tutorial_game/src/collisions/checkpoint.dart';
import 'package:tutorial_game/src/collisions/collision_block.dart';
import 'package:tutorial_game/src/collisions/saw.dart';
import 'package:tutorial_game/my_game.dart';
import 'package:tutorial_game/src/player.dart';

class Level extends World with HasGameRef<MyGame> {
  final String levelName;
  final Player player;

  Level({required this.levelName, required this.player});

  late TiledComponent map;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    map = await TiledComponent.load("$levelName.tmx", Vector2.all(16));

    add(map);
    scrollingBackground();
    _spawnObjects();
    _addCollisions();
    _addxxx();
    return super.onLoad();
  }

  void _spawnObjects() {
    final spawnPointsLayer = map.tileMap.getLayer<ObjectGroup>("SpawnPoint");

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case "Player":
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = 1;
            add(player);
            break;
          case "Fruit":
            final fruit = Fruit(
              fruit: spawnPoint.name,
              poistion: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;
          case "Saw":
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');

            final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,

              poistion: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw);

            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              poistion: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;
          case 'Chicken':
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final chicken = Chicken(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: offNeg,
              offPos: offPos,
            );
            add(chicken);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collidersLayer = map.tileMap.getLayer<ObjectGroup>("Colisions");

    if (collidersLayer != null) {
      for (final collider in collidersLayer.objects) {
        final block = CollisionBlock(
          position: Vector2(collider.x, collider.y),
          size: Vector2(collider.width, collider.height),
        );

        collisionBlocks.add(block);
        add(block);
      }

      player.collisionBlocks = collisionBlocks;
    }
  }

  void _addxxx() {
    final collidersLayer = map.tileMap.getLayer<ObjectGroup>("xxx");

    if (collidersLayer != null) {
      for (final collider in collidersLayer.objects) {
        final block = CollisionBlock(
          position: Vector2(collider.x, collider.y),
          size: Vector2(collider.width, collider.height),
          isPlatform: true,
        );

        collisionBlocks.add(block);
        add(block);
      }

      player.collisionBlocks = collisionBlocks;
    }
  }

  // void scrollingBackground() {
  //   final backGroundLayer = map.tileMap.getLayer('Background');

  //   const tileSize = 64;
  //   final numTileY = (game.size.y / tileSize).floor();
  //   final numTileX = (game.size.x / tileSize).floor();

  //   if (backGroundLayer != null) {
  //     final backGroundcolor = backGroundLayer.properties.getValue(
  //       'BackgroundColor',
  //     );
  //     for (double y = 0; y < game.size.y / numTileY; y++) {
  //       for (double x = 0; x < numTileX; x++) {
  //         final backGroundTile = BackgroundTile(
  //           color: backGroundcolor ?? "Gray",
  //           poistion: Vector2(x * tileSize, y * tileSize),
  //         );
  //         add(backGroundTile);
  //       }
  //     }
  //   }
  // }
  void scrollingBackground() {
    final backGroundLayer = map.tileMap.getLayer('Background');

    if (backGroundLayer != null) {
      final backGroundcolor = backGroundLayer.properties.getValue(
        'BackgroundColor',
      );
      final backGroundTile = BackgroundTile(
        color: backGroundcolor ?? "Gray",
        position: Vector2(0, 0),
      );

      add(backGroundTile);
    }
  }
}
