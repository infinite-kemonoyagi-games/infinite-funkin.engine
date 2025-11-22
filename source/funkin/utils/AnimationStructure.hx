package funkin.utils;

import funkin.utils.AnimationFile;

typedef AnimationBasic = 
{
    var name:String;
    var size:PointsObject;
    var spriteType:AnimationTypeFile;
}

typedef AnimationStructure = 
{
    var name:String;
    var size:PointsObject;
    var spriteType:AnimationTypeFile;
    var animations:Array<AnimationFile>;
}
