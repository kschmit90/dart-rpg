library dart_rpg.game_map;

import 'package:dart_rpg/src/encounter_tile.dart';
import 'package:dart_rpg/src/tile.dart';

class GameMap {
  String name;
  List<List<List<Tile>>> tiles = [];
  List<BattlerChance> battlerChances = [];
  
  GameMap(this.name, [this.tiles]);
}