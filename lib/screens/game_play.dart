import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:redmtionfighter/game/game.dart';
import 'package:redmtionfighter/widgets/overlays/game_over_menu.dart';
import 'package:redmtionfighter/widgets/overlays/pause_button.dart';
import 'package:redmtionfighter/widgets/overlays/pausemenu.dart';

SpaceScapeGame _spaceScapeGame = SpaceScapeGame();

class GamePlay extends StatelessWidget {
  const GamePlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
          onWillPop: () async => false,
          child:  GameWidget(
            game: _spaceScapeGame,
            // Initially only pause button overlay will be visible.
            initialActiveOverlays: [PauseButton.ID],
            overlayBuilderMap: {
              PauseButton.ID: (BuildContext context, SpaceScapeGame gameRef) =>
                  PauseButton(
                    gameRef: gameRef,
                  ),
              PauseMenu.ID: (BuildContext context, SpaceScapeGame gameRef) =>
                  PauseMenu(
                    gameRef: gameRef,
                  ),
              GameOverMenu.ID: (BuildContext context, SpaceScapeGame gameRef) =>
                  GameOverMenu(
                    gameRef: gameRef,
                  ),

            },
          ),
      ),
    );
  }
}

