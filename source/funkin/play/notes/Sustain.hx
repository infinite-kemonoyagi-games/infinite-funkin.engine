package funkin.play.notes;

import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.play.notes.strum.StrumLine;
import funkin.play.notes.strum.StrumNote;

class Sustain extends NoteBase
{
    public var strumline:StrumLine = null;
    public var strumnote(get, never):StrumNote;

    public var parent:Note;
    public var tail:NoteBase;

    public function new(parent:Note)
    {
        super(parent.chart, parent.file, parent.info, parent.inEditor);

        this.state = parent.state;
        this.parent = parent;

        animation.play("sustain");

        tail = new NoteBase(parent.chart, parent.file, parent.info, parent.inEditor);
        tail.state = state;
        tail.length = 0.0;
        tail.position += length;
        tail.animation.play("sustain-end");
    }

    public function spawn(sustains:FlxTypedGroup<Sustain>):Void
    {
        strumline = parent.strumline;

        reference = parent.reference;
        tail.reference = parent.reference;

        active = visible = true;
        tail.active = tail.visible = true;

        globalSpeed = parent.globalSpeed;
        tail.globalSpeed = globalSpeed;

        y = -height;
        tail.y = -tail.height;

        sustains.add(this);
    }

    public override function draw():Void
    {
        super.draw();
        if (tail.visible) tail.draw();
    }

    public override function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (tail.active) tail.update(elapsed);
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