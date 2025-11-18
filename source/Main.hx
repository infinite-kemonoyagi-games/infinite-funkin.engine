package;

import flixel.FlxG;
import flixel.FlxGame;
import funkin.play.PlayState;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		addChild(new FlxGame());

		FlxG.fixedTimestep = false;

		FlxG.switchState(() -> new PlayState("bopeebo", "normal"));
	}
}
