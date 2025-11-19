package funkin.play;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import funkin.backend.MusicBeatState;
import funkin.play.notes.Note;
import funkin.play.notes.Sustain;
import funkin.play.notes.data.NoteFile;
import funkin.play.notes.strum.StrumLine;
import funkin.play.notes.strum.StrumLineManager;
import funkin.play.notes.strum.StrumNote;
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

	public var strumline:FlxTypedGroup<StrumNote>;
	public var strumlineManager:StrumLineManager;
	public var playerStrum:StrumLine;
	public var opponentStrum:StrumLine;

	private var unspawnedNotes:Array<Note> = null;
	public var notes:FlxTypedGroup<Note> = null;
	public var sustains:FlxTypedGroup<Sustain> = null;

	private var notesLength:Int = 4;

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
		generateNotes();

		startCountdown();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		for (strum in opponentStrum)
		{
			final animName = strum.animation.curAnim.name;
			if (!strum.hold && animName == 'confirmed' && strum.animation.finished)
				strum.animation.play('static');
		}

		for (strum in strumline)
			if (strum.animation.curAnim.name != 'confirmed')
				strum.centerOffsets();

		for (note in unspawnedNotes)
		{
			note.waitingToSpawn(unspawnedNotes, () -> 
			{
				note.spawn(strumlineManager.strumlines[note.character], notes, sustains);
			});
		}

		for (note in notes)
		{
			if (note.type == OPPONENT && note.mustBeHit)
			{
				note.pressed = true;
				note.kill();
				note.destroy();
				notes.remove(note, true);

				note.strumnote.animation.play("confirmed", true);
				note.strumnote.hold = note.length > 0;
			}

			if (note.y <= -note.height)
			{
				note.kill();
				note.destroy();
				notes.remove(note, true);
			}
		}

		for (note in sustains)
		{
			final tail = note.tail;
			final center:Float = note.reference.y + note.reference.height / 2;

			if (note.y + note.offset.y <= note.reference.y + note.reference.height / 2 
				&& note.mustBeHit && note.parent.pressed)
			{
				final width = Math.max(note.width, tail.width);
				final height = note.height + tail.height;
				final rect:FlxRect = new FlxRect(0, center - note.y, width * 2, height * 2);
				rect.y /= note.scale.y;
				rect.height -= rect.y;
				note.clipRect = rect;

				if (tail.y + tail.offset.y <= tail.reference.y + tail.reference.height / 2)
					tail.clipRect = rect;
			}

			if (note.type == OPPONENT && tail.mustBeHit)
			{
				note.pressed = true;
				note.kill();
				note.destroy();
				sustains.remove(note, true);
				note.strumnote.hold = false;
			}

			if (note.parent.killed && !note.parent.pressed)
			{
				note.alpha = tail.alpha = FlxMath.lerp(note.alpha, 0, elapsed * 6);

				if (note.alpha == 0)
				{
					note.kill();
					note.destroy();
					sustains.remove(note, true);
				}
			}

			if (tail.y <= -tail.height)
			{
				note.kill();
				note.destroy();
				sustains.remove(note, true);
			}
		}
	}

	private function generateNotes():Void
	{
		notes = new FlxTypedGroup();
		add(notes);
		sustains = new FlxTypedGroup();
		add(sustains);

		unspawnedNotes = [];
		final storedSkins:Map<String, NoteFile> = [];

		for (note in chartData.notes)
		{
			final URL:String = 'assets/data/note/';

			var skinFile:NoteFile = null;
			var curSkin:String = "";

			if (note.skin == null || note.skin == "")
				curSkin = chartData.current.notes;
			else 
				curSkin = note.skin;
			
			if (!storedSkins.exists(curSkin))
			{
				skinFile = cast Json.parse(Assets.getText(URL + '$curSkin.json'));
				skinFile.notes = skinFile.notes.filter(item -> StrumLine.names[notesLength].contains(item.note));
				storedSkins[curSkin] = skinFile;
			}
			else skinFile = storedSkins[curSkin];

			final info = skinFile.notes[StrumLine.names[notesLength].indexOf(note.name)];
			final spr:Note = new Note(note, skinFile, info, this, false);
			spr.globalSpeed = chartData.speed;
			unspawnedNotes.push(spr);
		}
	}

	private function spawnStrumlines():Void
	{
		final URL:String = 'assets/data/note/';
		var strumFile:NoteFile = cast Json.parse(Assets.getText(URL + 'strum/${chartData.current.strumline}.json'));

		strumline = new FlxTypedGroup();
		add(strumline);

		strumlineManager = new StrumLineManager();
		add(strumlineManager);

		opponentStrum = new StrumLine(notesLength, strumFile, chartData.current.opponent, OPPONENT);
		opponentStrum.ID = 0;
		opponentStrum.y = 50;
		strumlineManager.add(opponentStrum);
		for (note in opponentStrum) strumline.add(note);
		
		playerStrum = new StrumLine(notesLength, strumFile, chartData.current.player, PLAYER);
		playerStrum.ID = 1;
		playerStrum.y = 50;
		strumlineManager.add(playerStrum);
		for (note in playerStrum) strumline.add(note);
		
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
			if (character.type == PLAYER) playerVocals.set(character.name, vocal);
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
