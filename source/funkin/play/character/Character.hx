package funkin.play.character;

import flixel.math.FlxPoint;
import funkin.backend.MusicBeatSprite;
import funkin.play.character.data.CharacterFile;
import funkin.utils.CoolUtils;
import haxe.Json;
import openfl.Assets;

class Character extends MusicBeatSprite
{
    public var name:String = null;

    public var isPlayer:Bool = false;

    public var holdTimer:Float = 0.0;
    public var cameraOpt:FlxPoint = null;

    public function new(name:String, isPlayer:Bool)
    {
        this.name = name;
        this.isPlayer = isPlayer;

        super();

        flipX = isPlayer;

        final URL:String = 'assets/data/characters/';
		var file:CharacterFile = cast Json.parse(Assets.getText(URL + '$name.json'));

        cameraOpt = new FlxPoint(file.camera.x, file.camera.y);

        final urls:Map<String, String> = CoolUtils.getAnimationURLS(file.spriteType);
        for (anim in file.animations)
            CoolUtils.loadAnimationFile(this, file.spriteType, anim, urls, new FlxPoint(file.size.x, file.size.y));

        animation.play("idle");

        if (isPlayer)
        {
            animation.rename("singLEFT", "singR");
            animation.rename("singLEFTmiss", "singRmiss");

            animation.rename("singRIGHT", "singLEFT");
            animation.rename("singRIGHTmiss", "singLEFTmiss");
            animation.rename("singR", "singRIGHT");
            animation.rename("singRmiss", "singRIGHTmiss");
        }
    }
}