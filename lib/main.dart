import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_game/my_game.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Focus(
        onKeyEvent: (node, event) => KeyEventResult.handled,
        child: MyGameWidget(),
      ),
    ),
  );
}

class MyGameWidget extends StatefulWidget {
  const MyGameWidget({super.key});

  @override
  State<MyGameWidget> createState() => _MyGameWidgetState();
}

class _MyGameWidgetState extends State<MyGameWidget> {
  final MyGame myGame = MyGame();

  @override
  void reassemble() {
    super.reassemble();
    myGame.reload();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: myGame);
  }
}
