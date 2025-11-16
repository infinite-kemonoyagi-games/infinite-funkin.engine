package funkin.play.notes.strum;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.play.notes.data.NoteFile;
import funkin.song.data.chart.ChartData.ChartCharacterType;

class StrumLine extends FlxTypedSpriteGroup<StrumNote>
{
    public static final names:Map<Int, Array<String>> =
    [
        2 => ["left", "right"],
        3 => ["left", "down", "right"],
        4 => ["left", "down", "up", "right"]
    ];

    public var notes:Map<String, StrumNote>;

    public var type:ChartCharacterType = null;

    public function new(length:Int, file:NoteFile, type:ChartCharacterType)
    {
        super();

        this.type = type;

        file.notes.sort((a, b) ->
        {
            if (!names[length].contains(a.note))
            {
                file.notes.remove(a);
                return 0;
            }
            return names[length].indexOf(a.note) - names[length].indexOf(b.note);
        });

        notes = new Map();

        var lastNote:StrumNote = null;
        for (index => name in names[length])
        {
            final note:StrumNote = new StrumNote(file.notes[index], file);
            if (lastNote != null) note.x = lastNote.x + (lastNote.width * lastNote.scale.x);
            notes[name] = note;
            add(note);

            lastNote = note;
        }
    }
}