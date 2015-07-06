library dart_rpg.object_editor_game_events;

import 'package:dart_rpg/src/character.dart';

import 'package:dart_rpg/src/game_event/game_event.dart';
import 'package:dart_rpg/src/game_event/delay_game_event.dart';
import 'package:dart_rpg/src/game_event/fade_game_event.dart';
import 'package:dart_rpg/src/game_event/move_game_event.dart';
import 'package:dart_rpg/src/game_event/text_game_event.dart';

import 'editor.dart';

class ObjectEditorGameEvents {
  static List<String> getAttributes(GameEvent gameEvent) {
    if(gameEvent is TextGameEvent) {
      return ["picture_id", "text"];
    } else if(gameEvent is MoveGameEvent) {
      return ["direction", "distance"];
    } else if(gameEvent is DelayGameEvent) {
      return ["milliseconds"];
    } else if(gameEvent is FadeGameEvent) {
      return ["fade_type"];
    } else {
      return [];
    }
  }
  
  static GameEvent buildGameEvent(String prefix, Character character) {
    String gameEventType = Editor.getSelectInputStringValue("#${prefix}_type");
    
    if(gameEventType == "text") {
      TextGameEvent textGameEvent = new TextGameEvent(
          Editor.getTextInputIntValue("#${prefix}_picture_id", 1),
          Editor.getTextAreaStringValue("#${prefix}_text")
        );
      
      return textGameEvent;
    } else if(gameEventType == "move") {
      MoveGameEvent moveGameEvent = new MoveGameEvent(
          character,
          Editor.getSelectInputIntValue("#${prefix}_direction", Character.DOWN),
          Editor.getTextInputIntValue("#${prefix}_distance", 1)
        );
      
      return moveGameEvent;
    } else if(gameEventType == "delay") {
      DelayGameEvent delayGameEvent = new DelayGameEvent(
          Editor.getTextInputIntValue("#${prefix}_milliseconds", 100)
        );
      
      return delayGameEvent;
    } else if(gameEventType == "fade") {
      FadeGameEvent fadeGameEvent = new FadeGameEvent(
          Editor.getSelectInputIntValue("#${prefix}_fade_type", 2)
        );
      
      return fadeGameEvent;
    } else {
      return null;
    }
  }
  
  static Map<String, Object> buildGameEventJson(GameEvent gameEvent) {
    Map<String, Object> gameEventJson = {};
    
    if(gameEvent is TextGameEvent) {
      gameEventJson["type"] = "text";
      gameEventJson["pictureId"] = gameEvent.pictureSpriteId;
      gameEventJson["text"] = gameEvent.text;
    } else if(gameEvent is MoveGameEvent) {
      gameEventJson["type"] = "move";
      gameEventJson["direction"] = gameEvent.direction;
      gameEventJson["distance"] = gameEvent.distance;
    } else if(gameEvent is DelayGameEvent) {
      gameEventJson["type"] = "delay";
      gameEventJson["milliseconds"] = gameEvent.milliseconds;
    } else if(gameEvent is FadeGameEvent) {
      gameEventJson["type"] = "fade";
      gameEventJson["fade_type"] = gameEvent.fadeType;
    }
    
    return gameEventJson;
  }
  
  static String buildGameEventTableRowHtml(GameEvent gameEvent, String prefix, int num) {
    String gameEventHtml = "";
    gameEventHtml += "<tr>";
    gameEventHtml += "  <td>${num}</td>";
    gameEventHtml += "  <td><select id='${prefix}_type'>";
    
    String paramsHtml = "";
    
    List<String> gameEventTypes = ["text", "move", "delay", "fade", "heal", "warp"];
    for(int k=0; k<gameEventTypes.length; k++) {
      String selectedText = "";
      if(gameEventTypes[k] == "text" && gameEvent is TextGameEvent) {
        selectedText = "selected='selected'";
        paramsHtml = ObjectEditorGameEvents.buildTextGameEventParamsHtml(gameEvent, prefix);
      } else if(gameEventTypes[k] == "move" && gameEvent is MoveGameEvent) {
        selectedText = "selected='selected'";
        paramsHtml = ObjectEditorGameEvents.buildMoveGameEventParamsHtml(gameEvent, prefix);
      } else if(gameEventTypes[k] == "delay" && gameEvent is DelayGameEvent) {
        selectedText = "selected='selected'";
        paramsHtml = ObjectEditorGameEvents.buildDelayGameEventParamsHtml(gameEvent, prefix);
      } else if(gameEventTypes[k] == "fade" && gameEvent is FadeGameEvent) {
        selectedText = "selected='selected'";
        paramsHtml = ObjectEditorGameEvents.buildFadeGameEventParamsHtml(gameEvent, prefix);
      }
      
      gameEventHtml += "    <option ${selectedText}>${gameEventTypes[k]}</option>";
    }
    
    gameEventHtml += "  </select></td>";
    gameEventHtml += "  <td>${paramsHtml}</td>";
    gameEventHtml += "  <td><button id='delete_${prefix}'>Delete</button></td>";
    gameEventHtml += "</tr>";
    
    return gameEventHtml;
  }
  
  static String buildTextGameEventParamsHtml(TextGameEvent textGameEvent, String prefix) {
    String html = "";
    
    html += "<table>";
    html += "  <tr><td>Picture Id</td><td>Text</td></tr>";
    html += "  <tr>";
    html += "    <td><input type='text' class='number' id='${prefix}_picture_id' value='${textGameEvent.pictureSpriteId}' /></td>";
    html += "    <td><textarea id='${prefix}_text'>${textGameEvent.text}</textarea>";
    html += "  </tr>";
    html += "</table>";
    
    return html;
  }
  
  static String buildMoveGameEventParamsHtml(MoveGameEvent moveGameEvent, String prefix) {
    String html = "";
    
    html += "<table>";
    html += "  <tr><td>Direction</td><td>Distance</td></tr>";
    html += "  <tr>";
    
    // direction
    html += "<td><select id='${prefix}_direction'>";
    List<String> directions = ["Down", "Right", "Up", "Left"];
    for(int direction=0; direction<directions.length; direction++) {
      html += "<option value='${direction}'";
      if(moveGameEvent.direction == direction) {
        html += " selected";
      }
      
      html += ">${directions[direction]}</option>";
    }
    html += "</select></td>";
    
    // distance
    html += "    <td><input type='text' class='number' id='${prefix}_distance' value='${moveGameEvent.distance}' /></td>";
    
    html += "  </tr>";
    html += "</table>";
    
    return html;
  }
  
  static String buildDelayGameEventParamsHtml(DelayGameEvent delayGameEvent, String prefix) {
    String html = "";
    
    html += "<table>";
    html += "  <tr><td>Milliseconds</td></tr>";
    html += "  <tr>";
    
    // milliseconds
    html += "    <td><input type='text' class='number' id='${prefix}_milliseconds' value='${delayGameEvent.milliseconds}' /></td>";
    
    html += "  </tr>";
    html += "</table>";
    
    return html;
  }
  
  static String buildFadeGameEventParamsHtml(FadeGameEvent fadeGameEvent, String prefix) {
    String html = "";
    
    html += "<table>";
    html += "  <tr><td>Fade Type</td></tr>";
    html += "  <tr>";
    
    // fade type
    html += "<td><select id='${prefix}_fade_type'>";
    List<String> fadeTypes = ["Normal to white", "White to normal", "Normal to black", "Black to normal"];
    for(int fadeType=0; fadeType<fadeTypes.length; fadeType++) {
      html += "<option value='${fadeType}'";
      if(fadeGameEvent.fadeType == fadeType) {
        html += " selected";
      }
      
      html += ">${fadeTypes.elementAt(fadeType)}</option>";
    }
    html += "</select></td>";
    
    html += "  </tr>";
    html += "</table>";
    
    return html;
  }
}