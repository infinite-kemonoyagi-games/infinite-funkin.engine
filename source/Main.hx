package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import funkin.assets.FunkinAssets;
import funkin.menu.MenuState;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var assets(default, null):FunkinAssets;

	public function new()
	{
		super();
		
		addChild(new FlxGame());

		assets = new FunkinAssets();

		FlxG.fixedTimestep = false;
		FlxSprite.defaultAntialiasing = true;

		FlxG.switchState(() -> new MenuState());
	}
}
