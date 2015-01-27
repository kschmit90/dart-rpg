library Character;

import 'package:dart_rpg/src/interactable.dart';
import 'package:dart_rpg/src/main.dart';
import 'package:dart_rpg/src/sprite.dart';
import 'package:dart_rpg/src/tile.dart';
import 'package:dart_rpg/src/world.dart';

class Character implements Interactable {
  static final int
    DOWN = 0,
    RIGHT = 1,
    UP = 2,
    LEFT = 3;
  
  final int
    walkSpeed = 4,
    runSpeed = 8,
    motionAmount = Sprite.pixelsPerSprite * Sprite.spriteScale,
    directionCooldownAmount = 4;
  
  int 
    motionX = 0,
    motionY = 0,
    direction = DOWN,
    directionCooldown = 0,
    curSpeed,
    motionStep = 1,
    motionSpriteOffset = 0,
    mapX,
    mapY,
    x,
    y;
  
  Character(int posX, int posY) {
    curSpeed = walkSpeed;
    mapX = posX;
    mapY = posY;
    x = mapX * motionAmount;
    y = mapY * motionAmount;
  }
  
  void move(motionDirection) {
    // only move if we're not already moving
    if(motionX == 0 && motionY == 0) {
      // allow the player to change directions without moving
      if(direction != motionDirection) {
        direction = motionDirection;
        directionCooldown = directionCooldownAmount;
        return;
      }
      
      // don't add motion until we've finished turning
      if(directionCooldown > 0)
        return;
      
      if(motionDirection == Character.LEFT) {
        Main.world.map[mapY][mapX-1][World.LAYER_GROUND].enter();
        motionX = -motionAmount;
      } else if(motionDirection == Character.RIGHT) {
        Main.world.map[mapY][mapX+1][World.LAYER_GROUND].enter();
        motionX = motionAmount;
      } else if(motionDirection == Character.UP) {
        Main.world.map[mapY-1][mapX][World.LAYER_GROUND].enter();
        motionY = -motionAmount;
      } else if(motionDirection == Character.DOWN) {
        Main.world.map[mapY+1][mapX][World.LAYER_GROUND].enter();
        motionY = motionAmount;
      }
    }
  }
  
  void tick() {
    if(directionCooldown > 0) {
      directionCooldown -= 1;
      
      // use walk cycle sprite when turning
      if(directionCooldown >= directionCooldownAmount/2) {
        motionSpriteOffset = motionStep + 3 + direction;
      } else if(directionCooldown == 0) {
        if(motionStep == 1)
          motionStep = 2;
        else if(motionStep == 2)
          motionStep = 1;
      }
      
      return;
    }
    
    // set walk cycle sprite for first half of motion
    if(
        (motionX != 0 && (motionX).abs() > motionAmount/2)
        || (motionY != 0 && (motionY).abs() > motionAmount/2)) {
      motionSpriteOffset = motionStep + 3 + direction;
    } else {
      motionSpriteOffset = 0;
    }
    
    if(motionX < 0) {
      motionX += curSpeed;
      if(!Main.world.isSolid(mapX-1, mapY)) {
        x -= curSpeed;
        
        if(motionX == 0)
          mapX -= 1;
      }
      
      // reverse walk cycle foot
      if(motionX == 0 && motionStep == 1)
        motionStep = 2;
      else if(motionX == 0 && motionStep == 2)
        motionStep = 1;
    } else if(motionX > 0) {
      motionX -= curSpeed;
      if(!Main.world.isSolid(mapX+1, mapY)) {
        x += curSpeed;
        
        if(motionX == 0)
          mapX += 1;
      }
      
      // reverse walk cycle foot
      if(motionX == 0 && motionStep == 1)
        motionStep = 2;
      else if(motionX == 0 && motionStep == 2)
        motionStep = 1;
    } else if(motionY < 0) {
      motionY += curSpeed;
      if(!Main.world.isSolid(mapX, mapY-1)) {
        y -= curSpeed;
        
        if(motionY == 0)
          mapY -= 1;
      }
      
      // reverse walk cycle foot
      if(motionY == 0 && motionStep == 1)
        motionStep = 2;
      else if(motionY == 0 && motionStep == 2)
        motionStep = 1;
    } else if(motionY > 0) {
      motionY -= curSpeed;
      if(!Main.world.isSolid(mapX, mapY+1)) {
        y += curSpeed;
        
        if(motionY == 0)
          mapY += 1;
      }
      
      // reverse walk cycle foot
      if(motionY == 0 && motionStep == 1)
        motionStep = 2;
      else if(motionY == 0 && motionStep == 2)
        motionStep = 1;
    }
  }
  
  void render(List<List<Tile>> renderList) {
    renderList[World.LAYER_PLAYER].add(
      new Tile(
        true,
        new Sprite(
          Tile.PLAYER + direction + motionSpriteOffset,
          x/motionAmount, (y/motionAmount)-1
        )
      )
    );
    
    renderList[World.LAYER_PLAYER].add(
      new Tile(
        true,
        new Sprite(
          Tile.PLAYER + direction + motionSpriteOffset + Sprite.spriteSheetSize,
          x/motionAmount, y/motionAmount
        )
      )
    );
  }
  
  void interact() {
    
  }
}