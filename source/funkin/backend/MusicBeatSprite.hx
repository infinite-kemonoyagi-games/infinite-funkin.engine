package funkin.backend;

import flixel.FlxSprite;
import flixel.animation.FlxAnimationController;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;

class MusicBeatSprite extends FlxSprite
{
    public function new()
    {
        super();
        animation = new MusicBeatAnimation(this);
    }

    public function getComplexAnim():MusicBeatAnimation
        return cast(animation, MusicBeatAnimation);
}

class MusicBeatAnimation extends FlxAnimationController
{
    public var offsets:Map<String, Array<Dynamic>>;
    public var framesAnimation:Map<String, FlxFramesCollection>;
    public var frames:Map<String, FlxFramesCollection>;

    public function new(sprite:FlxSprite)
    {
        offsets = [];
        frames = [];
        framesAnimation =[];
        super(sprite);
    }

    public function createFrame(id:String, frames:FlxFramesCollection):Void
    {
        this.frames[id] = frames;
    }

    public function setAnimToFrame(animation:String, frameID:String):Void
    {
        framesAnimation[animation] = frames[frameID];
    }

    public function setOffsets(animation:String, x:Float, y:Float, ?centerOffsets:Bool = false):Void
    {
        if (offsets[animation] == null) offsets[animation] = [];
        offsets[animation].push(new FlxPoint(x, y));
        offsets[animation].push(centerOffsets);
    }

    public override function add(name:String, frames:Array<Int>, 
        framerate:Float = 30.0, looped:Bool = true, flipX:Bool = false, flipY:Bool = false):Void
    {
        var oldFrame:FlxFramesCollection = null;

        if (framesAnimation.exists(name))
        {
            oldFrame = _sprite.frames;
            _sprite.setFrames(framesAnimation[name], true);
        }

        super.add(name, frames, framerate, looped, flipX, flipY);

        if (framesAnimation.exists(name) && oldFrame != null) _sprite.setFrames(oldFrame, true);
    }

    public override function addByPrefix(name:String, prefix:String, 
        frameRate:Float = 30.0, looped:Bool = true, flipX:Bool = false, flipY:Bool = false):Void
    {
        var oldFrame:FlxFramesCollection = null;

        if (framesAnimation.exists(name))
        {
            oldFrame = _sprite.frames;
            _sprite.setFrames(framesAnimation[name], true);
        }

        super.addByPrefix(name, prefix, frameRate, looped, flipX, flipY);

        if (framesAnimation.exists(name) && oldFrame != null) _sprite.setFrames(oldFrame, true);
    }

    public override function addByIndices(Name:String, Prefix:String, 
        Indices:Array<Int>, Postfix:String, FrameRate:Float = 30, Looped:Bool = true, 
        FlipX:Bool = false, FlipY:Bool = false):Void
    {
        var oldFrame:FlxFramesCollection = null;

        if (framesAnimation.exists(name))
        {
            oldFrame = _sprite.frames;
            _sprite.setFrames(framesAnimation[name], true);
        }

        super.addByIndices(Name, Prefix, Indices, Postfix, FrameRate, Looped, FlipX, FlipY);

        if (framesAnimation.exists(name) && oldFrame != null) _sprite.setFrames(oldFrame, true);
    }

    public override function play(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void
    {
        if (framesAnimation.exists(animName))
            _sprite.setFrames(framesAnimation[animName], true);

        super.play(animName, force, reversed, frame);

        if (offsets.exists(animName))
        {
            if (offsets[animName][1]) _sprite.centerOffsets();
            _sprite.offset.x += offsets[animName][0].x;
            _sprite.offset.y += offsets[animName][0].y;
        }
    }
}
