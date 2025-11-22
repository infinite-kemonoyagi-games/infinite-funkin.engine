package funkin.play.notes;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import funkin.backend.MusicBeatSprite;
import funkin.backend.MusicBeatState;
import funkin.play.notes.data.NoteFile;
import funkin.song.data.chart.ChartData.ChartCharacterType;
import funkin.song.data.chart.ChartNoteData;
import funkin.utils.CoolUtils;

class NoteBase extends MusicBeatSprite
{
	public static final hitboxFrames:Int = 10;
	public static final safeHitbox:Float = (hitboxFrames / 60) * 1000;

    public var name:String = "left";
    public var position:Float = 0.0;
    public var length:Float = 0.0;

    public var character:String = "bf";
    public var type:ChartCharacterType = null;

    public var alt:Bool = false;
    public var data:String = "";
    public var skin:String = "";

    public var speed:Float = 0.0;
    public var speedMode:NoteSpeedMode = null;

    public var globalSpeed:Float = 0.0;

    public var chart:ChartNoteData = null;

    public var file:NoteFile;
    public var info:NoteData;

    public var inEditor:Bool = false;
    public var reference:Null<FlxSprite> = null;

    public var state:MusicBeatState = null;

    public var killed:Bool = false;

    public var pressed:Bool = false;

    public var mustBeHit(get, never):Bool;
    public var canBeHit(get, never):Bool;
    public var wasTooLate(get, never):Bool;

    public var missed:Bool = false;

    public function new(chart:ChartNoteData, file:NoteFile, info:NoteData, inEditor:Bool)
    {
        super();

        active = visible = false;

        this.chart = chart;
        this.file = file;
        this.info = info;
        this.inEditor = inEditor;

        name = chart.name;
        position = chart.position;
        length = chart.length;
        character = chart.character;
        type = chart.type;
        alt = chart.alt;
        data = chart.data;
        skin = chart.skin;
        speed = chart.speed;
        speedMode = chart.speedMode;

        switch name
        {
            case "left": ID = 0;
            case "down": ID = 1;
            case "up": ID = 2;
            case "right": ID = 3;
        }

        final urls:Map<String, String> = CoolUtils.getAnimationURLS(file.spriteType);
        for (anim in info.animations) 
            CoolUtils.loadAnimationFile(this, file.spriteType, anim, urls, new FlxPoint(file.size.x, file.size.y));
    }

    public override function kill():Void
    {
        killed = true;
        super.kill();
    }

    public override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (inEditor) return;

        if (!visible) visible = true;
        
        var speed:Float = getCurrentSpeed();

        x = reference.x - ((width - reference.width) / 2);

        y = reference.y + (position - state.conductor.position) * (0.45 * FlxMath.roundDecimal(speed, 2));
    }

    private function getCurrentSpeed():Float
    {
        var speed:Float = 0.0;
        if (this.speed != 0)
            if (speedMode != null && speedMode == MULT)
                speed = globalSpeed * this.speed;
            else
                speed = this.speed;
        else speed = globalSpeed;

        return speed;
    }

    private function get_mustBeHit():Bool return position <= state.conductor.position;

    private function get_canBeHit():Bool 
        return position > state.conductor.position - NoteBase.safeHitbox
                && position < state.conductor.position + NoteBase.safeHitbox;

    private function get_wasTooLate():Bool 
        return position < state.conductor.position - NoteBase.safeHitbox;
}