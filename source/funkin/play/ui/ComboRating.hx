package funkin.play.ui;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxPool;
import funkin.backend.MusicBeatState;

class ComboRating extends FlxGroup
{
    public var parent:MusicBeatState = null;

    public var ratingPool:Map<String, FlxPool<Rating>> = null;
    public var loadedSkins:Array<String> = null;

    public var ratingGrp:FlxTypedGroup<Rating> = null;

    public function new(parent:MusicBeatState)
    {
        super();

        this.parent = parent;

        ratingPool = [];
        loadedSkins = [];

        ratingGrp = new FlxTypedGroup();
        add(ratingGrp);
    }

    public override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        for (rating in ratingGrp)
        {
            if (rating.y > FlxG.height + rating.height + camera.y)
            {
                rating.kill();
                rating.destroy();
                ratingGrp.remove(rating);
            }
        }
    }

    public function loadSkin(skin:String):Void
    {
        loadedSkins.push(skin);
        ratingPool.set(skin, new FlxPool(PoolFactory.fromFunction(() -> new Rating(skin))));
    }

    public function noteHit(skin:String, rating:String, combo:Int):Void
    {
        final ratingSpr = ratingPool[skin].get();
        ratingSpr.loadRating(rating);
        ratingSpr.screenCenter();
        ratingSpr.acceleration.y = 550;
        ratingSpr.velocity.y = -FlxG.random.int(225, 275);
        ratingSpr.velocity.x = -FlxG.random.int(-10, 10);
        ratingGrp.add(ratingSpr);

        FlxTween.tween(ratingSpr, {alpha: 0}, 0.2,
        {
            onComplete: tween ->
            {
                tween.destroy();

                ratingSpr.kill();
                ratingSpr.destroy();
                ratingGrp.remove(ratingSpr);
            },
			startDelay: parent.conductor.beatCrochet * 0.001
		});
    }

    public override function destroy():Void
    {
        for (pool in ratingPool) pool.clear();
        super.destroy();
    }
}