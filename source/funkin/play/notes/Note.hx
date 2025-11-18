package funkin.play.notes;

import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.backend.MusicBeatState;
import funkin.play.notes.data.NoteFile;
import funkin.play.notes.strum.StrumLine;
import funkin.play.notes.strum.StrumNote;
import funkin.song.data.chart.ChartNoteData;

class Note extends NoteBase
{
    public var strumline:StrumLine = null;
    public var strumnote(get, never):StrumNote;

    public var sustain:Null<Sustain> = null;

    public function new(chart:ChartNoteData, file:NoteFile, info:NoteData, state:MusicBeatState, inEditor:Bool)
    {
        super(chart, file, info, inEditor);

        this.state = state;

        animation.play("note");

        if (length > 0)
        {
            sustain = new Sustain(this);
            sustain.state = state;
        }
    }

    public function waitingToSpawn(unspawnedNotes:Array<Note>, onSpawned:() -> Void):Void
    {
        if (inEditor) return;
        var speed:Float = getCurrentSpeed();
        if (unspawnedNotes.length > 0 && position - state.conductor.position < (3000 / speed))
		{
            onSpawned();
            unspawnedNotes.remove(this);
		}
    }

    public function spawn(strumline:StrumLine, notes:FlxTypedGroup<Note>, sustains:FlxTypedGroup<Sustain>):Void
    {
        this.strumline = strumline;
        reference = strumnote;

        active = visible = true;
        notes.add(this);

        y = -height - camera.y;

        if (sustain != null) sustain.spawn(sustains);
    }


    @:noCompletion
    private function get_strumnote():StrumNote
    {
        if (strumline != null && strumline.notes != null)
        {
            return strumline.notes[name];
        }
        return null;
    }
}