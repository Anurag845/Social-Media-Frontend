import 'dart:ui';

class Filter {
  String effectId;
  String effectName;
  Color color1;
  Color color2;

  Filter(this.effectId,this.effectName,this.color1,this.color2);
}

class PhotoEffectArgs {
  String imagePath;
  Filter filter;

  PhotoEffectArgs(this.imagePath,this.filter);
}