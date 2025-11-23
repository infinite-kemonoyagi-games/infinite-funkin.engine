package funkin.visual.text;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class FunkinText extends FlxTypedSpriteGroup<FunkinTextCharacter>
{
    public static var templates:Map<String, FunkinTextChar> = [];
    public static var pool(default, null):FlxPool<FunkinTextChar> = new FlxPool<FunkinTextChar>(function()
    {
        return new FunkinTextChar();
    });

    public var text(default, set):String;
    public var size:Float = null;
    public var spaceLength(default, set):Float = 1.0;
    public var rowSize(default, set):Float = 1.0;

    public var individualAngle(default, set):Float = 0.0;

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