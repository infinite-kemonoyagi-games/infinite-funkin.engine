package funkin.play.notes.strum;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class StrumLineManager extends FlxTypedSpriteGroup<StrumLine>
{
    public var strumlines:Map<String, StrumLine>;

    public function new()
    {
        super();
        strumlines = [];
    }

    public override function add(Sprite:StrumLine):StrumLine
    {
        strumlines[Sprite.character] = Sprite;

        return super.add(Sprite);
    }

    public override function remove(sprite:StrumLine, splice:Bool = false):StrumLine
    {
        strumlines.remove(sprite.character);

        return super.remove(sprite, splice);
    }
}