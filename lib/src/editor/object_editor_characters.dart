library dart_rpg.object_editor_characters;

import 'dart:async';
import 'dart:html';

import 'package:dart_rpg/src/battler.dart';
import 'package:dart_rpg/src/battler_type.dart';
import 'package:dart_rpg/src/character.dart';
import 'package:dart_rpg/src/inventory.dart';
import 'package:dart_rpg/src/store_character.dart';
import 'package:dart_rpg/src/world.dart';

import 'package:dart_rpg/src/game_event/game_event.dart';
import 'package:dart_rpg/src/game_event/text_game_event.dart';

import 'editor.dart';
import 'object_editor.dart';
import 'object_editor_game_events.dart';

// TODO: add delete buttons for game events
// TODO: make all inputs with class number take out any non 0-9 characters

class ObjectEditorCharacters {
  static List<String> advancedTabs = ["character_inventory", "character_game_event", "character_battle", "character_store"];
  static Map<String, StreamSubscription> listeners = {};
  static int selected;
  
  // TODO: change more query selectors to Editor.getValue
  // TODO: update when adding new things
  
  static void setUp() {
    Editor.setUpTabs(advancedTabs);
    querySelector("#add_character_button").onClick.listen(addNewCharacter);
    querySelector("#add_inventory_item_button").onClick.listen(addInventoryItem);
    querySelector("#add_game_event_button").onClick.listen(addGameEvent);
  }
  
  static void addNewCharacter(MouseEvent e) {
    Character newCharacter = new Character(
      0, 0, 0, 0,
      layer: World.LAYER_BELOW,
      sizeX: 1, sizeY: 2,
      solid: true
    );
    
    BattlerType battlerType = World.battlerTypes.values.first;
    
    newCharacter.battler = new Battler(battlerType.name, battlerType, 2, battlerType.levelAttacks.values.toList());
    
    World.characters["New Character"] = newCharacter;
    
    update();
    ObjectEditor.update();
  }
  
  static void addInventoryItem(MouseEvent e) {
    Character selectedCharacter = World.characters.values.elementAt(selected);
    for(int i=0; i<World.items.keys.length; i++) {
      if(!selectedCharacter.inventory.itemNames().contains(World.items.keys.elementAt(i))) {
        // add the first possible item that is not already in the character's inventory
        selectedCharacter.inventory.addItem(World.items.values.elementAt(i));
        break;
      }
    }
    
    update();
    ObjectEditor.update();
  }
  
  static void addGameEvent(MouseEvent e) {
    Character selectedCharacter = World.characters.values.elementAt(selected);
    
    selectedCharacter.gameEvents.add(
        new TextGameEvent(1, "Text")
    );
    
    update();
    ObjectEditor.update();
  }
  
  static void update() {
    buildMainHtml();
    buildInventoryHtml();
    buildGameEventHtml();
    buildBattleHtml();
    buildStoreHtml();
    
    // TODO: add inventory, game event, and post battle event to right half
    
    // highlight the selected row
    if(querySelector("#character_row_${selected}") != null) {
      querySelector("#character_row_${selected}").classes.add("selected");
      querySelector("#characters_advanced").classes.remove("hidden");
    }
    
    Editor.setMapDeleteButtonListeners(World.characters, "character", listeners);
    
    for(int i=0; i<World.characters.keys.length; i++) {
      Editor.setMapDeleteButtonListeners(World.characters.values.elementAt(i).inventory.itemStacks, "character_${i}_item", listeners);
      
      Editor.setListDeleteButtonListeners(World.characters.values.elementAt(i).gameEvents, "character_${i}_game_event", listeners);
    }
    
    List<String> attrs = [
      // main
      "label", "name", "sprite_id", "picture_id", "size_x", "size_y",
      
      // battle
      "battler_type", "battler_level", "sight_distance", "pre_battle_text"
      
      //
      /* inventory, game_event */
      /* post battle event */
    ];
    
    List<String> inventory_attrs = [
      "inventory_item", "inventory_quantity"
    ];
    
    for(int i=0; i<World.characters.keys.length; i++) {
      Editor.attachListeners(listeners, "character_${i}", attrs, onInputChange);
      
      // when a row is clicked, set it as selected and highlight it
      querySelector("#character_row_${i}").onClick.listen((Event e) {
        selected = i;
        
        for(int j=0; j<World.characters.keys.length; j++) {
          // un-highlight other character rows
          querySelector("#character_row_${j}").classes.remove("selected");
          
          // hide the inventory items for other characters
          querySelector("#character_${j}_inventory_table").classes.add("hidden");
          querySelector("#character_${j}_game_event_table").classes.add("hidden");
          querySelector("#character_${j}_battle_container").classes.add("hidden");
          querySelector("#character_${j}_store_container").classes.add("hidden");
        }
        
        // hightlight the selected character row
        querySelector("#character_row_${i}").classes.add("selected");
        
        // show the characters advanced area
        querySelector("#characters_advanced").classes.remove("hidden");
        
        // show the advanced tables for the selected character
        querySelector("#character_${i}_inventory_table").classes.remove("hidden");
        querySelector("#character_${i}_game_event_table").classes.remove("hidden");
        querySelector("#character_${i}_battle_container").classes.remove("hidden");
        querySelector("#character_${i}_store_container").classes.remove("hidden");
      });
      
      Character character = World.characters.values.elementAt(i);
      
      List<String> inputIds = [];
      
      for(int j=0; j<character.inventory.itemNames().length; j++) {
        for(String inventory_attr in inventory_attrs) {
          String elementSelector = "#character_${i}_${inventory_attr}_${j}";
          inputIds.add(elementSelector);
        }
      }
      
      // game events
      for(int j=0; j<character.gameEvents.length; j++) {
        List<String> gameEventAttrs = ["type"];
        
        gameEventAttrs.addAll(ObjectEditorGameEvents.getAttributes(character.gameEvents[j]));
        
        // TODO: fix this
        Editor.attachListeners(listeners, "character_${i}_game_event_${j}", gameEventAttrs, onInputChange);
      }
      
      for(String inputId in inputIds) {
        if(listeners[inputId] != null) {
          listeners[inputId].cancel();
        }
        
        listeners[inputId] = querySelector(inputId).onInput.listen(onInputChange);
      }
    }
  }
  
  static void buildMainHtml() {
    String charactersHtml = "<table class='editor_table'>"+
      "  <tr>"+
      "    <td>Num</td>"+
      "    <td>Label</td>"+
      "    <td>Name</td>"+
      "    <td>Sprite Id</td>"+
      "    <td>Picture Id</td>"+
      "    <td>Size X</td>"+
      "    <td>Size Y</td>"+
      "    <td></td>"+
      "  </tr>";
    
    for(int i=0; i<World.characters.keys.length; i++) {
      String key = World.characters.keys.elementAt(i);
      
      charactersHtml +=
        "<tr id='character_row_${i}'>"+
        "  <td>${i}</td>"+
        "  <td><input id='character_${i}_label' type='text' value='${ key }' /></td>"+
        "  <td><input id='character_${i}_name' type='text' value='${ World.characters[key].name }' /></td>"+
        "  <td><input id='character_${i}_sprite_id' type='text' class='number' value='${ World.characters[key].spriteId }' /></td>"+
        "  <td><input id='character_${i}_picture_id' type='text' class='number' value='${ World.characters[key].pictureId }' /></td>"+
        "  <td><input id='character_${i}_size_x' type='text' class='number' value='${ World.characters[key].sizeX }' /></td>"+
        "  <td><input id='character_${i}_size_y' type='text' class='number' value='${ World.characters[key].sizeY }' /></td>"+
        "  <td><button id='delete_character_${i}'>Delete</button></td>"+
        "</tr>";
    }
    
    charactersHtml += "</table>";
    
    querySelector("#characters_container").setInnerHtml(charactersHtml);
  }
  
  static void buildInventoryHtml() {
    String inventoryHtml = "";
    
    for(int i=0; i<World.characters.keys.length; i++) {
      String visibleString = "class='hidden'";
      if(selected == i) {
        visibleString = "";
      }
      
      inventoryHtml += "<table id='character_${i}_inventory_table' ${visibleString}>";
      inventoryHtml += "<tr><td>Num</td><td>Item</td><td>Quantity</td><td></td></tr>";
      Character character = World.characters.values.elementAt(i);
      for(int j=0; j<character.inventory.itemNames().length; j++) {
        String curItemName = character.inventory.itemNames().elementAt(j);
        inventoryHtml += "<tr>";
        inventoryHtml += "  <td>${j}</td>";
        inventoryHtml += "  <td><select id='character_${i}_inventory_item_${j}'>";
        World.items.keys.forEach((String itemOptionName) {
          String selectedString = "";
          
          if(itemOptionName != curItemName && character.inventory.itemNames().contains(itemOptionName)) {
            // don't show items that are already somewhere else in the character's inventory
            return;
          }
          
          if(itemOptionName == curItemName) {
            selectedString = "selected=\"selected\"";
          }
          inventoryHtml += "<option ${selectedString}>${itemOptionName}</option>";
        });
        inventoryHtml += "  </select></td>";
        inventoryHtml += "  <td><input id='character_${i}_inventory_quantity_${j}' type='text' class='number' value='${character.inventory.getQuantity(curItemName)}' /></td>";
        inventoryHtml += "  <td><button id='delete_character_${i}_item_${j}'>Delete</button></td>";
        inventoryHtml += "</tr>";
      }
      
      inventoryHtml += "</table>";
    }
    
    querySelector("#inventory_container").setInnerHtml(inventoryHtml);
  }
  
  static void buildGameEventHtml() {
    String gameEventHtml = "";
    
    for(int i=0; i<World.characters.keys.length; i++) {
      String visibleString = "class='hidden'";
      if(selected == i) {
        visibleString = "";
      }
      
      Character character = World.characters.values.elementAt(i);
      
      gameEventHtml += "<table id='character_${i}_game_event_table' ${visibleString}>";
      gameEventHtml += "<tr><td>Num</td><td>Event Type</td><td>Params</td><td></td></tr>";
      for(int j=0; j<character.gameEvents.length; j++) {
        gameEventHtml += ObjectEditorGameEvents.buildGameEventTableRowHtml(character.gameEvents[j], "character_${i}_game_event_${j}", j);
      }
      
      gameEventHtml += "</table>";
    }
    
    querySelector("#game_event_container").setInnerHtml(gameEventHtml);
  }
  
  static void buildBattleHtml() {
    String battleHtml = "";
    
    for(int i=0; i<World.characters.keys.length; i++) {
      String visibleString = "class='hidden'";
      if(selected == i) {
        visibleString = "";
      }
      
      Character character = World.characters.values.elementAt(i);
      
      battleHtml += "<table id='character_${i}_battle_container' ${visibleString}>";
      battleHtml += "<tr><td>Battler Type</td><td>Level</td><td>Sight Distance</td><td>Pre Battle Text</td></tr>";
      
      battleHtml += "<tr><td><select id='character_${i}_battler_type'>";
      World.battlerTypes.forEach((String name, BattlerType battlerType) {
        battleHtml += "<option value='${battlerType.name}'";
        if(character.battler.battlerType.name == name) {
          battleHtml += " selected";
        }
        
        battleHtml += ">${battlerType.name}</option>";
      });
      battleHtml += "</select></td>";
      
      battleHtml += "<td><input id='character_${i}_battler_level' type='text' class='number' value='${character.battler.level}' /></td>";
      battleHtml += "<td><input id='character_${i}_sight_distance' type='text' class='number' value='${character.sightDistance}' /></td>";
      battleHtml += "<td><textarea id='character_${i}_pre_battle_text'>${character.preBattleText}</textarea></td>";
      
      battleHtml += "</tr></table>";
    }
    
    querySelector("#battle_container").setInnerHtml(battleHtml);
  }
  
  static void buildStoreHtml() {
    String battleHtml = "";
    
    for(int i=0; i<World.characters.keys.length; i++) {
      String visibleString = "class='hidden'";
      if(selected == i) {
        visibleString = "";
      }
      
      Character character = World.characters.values.elementAt(i);
      
      String helloMessage = "", goodbyeMessage = "";
      
      if(character is StoreCharacter) {
        helloMessage = character.helloMessage;
        goodbyeMessage = character.goodbyeMessage;
      }
      
      // TODO: disable inputs if character is not a store character
      // TODO: discount field?
      // TODO: checkbox to enable store character
      // TODO: onInputChange
      
      battleHtml += "<table id='character_${i}_store_container' ${visibleString}>";
      battleHtml += "<tr><td>Hello Message</td><td>Goodbye Message</td></tr>";
      battleHtml += "<td><input id='character_${i}_store_hello_message' type='text' value='${helloMessage}' /></td>";
      battleHtml += "<td><input id='character_${i}_store_goodbye_message' type='text' value='${goodbyeMessage}' /></td>";
      battleHtml += "</tr>";
      battleHtml += "</table>";
    }
    
    querySelector("#store_container").setInnerHtml(battleHtml);
  }
  
  static void onInputChange(Event e) {
    if(e.target is InputElement) {
      InputElement target = e.target;
      
      if(target.id.contains("_label") && World.characters.keys.contains(target.value)) {
        // avoid name collisions
        int i = 0;
        for(; World.characters.keys.contains(target.value + "_${i}"); i++) {}
        target.value += "_${i}";
      } else {
        List<String> numberFields = [
          "sprite_id", "picture_id", "battler_level",
          "size_x", "size_y",
          "sight_distance", "character_power_"
        ];
        
        numberFields.forEach((String field) {
          if(target.id.contains(field)) {
            // enforce number format
            target.value = target.value.replaceAll(new RegExp(r'[^0-9]'), "");
          }
        });
      }
    }
    
    World.characters = new Map<String, Character>();
    for(int i=0; querySelector('#character_${i}_label') != null; i++) {
      try {
        Character character = new Character(
          Editor.getTextInputIntValue('#character_${i}_sprite_id', 1),
          Editor.getTextInputIntValue('#character_${i}_picture_id', 1),
          0, 0,
          layer: World.LAYER_BELOW,
          sizeX: Editor.getTextInputIntValue('#character_${i}_size_x', 1),
          sizeY: Editor.getTextInputIntValue('#character_${i}_size_y', 2),
          solid: true
        );
        
        character.name = Editor.getTextInputStringValue('#character_${i}_name');
        
        String battlerTypeName = Editor.getSelectInputStringValue('#character_${i}_battler_type');
        
        // TODO: add battler name field
        Battler battler = new Battler(
          "name",
          World.battlerTypes[battlerTypeName],
          Editor.getTextInputIntValue('#character_${i}_battler_level', 2),
          World.battlerTypes[battlerTypeName].levelAttacks.values.toList()
        );
        
        character.battler = battler;
        character.sightDistance = Editor.getTextInputIntValue('#character_${i}_sight_distance', 0);
        character.preBattleText = Editor.getTextAreaStringValue('#character_${i}_pre_battle_text');
        // post battle event
        
        String label = Editor.getTextInputStringValue('#character_${i}_label');
        World.characters[label] = character;
      } catch(e) {
        // could not update this character
        print("Error updating character: " + e.toString());
      }
    }
    
    for(int i=0; i<World.characters.keys.length; i++) {
      Character character = World.characters.values.elementAt(i);
      character.inventory = new Inventory([]);
      
      for(int j=0; querySelector('#character_${i}_inventory_item_${j}') != null; j++) {
        String itemName = (querySelector('#character_${i}_inventory_item_${j}') as SelectElement).value;
        int itemQuantity = int.parse((querySelector('#character_${i}_inventory_quantity_${j}') as TextInputElement).value);
        character.inventory.addItem(World.items[itemName], itemQuantity);
      }
      
      character.gameEvents = new List<GameEvent>();
      for(int j=0; querySelector('#character_${i}_game_event_${j}_type') != null; j++) {
        character.gameEvents.add(
            ObjectEditorGameEvents.buildGameEvent("character_${i}_game_event_${j}", character)
          );
      }
    }
    
    Editor.updateAndRetainValue(e);
  }
  
  static void export(Map<String, Object> exportJson) {
    Map<String, Map<String, String>> charactersJson = {};
    World.characters.forEach((String key, Character character) {
      Map<String, Object> characterJson = {};
      characterJson["spriteId"] = character.spriteId.toString();
      characterJson["pictureId"] = character.pictureId.toString();
      characterJson["sizeX"] = character.sizeX.toString();
      characterJson["sizeY"] = character.sizeY.toString();
      characterJson["name"] = character.name;
      
      // inventory
      List<Map<String, String>> inventoryJson = [];
      character.inventory.itemNames().forEach((String itemName) {
        Map<String, String> itemJson = {};
        itemJson["item"] = itemName;
        itemJson["quantity"] = character.inventory.getQuantity(itemName).toString();
        
        inventoryJson.add(itemJson);
      });
      
      characterJson["inventory"] = inventoryJson;
      
      // game event
      List<Map<String, String>> gameEventsJson = [];
      character.gameEvents.forEach((GameEvent gameEvent) {
        gameEventsJson.add(
            ObjectEditorGameEvents.buildGameEventJson(gameEvent)
          );
      });
      
      characterJson["gameEvents"] = gameEventsJson;
      
      // battle
      characterJson["battlerType"] = character.battler.battlerType.name;
      characterJson["battlerLevel"] = character.battler.level.toString();
      characterJson["sightDistance"] = character.sightDistance.toString();
      characterJson["preBattleText"] = character.preBattleText;
      // TODO: post battle event
      
      charactersJson[key] = characterJson;
    });
    
    exportJson["characters"] = charactersJson;
  }
}