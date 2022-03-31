import 'package:flame/components.dart';

mixin KnowsGameSize on BaseComponent
{
  late Vector2 gameSize;

  void onReSize(Vector2 newGameSize){
    gameSize = newGameSize;
  }
}