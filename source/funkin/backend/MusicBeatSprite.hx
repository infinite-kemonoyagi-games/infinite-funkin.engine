package funkin.backend;

import flixel.FlxSprite;
import flixel.animation.FlxAnimationController;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;

class MusicBeatSprite extends FlxSprite
{
    public function new()
    {
        super();
        animation = new MusicBeatAnimation(this);
    }

    public function getComplexAnimation():MusicBeatAnimation
        return cast(animation, MusicBeatAnimation);
}

class MusicBeatAnimation extends FlxAnimationController
{
    public var offsets:Map<String, Array<Dynamic>>;
    public var framesAnimation:Map<String, FlxFrame>;
    public var frames:Map<String, FlxFrame>;

    public function new(sprite:FlxSprite)
    {
        offsets = [];
        frames = [];
        super(sprite);
    }

    public function createFrame(id:String, frame:FlxFrame):Void
    {
        frames[id] = frame;
    }

    public function setAnimToFrame(animation:String, frameID:String):Void
    {
        framesAnimation[animation] = frames[frameID];
    }

    public function setOffsets(animation:String, x:Float, y:Float, ?centerOffsets:Bool = false):Void
    {
        offsets[animation].push([new FlxPoint(x, y), centerOffsets]);
    }

    public override function add(name:String, frames:Array<Int>, 
        framerate:Float = 30.0, looped:Bool = true, flipX:Bool = false, flipY:Bool = false):Void
    {
        var oldFrame:FlxFrame = null;

        if (framesAnimation.exists(name))
        {
            oldFrame = _sprite.frame;
            _sprite.frame = framesAnimation[name];
        }

        super.add(name, frames, framerate, looped, flipX, flipY);

        _sprite.frame = oldFrame;
    }

    public override function addByPrefix(name:String, prefix:String, 
        frameRate:Float = 30.0, looped:Bool = true, flipX:Bool = false, flipY:Bool = false):Void
    {
        var oldFrame:FlxFrame = null;

        if (framesAnimation.exists(name))
        {
            oldFrame = _sprite.frame;
            _sprite.frame = framesAnimation[name];
        }

        super.addByPrefix(name, prefix, frameRate, looped, flipX, flipY);

        _sprite.frame = oldFrame;
    }

    public override function addByIndices(Name:String, Prefix:String, 
        Indices:Array<Int>, Postfix:String, FrameRate:Float = 30, Looped:Bool = true, 
        FlipX:Bool = false, FlipY:Bool = false):Void
    {
        var oldFrame:FlxFrame = null;

        if (framesAnimation.exists(name))
        {
            oldFrame = _sprite.frame;
            _sprite.frame = framesAnimation[name];
        }

        super.addByIndices(Name, Prefix, Indices, Postfix, FrameRate, Looped, FlipX, FlipY);

        _sprite.frame = oldFrame;
    }

    public override function play(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void
    {
        if (framesAnimation.exists(animName))
            _sprite.frame = framesAnimation[name];

        super.play(animName, force, reversed, frame);

        if (offsets.exists(animName))
        {
            if (offsets[animName][1]) _sprite.centerOffsets();
            _sprite.offset.x += offsets[animName][0].x;
            _sprite.offset.y += offsets[animName][0].y;
        }
    }
}
