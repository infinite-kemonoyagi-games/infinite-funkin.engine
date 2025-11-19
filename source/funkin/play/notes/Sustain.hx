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

        alpha = 0.6;

        animation.play("sustain");
        updateHitbox();

        tail = new NoteBase(parent.chart, parent.file, parent.info, parent.inEditor);
        tail.state = state;
        tail.length = 0.0;
        tail.position += length;
        tail.alpha = 0.6;
        tail.animation.play("sustain-end");
    }

    public function spawn(sustains:FlxTypedGroup<Sustain>):Void
    {
        strumline = parent.strumline;

        reference = strumnote;
        tail.reference = strumnote;

        active = true;
        tail.active = true;

        globalSpeed = parent.globalSpeed;
        tail.globalSpeed = globalSpeed;

        sustains.add(this);
    }

    public override function kill():Void
    {
        super.kill();
        tail.kill();
    }

    public override function destroy():Void
    {
        super.destroy();
        tail.destroy();
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

        final sub = (parent?.height ?? 0) / 2;
        final len = length * (0.45 * getCurrentSpeed());

        setGraphicSize(width, (len - sub) + 10);
        updateHitbox();
        y += sub;
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