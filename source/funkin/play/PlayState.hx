package funkin.play;

import flixel.FlxG;
import flixel.FlxState;
import funkin.song.Conductor;

class PlayState extends FlxState
{
	public var conductor:Conductor;

	override public function create()
	{
		super.create();

		FlxG.sound.playMusic("assets/music/songs/bopeebo/Inst.ogg");

		conductor = new Conductor(100);
		conductor.reference = FlxG.sound.music;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		conductor.update(elapsed);
		
		FlxG.watch.addQuick("steps", conductor.steps);
		FlxG.watch.addQuick("beats", conductor.beats);
		FlxG.watch.addQuick("sections", conductor.sections);
	}
}
