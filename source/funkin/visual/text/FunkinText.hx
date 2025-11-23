package funkin.visual.text;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxPool;

class FunkinText extends FlxTypedSpriteGroup<FunkinTextCharacter>
{
    public static var templates:Map<String, FunkinTextCharacter> = [];
    public static var pool(default, null):FlxPool<FunkinTextCharacter> = new FlxPool<FunkinTextCharacter>(function()
    {
        return new FunkinTextCharacter();
    });

    public var text(default, set):String;
    public var size:Float = null;
    public var spaceLength:Float = 1.0;
    public var rowSize:Float = 1.0;

    public var individualAngle:Float = 0.0;

    public function new()
    {
        super();
    }

    @:noCompletion
    function set_text(newValue:String):String
    {
        return text = newValue;
    }
}