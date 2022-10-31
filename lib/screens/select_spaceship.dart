import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:redmtionfighter/models/player_data.dart';
import 'package:redmtionfighter/models/spaceship_details.dart';
import 'package:redmtionfighter/screens/main_menu.dart';

import 'game_play.dart';

class SelectSpaceship extends StatelessWidget {
  const SelectSpaceship({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Text(
                'Select',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 50.0, shadows: [
                  const Shadow(
                    blurRadius: 20.0,
                    color: Colors.white,
                    offset: Offset(0, 0),
                  ),
                ]),
              ),
            ),
            Consumer<PlayerData>(builder: (context,playerData,child){
              final spaceship = Spaceship.getSpaceshipByType(playerData.spaceshipType);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Ship: ${spaceship.name}',   style: const TextStyle(
                    color: Colors.white,fontSize: 18
                  ), ),
                  Text('Money: ${playerData.money}',style: const TextStyle(
                    color: Colors.white,fontSize: 18
                  ), ),
                ],
              );
            },),


            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: CarouselSlider.builder(
                itemCount: Spaceship.spaceships.length,
                slideBuilder: (index) {
                  final spaceship = Spaceship.spaceships.entries.elementAt(index).value;
                  return Column(
                    children: [
                      Image.asset(spaceship.assetPath),
                      Text(spaceship.name, style: const TextStyle(color: Colors.white)),
                      Text(
                        'Speed: ${spaceship.speed}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text('Level: ${spaceship.level}',
                          style: const TextStyle(color: Colors.white)),
                      Text('Cost: ${spaceship.cost}', style: const TextStyle(color: Colors.white)),
                      Consumer<PlayerData>(builder: (context, playerData, child) {
                        final type = Spaceship.spaceships.entries.elementAt(index).key;

                        final isEquipped = playerData.isEquipped(type);

                        final isOwned = playerData.isOwned(type);

                        final canBuy = playerData.canBuy(type);

                        return ElevatedButton(
                          child: Text(isEquipped
                              ? 'Equipped'
                              : isOwned
                                  ? 'Select'
                                  : 'Buy'),
                          onPressed: isEquipped
                              ? null
                              : () {
                                  if (isOwned) {
                                    playerData.equip(type);
                                  } else {
                                    if (canBuy) {
                                      playerData.buy(type);
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return
                                            AlertDialog(
                                              backgroundColor: Colors.redAccent,
                                              title: const Text(
                                                'Insufficient Balance',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Colors.white,fontSize: 20),
                                              ),
                                              content:
                                                  Text('Need ${spaceship.cost - playerData.money}',  textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.white,fontSize: 20),),
                                            );
                                          });
                                    }
                                  }
                                },
                        );
                      })
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const GamePlay(),
                      ),
                    );
                  },
                  child: const Text('Start')),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const MainMenu()));
                    },
                    child: const Icon(Icons.arrow_back_ios_new_rounded))),
          ],
        ),
      ),
    );
  }
}
