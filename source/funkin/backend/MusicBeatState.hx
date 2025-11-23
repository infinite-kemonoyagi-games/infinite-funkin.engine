package funkin.backend;

import flixel.FlxState;
import funkin.assets.FunkinAssets;
import funkin.assets.FunkinLoader;
import funkin.song.Conductor;

class MusicBeatState extends FlxState
{
    public var conductor:Null<Conductor> = null;

    public var assets(get, never):FunkinAssets;
    @:noCompletion
    private function get_assets():FunkinAssets return Main.assets;

    public var load(get, never):FunkinLoader;
    @:noCompletion
    private function get_load():FunkinLoader return assets.load;

    public function addConductor():Void
    {
        if (conductor != null)
        {
            conductor.onStepUpdate.add(onStepHit);
            conductor.onBeatUpdate.add(onBeatHit);
            conductor.onSectionUpdate.add(onSectionHit);
        }
    }

    public function onStepHit(steps:Int):Void {}
    public function onBeatHit(beats:Int):Void {}
    public function onSectionHit(sections:Int):Void {}

    public override function create():Void
    {
        super.create();
    }

    public override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (conductor != null) conductor.update(elapsed);
    }
}