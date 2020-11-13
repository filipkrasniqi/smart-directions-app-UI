import 'package:flutter/material.dart';

class MapOriginColor {
  List availableColors;
  Map<String, MaterialColor> originColor;
  
  MapOriginColor() {
    originColor = Map<String, MaterialColor>();
    availableColors = [Colors.red, Colors.green, Colors.yellow];
  }
  
  add(String key, [MaterialColor rgb]) {
    if(rgb == null) {
      rgb = availableColors[originColor.length];
    }
    originColor.addAll({key: rgb});
  }

  get(String key) {
    if(!originColor.containsKey(key)) {
      add(key);
    }
    return originColor[key];
  }
  
}