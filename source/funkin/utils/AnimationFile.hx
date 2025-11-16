package funkin.utils;

import funkin.utils.PointsObject;

typedef AnimationFile = 
{
    var path:String;
    var ?size:Null<PointsObject>;
    var name:String;
    var ?prefix:Null<String>;
    var ?frames:Null<Array<Int>>;
    var framerate:Int;
    var looped:Bool;
    var flip:PointsObjectBoolean;
    var offsets:PointsObject;
    var ?centerOffsets:Null<Bool>;
}
