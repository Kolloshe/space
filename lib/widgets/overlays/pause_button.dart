import 'package:flutter/material.dart';
import 'package:redmtionfighter/game/game.dart';
import 'package:redmtionfighter/widgets/overlays/pausemenu.dart';

class PauseButton extends StatelessWidget {
  static const String ID = 'PauseButton';
final SpaceScapeGame gameRef;
  const PauseButton({Key? key,required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: TextButton(child: Icon(Icons.pause_rounded,size: 50, color: Colors.white,),

        onPressed: () {
          gameRef.pauseEngine();
          gameRef.overlays.add(PauseMenu.ID);
          gameRef.overlays.remove(PauseButton.ID);
        },),

    );
  }
}
