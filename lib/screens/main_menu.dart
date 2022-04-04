import 'package:flutter/material.dart';
import 'package:redmtionfighter/screens/game_play.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child:  Text(
                'Spacescape',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 50.0, shadows: [
                  const Shadow(
                    blurRadius: 20.0,
                    color: Colors.white,
                    offset: Offset(0, 0),
                  ),
                ]),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width/3,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const GamePlay(),
                      ),
                    );
                  },
                  child: const Text('play')),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width/3,

                child: ElevatedButton(onPressed: () {}, child: const Text('Options'))),
          ],
        ),
      ),
    );
  }
}
