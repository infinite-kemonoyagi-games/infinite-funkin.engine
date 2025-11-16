package funkin.play;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.sound.FlxSound;
import funkin.backend.MusicBeatState;
import funkin.play.notes.data.NoteFile;
import funkin.play.notes.strum.StrumLine;
import funkin.song.Conductor;
import funkin.song.TimeSignature;
import funkin.song.data.SongMetaData;
import funkin.song.data.chart.ChartData;
import funkin.song.data.chart.ChartParser;
import haxe.Json;
import openfl.Assets;

class PlayState extends MusicBeatState
{
	public var level:String;
	public var difficulty:String;
	
	public var vocals:Map<String, FlxSound> = null;
	public var playerVocals:Map<String, FlxSound> = null;

	public var generatedMusic:Bool = false;

	private var songMeta:SongMetaData = null; // temporal... or maybe not
	private var chartData:ChartData = null;

	public var strumlineManager:FlxTypedSpriteGroup<StrumLine>;
	public var playerStrum:StrumLine;
	public var opponentStrum:StrumLine;

	public function new(level:String, difficulty:String)
	{
		this.level = level;
		this.difficulty = difficulty;

		final URL:String = 'assets/data/charts/$level/';
		songMeta = cast Json.parse(Assets.getText(URL + difficulty + '-meta.json'));
		chartData = cast ChartParser.loadChart(URL, difficulty);

		super();
	}

	public override function create():Void
	{
		super.create();

		setupSong();

		spawnStrumlines();

		startCountdown();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	private function spawnStrumlines():Void
	{
		final URL:String = 'assets/data/note/';
		var strumFile:NoteFile = cast Json.parse(Assets.getText(URL + 'strum/${chartData.current.strumline}.json'));

		strumlineManager = new FlxTypedSpriteGroup();
		add(strumlineManager);

		opponentStrum = new StrumLine(4, strumFile, opponent);
		opponentStrum.ID = 0;
		opponentStrum.y = 50;
		strumlineManager.add(opponentStrum);

		playerStrum = new StrumLine(4, strumFile, player);
		playerStrum.ID = 1;
		playerStrum.y = 50;
		strumlineManager.add(playerStrum);

		for (line in strumlineManager)
		{
			line.screenCenter(X);
			final mult = (line.ID - (strumlineManager.length - 1) / 2) * (line.width * 1.2);
			line.x += mult;
		}
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
		vocals = [];
		playerVocals = [];

		FlxG.sound.music = new FlxSound();
		FlxG.sound.music.loadEmbedded('assets/music/songs/$level/Inst.ogg');

		for (character in chartData.characters)
		{
			if (!chartData.allowedVocals.get(character.name)) continue;
			final vocal:FlxSound = new FlxSound();
			vocal.loadEmbedded('assets/music/songs/$level/Voices-${character.name}.ogg');
			FlxG.sound.list.add(vocal);
			vocals.set(character.name, vocal);
			if (character.type == player) playerVocals.set(character.name, vocal);
		}

		final tempo = songMeta.tempo[0].data;
		final signature = songMeta.signature[0].data;

		conductor = new Conductor(tempo, new TimeSignature(signature[0], signature[1]));
		conductor.position = -(conductor.beatCrochet * 5);
		conductor.play();
		addConductor();
	}

	private function startSong():Void
	{
		generatedMusic = true;

		conductor.reference = FlxG.sound.music;
		FlxG.sound.music.play();
		for (sound in vocals) sound.play();
		resyncVocals();
	}

	function resyncVocals():Void
	{
		if (vocals == null) return;
		if (!FlxG.sound.music.playing) return;

		final timeToPlayAt:Float = conductor.position;

		FlxG.sound.music.pause();
		for (sound in vocals) sound.pause();

		FlxG.sound.music.time = timeToPlayAt;
		FlxG.sound.music.play(false, timeToPlayAt);

		for (sound in vocals)
		{
			sound.time = timeToPlayAt;
			sound.play(false, timeToPlayAt);	
		}
	}
}
