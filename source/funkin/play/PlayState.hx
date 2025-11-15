package funkin.play;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;
import funkin.backend.MusicBeatState;
import funkin.song.Conductor;

class PlayState extends MusicBeatState
{
	public var vocalP1:FlxSound = null;
	public var vocalP2:FlxSound = null;
	public var vocals:FlxSoundGroup = null;

	public var generatedMusic:Bool = false;

	public override function create():Void
	{
		super.create();

		setupSong();

		conductor = new Conductor(100);
		conductor.position = -(conductor.beatCrochet * 5);
		conductor.play();
		addConductor();

		startCountdown();
	}

	private function startCountdown():Void
	{
		conductor.onBeatUpdate.add(function count(beats:Int):Void
		{
			switch Math.abs(beats)
			{
				case 4: FlxG.sound.play('assets/sounds/play/funkin/intro3.ogg', 0.6);
				case 3: FlxG.sound.play('assets/sounds/play/funkin/intro2.ogg', 0.6);
				case 2: FlxG.sound.play('assets/sounds/play/funkin/intro1.ogg', 0.6);
				case 1: FlxG.sound.play('assets/sounds/play/funkin/introGo.ogg', 0.6);
				case 0: 
					startSong();
					conductor.onBeatUpdate.remove(count);
			}
		});
	}

	private function setupSong():Void
	{
		vocals = new FlxSoundGroup();

		FlxG.sound.music = new FlxSound();
		FlxG.sound.music.loadEmbedded("assets/music/songs/bopeebo/Inst.ogg");

		vocalP1 = new FlxSound();
		vocalP1.loadEmbedded("assets/music/songs/bopeebo/Voices-bf.ogg");
		FlxG.sound.list.add(vocalP1);
		vocals.add(vocalP1);

		vocalP2 = new FlxSound();
		vocalP2.loadEmbedded("assets/music/songs/bopeebo/Voices-dad.ogg");
		FlxG.sound.list.add(vocalP2);
		vocals.add(vocalP2);
	}

	private function startSong():Void
	{
		generatedMusic = true;

		conductor.reference = FlxG.sound.music;
		FlxG.sound.music.play();
		vocalP1.play();
		vocalP2.play();
		resyncVocals();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		conductor.update(elapsed);
	}

	function resyncVocals():Void
	{
		if (vocals == null) return;
		if (!FlxG.sound.music.playing) return;

		final timeToPlayAt:Float = conductor.position;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = timeToPlayAt;
		FlxG.sound.music.play(false, timeToPlayAt);

		for (sound in vocals.sounds)
		{
			sound.time = timeToPlayAt;
			sound.play(false, timeToPlayAt);	
		}
	}
}
