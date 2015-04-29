library dart_rpg.gui_items_menu;

import 'package:dart_rpg/src/character.dart';
import 'package:dart_rpg/src/choice_game_event.dart';
import 'package:dart_rpg/src/font.dart';
import 'package:dart_rpg/src/game_event.dart';
import 'package:dart_rpg/src/gui.dart';
import 'package:dart_rpg/src/item.dart';
import 'package:dart_rpg/src/item_stack.dart';
import 'package:dart_rpg/src/main.dart';
import 'package:dart_rpg/src/sprite.dart';

class GuiItemsMenu {
  static final double
    textX = 21.0,
    textY = 9.0;
  
  static final int
    itemDescriptionWindowWidth = 9;
  
  static Item selectedItem;
  static Function selectCallback;
  static bool backEnabled = true;
  static bool storeMode = false;
  static Character character;
  
  static Function playerMoneyWindow = () {
    Gui.renderWindow(0, 10, 10, 2);
    Font.renderStaticText(1.0, 21.75, "Money: " + Main.player.inventory.money.toString());
  };
  
  static Function storeMoneyWindow = () {
    Gui.renderWindow(10, 10, 10, 2);
    Font.renderStaticText(1.0, 21.75, "Store: " + Main.player.inventory.money.toString());
  };
  
  static GameEvent selectItem = new GameEvent((Function callback) {
    selectCallback(selectedItem);
  });
  
  static GameEvent items = new GameEvent((Function callback) {
    GameEvent callbackEvent = new GameEvent((Function c){
      callback(null);
    });
    selectCallback = callback;
    
    Map<String, List<GameEvent>> items = new Map<String, List<GameEvent>>();
    for(ItemStack itemStack in character.inventory.itemStacks) {
      String name = itemStack.quantity.toString();
      if(name.length == 1)
        name = "0" + name;
      
      name += " x ";
      name += itemStack.item.name;
      items.addAll({name: [selectItem]});
    }
    
    if(backEnabled) {
      items.addAll({"Back": [callbackEvent]});
    }
    
    ChoiceGameEvent itemChoice;
    Function descriptionWindow;
    
    GameEvent onCancel = new GameEvent((Function a) {
      Gui.removeWindow(descriptionWindow);
      callbackEvent.trigger();
    });
    
    GameEvent onChange = new GameEvent((Function callback) {
      Gui.removeWindow(descriptionWindow);
      
      if(itemChoice.curChoice < character.inventory.itemStacks.length) {
        selectedItem = character.inventory.itemStacks[itemChoice.curChoice].item;
        Sprite curSprite = new Sprite.int(selectedItem.pictureId, 13, 1);
        descriptionWindow = () {
          Gui.renderWindow(10, 0, itemDescriptionWindowWidth, 10);
          
          // TODO: calculate max lines based on window height
          List<String> textLines = Gui.splitText(selectedItem.description, itemDescriptionWindowWidth);
          for(int i=0; i<textLines.length && i<8; i++) {
            Font.renderStaticText(textX, textY + Gui.verticalLineSpacing*i, textLines[i]);
          }
          
          curSprite.renderStaticSized(3, 3);
        };
        
        Gui.addWindow(descriptionWindow);
      }
    });
    
    itemChoice = new ChoiceGameEvent.custom(
        Main.player, items,
        0, 0,
        10, 10,
        onCancel,
        onChange
    );
    
    onChange.trigger();
    
    itemChoice.trigger();
  });
  
  static trigger(Character character, Function callback, [bool backEnabled = true, storeMode = false]) {
    GuiItemsMenu.character = character;
    GuiItemsMenu.backEnabled = backEnabled;
    
    Gui.addWindow(playerMoneyWindow);
    
    GuiItemsMenu.storeMode = storeMode;
    if(storeMode) {
      Gui.addWindow(storeMoneyWindow);
    }
    
    items.callback = callback;
    items.trigger();
  }
}