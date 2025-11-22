package funkin.play.ui;

import flixel.math.FlxPoint;
import funkin.backend.MusicBeatSprite;
import funkin.play.notes.data.NoteFile;
import funkin.play.notes.strum.StrumNote;
import funkin.utils.CoolUtils;
import haxe.Json;
import openfl.Assets;

class NoteSplash extends MusicBeatSprite
{
    public var skin:String = "";
    public var parent:StrumNote = null;

    private var _visible:Bool = false;

    public function new(skin:String, name:String, parent:StrumNote):Void 
    {
        super();

        this.parent = parent;
        this.parent.splash = this;
        this.skin = skin;

        final URL:String = 'assets/data/note/splash/';
		var file:NoteFile = cast Json.parse(Assets.getText(URL + '$skin.json'));

        for (note in file.notes)
        {
            if (note.note == name)
            {
                final urls:Map<String, String> = CoolUtils.getAnimationURLS(file.spriteType);
                for (anim in note.animations) 
                    CoolUtils.loadAnimationFile(this, file.spriteType, anim, urls, new FlxPoint(file.size.x, file.size.y));
            }
        }
        animation.play("splash");
    }

    public override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        x = parent.x - ((width - parent.width) / 2);
        y = parent.y - ((height - parent.height) / 2);
        visible = !animation.finished && animation.curAnim != null && _visible;
    }

    public function splash():Void
    {
        animation.play("splash", true);
        _visible = true;
    }
}