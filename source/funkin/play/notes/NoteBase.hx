package funkin.play.notes;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import funkin.backend.MusicBeatSprite;
import funkin.backend.MusicBeatState;
import funkin.play.notes.data.NoteFile;
import funkin.song.data.chart.ChartData.ChartCharacterType;
import funkin.song.data.chart.ChartNoteData;

class NoteBase extends MusicBeatSprite
{
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

    public var pressed:Bool = false;

    public var mustBeHit(get, never):Bool;

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

        final urls:Map<String, String> = [];
        for (url in file.spriteType.urls)
        {
            urls[url.id] = url.path;
        }

        name = info.note;
        for (anim in info.animations)
        {
            switch file.spriteType.id
            {
                case "default":
                    final frame:FlxGraphicAsset = urls[anim.path] + '.png';
                    final tex = FlxTileFrames.fromGraphic(frame, FlxPoint.get(anim.size.x, anim.size.y));
                    getComplexAnim().createFrame(anim.path, tex);
                    getComplexAnim().setAnimToFrame(anim.name, anim.path);

                    getComplexAnim().add(anim.name, anim.frames, anim.framerate, anim.looped, 
                        anim.flip.x, anim.flip.y);
                    getComplexAnim().setOffsets(anim.name, anim.offsets.x, 
                        anim.offsets.y, anim?.centerOffsets ?? false);
                case "sparrow":
                    final frame:String = urls[anim.path];
                    final tex = FlxAtlasFrames.fromSparrow(frame + ".png", frame + ".xml");
                    tex.parent.persist = true;
                    getComplexAnim().createFrame(anim.path, tex);
                    getComplexAnim().setAnimToFrame(anim.name, anim.path);

                    if (anim.frames == null)
                    {
                        getComplexAnim().addByPrefix(anim.name, anim.prefix, 
                            anim.framerate, anim.looped, anim.flip.x, anim.flip.y);
                    }
                    else
                    {
                        getComplexAnim().addByIndices(anim.name, anim.prefix, anim.frames, 
                            "", anim.framerate, anim.looped, anim.flip.x, anim.flip.y);
                    }
                    getComplexAnim().setOffsets(anim.name, anim.offsets.x, 
                        anim.offsets.y, anim?.centerOffsets ?? false);
            }
        }
        scale.set(file.size.x, file.size.y);
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
}