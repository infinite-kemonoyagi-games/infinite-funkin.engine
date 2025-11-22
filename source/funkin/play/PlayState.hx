package funkin.play;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.MusicBeatState;
import funkin.play.notes.Note;
import funkin.play.notes.NoteBase;
import funkin.play.notes.Sustain;
import funkin.play.notes.data.NoteFile;
import funkin.play.notes.strum.StrumLine;
import funkin.play.notes.strum.StrumLineManager;
import funkin.play.notes.strum.StrumNote;
import funkin.play.ui.ComboRating;
import funkin.play.ui.NoteSplash;
import funkin.song.Conductor;
import funkin.song.TimeSignature;
import funkin.song.data.SongMetaData;
import funkin.song.data.chart.ChartData;
import funkin.song.data.chart.ChartParser;
import funkin.utils.FunkinStringUtils;
import funkin.utils.MathUtils;
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

	public var noteSplashes:FlxTypedGroup<NoteSplash> = null;

	private var unspawnedNotes:Array<Note> = null;
	public var notes:FlxTypedGroup<Note> = null;
	public var sustains:FlxTypedGroup<Sustain> = null;

	private var notesLength:Int = 4;

	public var comboGrp:ComboRating = null;

	public var scoreTxt:FlxText = null;

	public var score:Float = 0.0;
	public var misses:Int = 0;
	public var accuracy:Float = 0.0;
	public var combos:Int = 0;

	public var notesPrec:Float = 0.0;
	public var notesCount:Int = 0;

	public var botplay:Bool = false;

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

		comboGrp = new ComboRating(this);
		comboGrp.loadSkin(chartData.current.notes);
		add(comboGrp);

		scoreTxt = new FlxText("Score: 0.0 | Accuracy: 0.00%"); // if misses are 0 will not show in text
		scoreTxt.setFormat(FlxAssets.FONT_DEFAULT, 24, OUTLINE, FlxColor.BLACK);
		scoreTxt.y = FlxG.height - scoreTxt.height;
		scoreTxt.screenCenter(X);
		add(scoreTxt);

		spawnStrumlines();
		generateNotes();

		startCountdown();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		for (strum in strumline)
		{
			final isBot:Bool = strum.parent.botplay;
			var animName = strum.animation.curAnim.name;
			if (isBot && !strum.hold && animName == 'confirmed' && strum.animation.finished)
				strum.animation.play('static');
			animName = strum.animation.curAnim.name; // refresh name

			if (animName != 'confirmed') strum.centerOffsets();
		}

		for (note in unspawnedNotes)
		{
			note.waitingToSpawn(unspawnedNotes, () -> 
			{
				note.spawn(strumlineManager.strumlines[note.character], notes, sustains);
			});
		}

		updateNotes(elapsed);

		if (!botplay) updateInput(elapsed);

		final scoreFormat:String = FunkinStringUtils.formatDecimals(score, 1);
		final accuracyFormat:String = FunkinStringUtils.formatDecimals(accuracy, 2);

		if (misses > 0)
			scoreTxt.text = 'Score: $scoreFormat | Misses: $misses | Accuracy: $accuracyFormat%';
		else
			scoreTxt.text = 'Score: $scoreFormat | Accuracy: $accuracyFormat%';

		scoreTxt.screenCenter(X);
	}

	private function updateNotes(elapsed:Float):Void
	{
		for (note in notes)
		{
			if (note.wasTooLate && !note.missed)
			{
				if (note.length > 0) note.sustain.vanish = true;
				note.alpha = FlxMath.lerp(note.alpha, 0, elapsed * 6);
				if (note.alpha == 0) deleteNote(note);
				noteMiss(note);
			}

			if (note.botplay && note.mustBeHit) deleteNote(note, true);
			if (note.y <= -note.height) deleteNote(note);

		}

		for (note in sustains)
		{
			final tail = note.tail;
			final center:Float = note.reference.y + note.reference.height / 2;

			if (note.y + note.offset.y <= note.reference.y + note.reference.height / 2 
				&& note.mustBeHit && note.parent.pressed)
			{
				if (!note.strumnote.hold) note.strumnote.hold = true;

				final width = Math.max(note.width, tail.width);
				final height = note.height + tail.height;
				final rect:FlxRect = new FlxRect(0, center - note.y, width * 2, height * 2);
				rect.y /= note.scale.y;
				rect.height -= rect.y;
				note.clipRect = rect;

				if (tail.y + tail.offset.y <= tail.reference.y + tail.reference.height / 2)
					tail.clipRect = rect;
			}

			if (note.botplay && tail.mustBeHit) deleteSustain(note);

			if (note.parent.killed && !note.parent.pressed || note.vanish)
			{
				note.alpha = tail.alpha = FlxMath.lerp(note.alpha, 0, elapsed * 6);

				if (note.alpha == 0) deleteSustain(note);
			}

			if (tail.y <= -tail.height) deleteSustain(note);
		}
	}

	private function updateInput(elapsed:Float):Void 
	{
		final left:Bool = FlxG.keys.pressed.D;
		final down:Bool = FlxG.keys.pressed.F;
		final up:Bool = FlxG.keys.pressed.J;
		final right:Bool = FlxG.keys.pressed.K;
		final presseds:Array<Bool> = [left, down, up, right];

		final justLeft:Bool = FlxG.keys.justPressed.D;
		final justDown:Bool = FlxG.keys.justPressed.F;
		final justUp:Bool = FlxG.keys.justPressed.J;
		final justRight:Bool = FlxG.keys.justPressed.K;
		final justPresseds:Array<Bool> = [justLeft, justDown, justUp, justRight];

		final leftR:Bool = FlxG.keys.justReleased.D;
		final downR:Bool = FlxG.keys.justReleased.F;
		final upR:Bool = FlxG.keys.justReleased.J;
		final rightR:Bool = FlxG.keys.justReleased.K;
		final releaseds:Array<Bool> = [leftR, downR, upR, rightR];

		if (justPresseds.contains(true))
		{
			final notesDetected:Array<Note> = [];
			var skipDetection:Bool = false;

			for (note in notes)
			{
				if (!note.botplay && note.canBeHit && !note.wasTooLate && justPresseds[note.ID])
				{
					for (possible in notesDetected)
					{
						skipDetection = Math.abs(possible.position - note.position) > 0 && possible.name == note.name;
						if (skipDetection) break;
					}
					if (!skipDetection) notesDetected.push(note);
				}
				else if (!note.botplay && !note.canBeHit) break;
			}

			if (notesDetected.length > 0)
			{
				for (note in notesDetected)
				{
					goodHit(note);
					deleteNote(note, true);
				}
			}
			else 
				for (index => input in justPresseds) if (input) badHit(index);
		}

		if (presseds.contains(true) || releaseds.contains(true))
		{
			for (note in sustains)
			{
				final isPressed:Bool = !note.botplay && note.parent.pressed && presseds[note.ID];
				final hasVanish = !note.botplay && note.pressed && releaseds[note.ID];

				final add:Float = 350 * (note.length / conductor.beatCrochet) * elapsed;
				if (isPressed && !note.vanish)
				{
					note.pressed = true;
					note.scoreAdded += add;
					increaseScore(add);
				}
				else if (!note.botplay && note.tail.canBeHit || hasVanish)
				{
					deleteSustain(note);
					if (hasVanish && !note.tail.canBeHit) increaseScore(-100.5, 0.5, true);
					else increaseScore(note.scoreAdded - add);
				}
				else if (!note.botplay) break;
			}
		}

		for (strum in playerStrum) // just copied strumlines bucle for line lol
		{
			final isBot:Bool = strum.parent.botplay;
			var animName = strum.animation.curAnim.name;

			if (!isBot && animName != 'static' && releaseds[strum.ID])
				strum.animation.play('static');

			animName = strum.animation.curAnim.name; // refresh name
			if (animName != 'confirmed') strum.centerOffsets();
		}
	}

	public function badHit(direction:Int):Void
	{
		increaseScore(-25.2, 0.5, true);
		playerStrum.members[direction].animation.play("pressed", true);
	}

	public function goodHit(note:Note):Void
	{
		++combos;

		final noteDiff:Float = Math.abs(note.position - conductor.position);
		var rating:String = "sick";

		if (noteDiff > NoteBase.safeHitbox * 0.9)
		{
			rating = 'bad';
			increaseScore(350, 0.2);
			notesPrec += 0.2;
		}
		else if (noteDiff > NoteBase.safeHitbox * 0.6)
		{
			rating = 'bad';
			increaseScore(350, 0.45);
			notesPrec += 0.45;
		}
		else if (noteDiff > NoteBase.safeHitbox * 0.3)
		{
			rating = 'good';
			increaseScore(350, 0.75);
			notesPrec += 0.75;
		}
		else
		{
			increaseScore(350);
			note.strumnote.splash.splash();
			++notesPrec;
		}
		updateAccuracy();

		comboGrp.noteHit(note.skin, rating, combos);
	}

	public function noteMiss(note:Note):Void
	{
		note.missed = true;
		updateAccuracy();
		increaseScore(-150);
		++misses;
		combos = 0;
	}

	private function increaseScore(add:Float, mult:Float = 1.0, onlyMultHealth:Bool = false):Void
	{
		if (!onlyMultHealth) score += add * mult;
		else score += add;
		// health ++
	}

	public function deleteNote(note:Note, isPressed:Bool = false):Void
	{
		note.pressed = isPressed;
		note.kill();
		note.destroy();
		if (isPressed)
		{
			note.strumnote.hold = note.length > 0;
			note.strumnote.animation.play("confirmed", true);
		}
		notes.remove(note, true);
	}

	public function deleteSustain(sustain:Sustain):Void
	{
		sustain.parent.pressed = false;
		sustain.pressed = false;
		sustain.kill();
		sustain.destroy();
		sustain.strumnote.hold = false;
		sustains.remove(sustain, true);
	}

	public function updateAccuracy():Void
	{
		++notesCount;
		accuracy = MathUtils.floorDecimal(notesPrec / notesCount * 100, 2);
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

			if (!comboGrp.loadedSkins.contains(curSkin)) comboGrp.loadSkin(curSkin);
			
			if (!storedSkins.exists(curSkin))
			{
				skinFile = cast Json.parse(Assets.getText(URL + '$curSkin.json'));
				skinFile.notes = skinFile.notes.filter(item -> StrumLine.names[notesLength].contains(item.note));
				storedSkins[curSkin] = skinFile;
			}
			else skinFile = storedSkins[curSkin];

			if (note.skin == null) note.skin = curSkin;

			final info = skinFile.notes[StrumLine.names[notesLength].indexOf(note.name)];
			final spr:Note = new Note(note, skinFile, info, this, false);
			spr.globalSpeed = chartData.speed;
			unspawnedNotes.push(spr);
		}
	}

	private function spawnStrumlines():Void
	{
		final curSkin:String = chartData.current.strumline;

		final URL:String = 'assets/data/note/';
		var strumFile:NoteFile = cast Json.parse(Assets.getText(URL + 'strum/$curSkin.json'));

		strumline = new FlxTypedGroup();
		add(strumline);

		strumlineManager = new StrumLineManager();
		add(strumlineManager);

		opponentStrum = new StrumLine(curSkin, notesLength, strumFile, chartData.current.opponent, OPPONENT);
		opponentStrum.ID = 0;
		opponentStrum.y = 50;
		strumlineManager.add(opponentStrum);
		for (note in opponentStrum) strumline.add(note);

		noteSplashes = new FlxTypedGroup();
		add(noteSplashes);

		playerStrum = new StrumLine(curSkin, notesLength, strumFile, chartData.current.player, PLAYER);
		playerStrum.ID = 1;
		playerStrum.y = 50;
		playerStrum.botplay = botplay;
		strumlineManager.add(playerStrum);
		for (note in playerStrum)
		{
			final splash:NoteSplash = new NoteSplash(curSkin, note.name, note);
			noteSplashes.add(splash);
			strumline.add(note);
		}

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

		var newAdded:Int = 0;

		for (index => character in chartData.characters)
		{
			if (!chartData.allowedVocals.get(character.name)) 
			{
				if (index == chartData.characters.length - 1) ++newAdded;
				continue;
			}
			final URL:String = 'assets/music/songs/$level/Voices-${character.name}.ogg';
			if (!Assets.exists(URL)) continue;

			final vocal:FlxSound = new FlxSound();
			vocal.loadEmbedded(URL);
			FlxG.sound.list.add(vocal);
			vocals.set(character.name, vocal);
			++newAdded;

			if (character.type == PLAYER) playerVocals.set(character.name, vocal);
		}

		if (newAdded < 1)
		{
			final URL:String = 'assets/music/songs/$level/Voices.ogg';
			final vocal:FlxSound = new FlxSound();
			vocal.loadEmbedded(URL);
			FlxG.sound.list.add(vocal);
			vocals.set("", vocal);
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
