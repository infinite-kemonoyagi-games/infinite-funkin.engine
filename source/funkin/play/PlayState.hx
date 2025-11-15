package funkin.play;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;
import funkin.backend.MusicBeatState;
import funkin.song.Conductor;

class PlayState extends MusicBeatState
{
	public var logo:FlxSprite = null;
	public var vocalP1:FlxSound = null;
	public var vocalP2:FlxSound = null;

	public var vocals:FlxSoundGroup = null;

	public override function create():Void
	{
		super.create();

		logo = new FlxSprite().loadGraphic("assets/images/menu/logo/basic.png");
		logo.screenCenter();
		add(logo);

		vocals = new FlxSoundGroup();

		FlxG.sound.music = new FlxSound();
		FlxG.sound.music.loadEmbedded("assets/music/songs/bopeebo/Inst.ogg");
		FlxG.sound.music.play(true);

		vocalP1 = new FlxSound();
		vocalP1.loadEmbedded("assets/music/songs/bopeebo/Voices-bf.ogg");
		vocalP2 = new FlxSound();
		vocalP2.loadEmbedded("assets/music/songs/bopeebo/Voices-dad.ogg");

		FlxG.sound.list.add(vocalP1);
		vocals.add(vocalP1);
		FlxG.sound.list.add(vocalP2);
		vocals.add(vocalP2);

		vocalP1.play(true);
		vocalP2.play(true);

		conductor = new Conductor(100);
		conductor.reference = FlxG.sound.music;
		addConductor();

		resyncVocals();
	}

	public override function onBeatHit(beats:Int):Void
	{
		logo.scale.set(1.08, 1.08);
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		logo.scale.x = FlxMath.lerp(logo.scale.x, 1.0, elapsed * 6);
		logo.scale.y = FlxMath.lerp(logo.scale.y, 1.0, elapsed * 6);
		
		conductor.update(elapsed);
	}

	function resyncVocals():Void
	{
		if (vocals == null) return;
		if (!FlxG.sound.music.playing) return;

		var timeToPlayAt:Float = conductor.position;

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
