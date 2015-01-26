library WarpTile;

import 'dart:async';

import 'package:dart_rpg/src/gui.dart';
import 'package:dart_rpg/src/main.dart';
import 'package:dart_rpg/src/player.dart';
import 'package:dart_rpg/src/sprite.dart';
import 'package:dart_rpg/src/tile.dart';

class DelayedEvent {
  final Function function;
  final int delay;
  DelayedEvent(this.delay, this.function);
}

class WarpTile extends Tile {
  int destX, destY;
  
  WarpTile(solid, sprite, this.destX, this.destY) : super(solid, sprite);
  
  void enter() {
    Main.timeScale = 0.0;
    Gui.fadeOutLevel = Gui.FADE_BLACK_LOW;
    List<DelayedEvent> events = [];
    
    events.add(new DelayedEvent(100, () {
        Gui.fadeOutLevel = Gui.FADE_BLACK_MED;
      })
    );
    
    events.add(new DelayedEvent(100, () {
        Gui.fadeOutLevel = Gui.FADE_BLACK_FULL;
        
        Player.x = destX * Sprite.pixelsPerSprite * Sprite.spriteScale;
        Player.y = destY * Sprite.pixelsPerSprite * Sprite.spriteScale;
        Player.mapX = destX;
        Player.mapY = destY;
      })
    );
    
    events.add(new DelayedEvent(100, () {
        Gui.fadeOutLevel = Gui.FADE_BLACK_MED;
      })
    );
    
    events.add(new DelayedEvent(100, () {
        Gui.fadeOutLevel = Gui.FADE_BLACK_LOW;
      })
    );
    
    events.add(new DelayedEvent(100, () {
        Gui.fadeOutLevel = Gui.FADE_NORMAL;
        Main.timeScale = 1.0;
      })
    );
    
    executeDelayedEvents(events);
  }
  
  void executeDelayedEvents(List<DelayedEvent> events) {
    Future future = new Future.delayed(const Duration(milliseconds: 0), () {});
    for(DelayedEvent event in events) {
      future = addDelayed(future, event.delay, event.function);
    }
  }
  
  Future addDelayed(Future future, int delay, Function function) {
    return future.then( (value) {
      return new Future.delayed(new Duration(milliseconds: delay), () {
        function();
      });
    });
  }
}