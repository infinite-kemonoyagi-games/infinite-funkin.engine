package funkin.menu;

import flixel.FlxG;
import flixel.FlxSprite;
import funkin.assets.Paths;
import funkin.backend.MusicBeatState;
import funkin.visual.text.FunkinText;

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

        background = new FlxSprite(load.image(Paths.images("menu/menuDesat.png"), true));
        background.color = 0xFFFFD332;
        add(background);

        final text:FunkinText = new FunkinText("Friday Night Funkin' | Infintie Funkin' Engine v0.1.0", 0.4, "bold");
        text.y = FlxG.height - text.height;
        add(text);
    }
}