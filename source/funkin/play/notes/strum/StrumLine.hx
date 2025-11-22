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

    public var character:String;
    public var type:ChartCharacterType = null;

    public var botplay:Bool = false;

    public function new(length:Int, file:NoteFile, character:String, type:ChartCharacterType)
    {
        super();

        this.character = character;
        this.type = type;
        botplay = type != PLAYER;

        file.notes = file.notes.filter(item -> names[length].contains(item.note));

        notes = new Map();

        var lastNote:StrumNote = null;
        for (index => name in names[length])
        {
            final note:StrumNote = new StrumNote(file.notes[index], file, this);
            note.ID = index;
            if (lastNote != null) note.x = lastNote.x + (lastNote.width * lastNote.scale.x);
            notes[name] = note;
            add(note);

            lastNote = note;
        }
    }
}