package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import funkin.menu.MenuState;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		addChild(new FlxGame());

		FlxG.fixedTimestep = false;
		FlxSprite.defaultAntialiasing = true;

		FlxG.switchState(() -> new MenuState());
	}
}
