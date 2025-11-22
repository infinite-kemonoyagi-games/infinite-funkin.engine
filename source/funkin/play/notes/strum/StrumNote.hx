package funkin.play.notes.strum;

import flixel.math.FlxPoint;
import funkin.backend.MusicBeatSprite;
import funkin.play.notes.data.NoteFile;
import funkin.play.ui.NoteSplash;
import funkin.song.data.chart.ChartNoteData.SustainAnimation;
import funkin.utils.CoolUtils;

class StrumNote extends MusicBeatSprite
{
    public var name:String;
    public var data:NoteData;

    public var hold:Bool = false;
    public var animSustain:SustainAnimation;

    public var parent:StrumLine = null;

    public var splash:NoteSplash = null;

    public function new(data:NoteData, file:NoteFile, parent:StrumLine)
    {
        super();

        this.parent = parent;

        final urls:Map<String, String> = CoolUtils.getAnimationURLS(file.spriteType);
        for (anim in data.animations) 
            CoolUtils.loadAnimationFile(this, file.spriteType, anim, urls, new FlxPoint(file.size.x, file.size.y));
        animation.play("static");
    }
}
