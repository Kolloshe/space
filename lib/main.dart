import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redmtionfighter/screens/main_menu.dart';

import 'game/game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  runApp(MaterialApp(
    themeMode:ThemeMode.dark,
    darkTheme:ThemeData.dark().copyWith(textTheme: GoogleFonts.bubblegumSansTextTheme(),
    scaffoldBackgroundColor: Colors.black),
    home:  const MainMenu(),
  ));
}
