package funkin.menu;

import flixel.FlxSprite;
import funkin.backend.MusicBeatState;

class MenuState extends MusicBeatState
{
    private static var selected:Int = 0;

    private var options:Array<String> = [
        "storymode",
        "freeplay",
        "options",
        "credits"
    ];

    private var background:FlxSprite = null;

    public function new()
    {
        super();
    }

    public override function create():Void
    {
        super.create();

        background = new FlxSprite("assets/images/menu/menuDesat.png");
        background.color = 0xFFFFD332;
        add(background);
    }
}