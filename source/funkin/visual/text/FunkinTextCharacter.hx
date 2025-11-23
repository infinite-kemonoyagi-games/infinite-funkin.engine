package funkin.visual.text;

import funkin.backend.MusicBeatSprite;

class FunkinTextCharacter extends MusicBeatSprite
{
    public var parent:Null<FunkinText> = null;

    public var character:String;
    public var font:String;
    public var size:Int;
    public var row:Int;
    public var lastCharacter(default, null):Null<FunkinTextCharacter> = null;
    public var lastSpaces(default, null):Float = 0.0;
    public var lastRows(default, null):Float = 0.0;

    public function new()
    {
        super();
    }
}