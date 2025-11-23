package funkin.play;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import funkin.backend.MusicBeatState;
import funkin.play.character.Character;
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
import funkin.song.data.chart.ChartEventData;
import funkin.song.data.chart.ChartParser;
import funkin.utils.FunkinStringUtils;
import funkin.utils.MathUtils;
import haxe.Json;
import openfl.Assets;

using StringTools;

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

	private var events:Array<ChartEventData> = null;
	private var unspawnedNotes:Array<Note> = null;
	public var notes:FlxTypedGroup<Note> = null;
	public var sustains:FlxTypedGroup<Sustain> = null;

	public var boyfriend:Character = null;
	public var dad:Character = null;

	private var characterList:Map<String, Character> = null;

	private var notesLength:Int = 4;

	public var comboGrp:ComboRating = null;

	public var scoreTxt:FlxText = null;
	public var timeTxt:FlxText = null;

	public var score:Float = 0.0;
	public var misses:Int = 0;
	public var accuracy:Float = 0.0;
	public var combos:Int = 0;

	public var notesPrec:Float = 0.0;
	public var notesCount:Int = 0;

	public var botplay(default, set):Bool = false;

	private var tweenCamera:FlxTween = null;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

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
		persistentUpdate = true;
		persistentDraw = true;

		characterList = [];

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		@:privateAccess
		FlxCamera._defaultCameras = [camGame];

		super.create();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		setupSong();

		boyfriend = new Character(chartData.current.player, true);
		boyfriend.screenCenter();
		boyfriend.x += 250;
		boyfriend.y += 110;
		characterList[chartData.current.player] = boyfriend;
		add(boyfriend);

		dad = new Character(chartData.current.opponent, true);
		dad.screenCenter();
		dad.x -= 250;
		dad.y -= 75;
		characterList[chartData.current.opponent] = dad;
		add(dad);

		comboGrp = new ComboRating(this);
		comboGrp.loadSkin(chartData.current.notes);
		comboGrp.cameras = [camHUD];
		add(comboGrp);

		scoreTxt = new FlxText("Score: 0.0 | Accuracy: 0.00%"); // if misses are 0 will not show in text
		scoreTxt.setFormat(FlxAssets.FONT_DEFAULT, 24, OUTLINE, FlxColor.BLACK);
		scoreTxt.y = FlxG.height - scoreTxt.height;
		scoreTxt.screenCenter(X);
		scoreTxt.cameras = [camHUD];
		add(scoreTxt);

		timeTxt = new FlxText("0:00 | 0:01");
		timeTxt.setFormat(FlxAssets.FONT_DEFAULT, 18, OUTLINE, FlxColor.BLACK);
		timeTxt.y = 25;
		timeTxt.screenCenter(X);
		timeTxt.cameras = [camHUD];
		add(timeTxt);

		spawnStrumlines();
		generateNotes();

		startCountdown();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1.0, elapsed * 6);
		camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1.0, elapsed * 6);

		for (event in events)
		{
			if (event.position - conductor.position <= 0) 
			{
				eventCalled(event);
				events.remove(event);
			}
		}

		scoreTxt.scale.x = FlxMath.lerp(scoreTxt.scale.x, 1.0, elapsed * 6);

		for (strum in strumline)
		{
			final isBot:Bool = strum.parent.botplay;
			var animName = strum.animation.curAnim?.name ?? "";
			if (isBot && !strum.hold && animName == 'confirmed' && strum.animation.finished)
				strum.animation.play('static');
			animName = strum.animation.curAnim?.name ?? ""; // refresh name

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
		updateInput(elapsed);

		if (dad.holdTimer > conductor.beatCrochet * 2) dad.canDance = true;

		final scoreFormat:String = FunkinStringUtils.formatDecimals(score, 1);
		final accuracyFormat:String = FunkinStringUtils.formatDecimals(accuracy, 2);

		if (misses > 0)
			scoreTxt.text = 'Score: $scoreFormat | Misses: $misses | Accuracy: $accuracyFormat%';
		else
			scoreTxt.text = 'Score: $scoreFormat | Accuracy: $accuracyFormat%';

		if (botplay) scoreTxt.text = 'Score: $scoreFormat | botplay mode';

		scoreTxt.screenCenter(X);

		final time:Float = conductor.position;
		final length:Float = FlxG.sound.music?.length ?? 0;

		timeTxt.text = '${FlxStringUtil.formatTime(time / 1000)} | ${FlxStringUtil.formatTime(length / 1000)}';

		timeTxt.screenCenter(X);
	}

	public override function onBeatHit(beats:Int):Void
	{
		if (beats % 2 == 0 && boyfriend.canDance) boyfriend.animation.play("idle", true);
		if (beats % 2 == 0 && dad.canDance) dad.animation.play("idle", true);

		if (level == "bopeebo" && beats % 8 == 7) boyfriend.animation.play("hey");
	}

	public override function onSectionHit(beats:Int):Void
	{
		FlxG.camera.zoom = 1.02;
		camHUD.zoom = 1.05;
	}

	public function eventCalled(event:ChartEventData):Void
	{
		if (event.name == "focusCharacter")
		{
			var target:Character = characterList[cast event.values[0]];

			if (tweenCamera != null) tweenCamera.cancel();

			tweenCamera = FlxTween.tween(FlxG.camera, 
			{
				"scroll.x": target.x - ((camera.width - target.width) / 2) + target.cameraOpt.x,
				"scroll.y": target.y - ((camera.height - target.height) / 2) + target.cameraOpt.y,
			}, event.length,
			{
				ease: Reflect.field(FlxEase, cast event.values[1]),
				onComplete: _ ->
				{
					tweenCamera = null;
				}
			});
		}
	}

	private function updateNotes(elapsed:Float):Void
	{
		for (note in notes)
		{
			if (note.wasTooLate && !note.missed || note.y <= -note.height)
			{
				if (note.length > 0) note.sustain.vanish = true;
				note.alpha = FlxMath.lerp(note.alpha, 0, elapsed * 6);
				if (note.alpha == 0) deleteNote(note);
				if (note.type == PLAYER) noteMiss(note);
			}

			if (note.botplay && note.mustBeHit) 
			{
				switch note.type
				{
					case PLAYER: goodHit(note);
					case OPPONENT:
						dad.animation.play(Character.singNotes[notesLength][note.ID], true);
						dad.canDance = false;
						dad.holdTimer = 0;
					case GIRLFRIEND: // nothing at the moment
				}
				deleteNote(note, true);
			}
			if (note.y <= -note.height) deleteNote(note);
		}

		for (note in sustains)
		{
			final tail = note.tail;
			final center:Float = note.reference.y + note.reference.height / 2;

			final add:Float = 350 * (note.length / conductor.beatCrochet) * elapsed;
			if (note.botplay && note.parent.pressed && !note.vanish)
			{
				switch note.type
				{
					case PLAYER:
						boyfriend.canDance = false;
						boyfriend.holdTimer = 0;

						note.pressed = true;
						note.scoreAdded += add;
						increaseScore(add);
					case OPPONENT:
						dad.canDance = false;
						dad.holdTimer = 0;
					case GIRLFRIEND: // nothing at the moment
				}
			}

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

		if (FlxG.keys.justPressed.SEVEN) botplay = !botplay;

		if (!botplay) detectNoteInput(elapsed, presseds, justPresseds, releaseds);

		final animName:String = boyfriend.animation.curAnim.name.replace("miss", "");
		final notePressed:Int = Character.singNotes[notesLength].indexOf(animName);

		if (boyfriend.holdTimer > conductor.beatCrochet * 2 && (!presseds[notePressed] || botplay))
			boyfriend.canDance = true;
	}

	private function detectNoteInput(elapsed:Float, presseds:Array<Bool>, justPresseds:Array<Bool>,
		releaseds:Array<Bool>):Void
	{
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

					boyfriend.canDance = false;
					boyfriend.holdTimer = 0;
				}
				else if (!note.botplay && note.tail.canBeHit || hasVanish)
				{
					deleteSustain(note);
					if (hasVanish && !note.tail.canBeHit)
					{
						increaseScore(-100.5, 0.5, true);
						for (sound in playerVocals) sound.volume = 0;
						boyfriend.animation.play(Character.singNotes[notesLength][note.ID] + "miss", true);
						boyfriend.canDance = false;
						boyfriend.holdTimer = 0;
					}
					else increaseScore(note.scoreAdded - add);
				}
				else if (!note.botplay) break;
			}
		}

		for (strum in playerStrum) // just copied strumlines bucle for line lol
		{
			final isBot:Bool = strum.parent.botplay;
			var animName = strum.animation.curAnim?.name ?? "";

			if (!isBot && animName != 'static' && releaseds[strum.ID])
				strum.animation.play('static');

			animName = strum.animation.curAnim?.name ?? ""; // refresh name
			if (animName != 'confirmed') strum.centerOffsets();
		}
	}

	public function badHit(direction:Int):Void
	{
		for (sound in playerVocals) sound.volume = 0;

		increaseScore(-25, 0.5, true);
		playerStrum.members[direction].animation.play("pressed", true);

		boyfriend.animation.play(Character.singNotes[notesLength][direction] + "miss", true);
		boyfriend.canDance = false;
		boyfriend.holdTimer = 0;
	}

	public function goodHit(note:Note):Void
	{
		for (sound in playerVocals) sound.volume = 1;

		++combos;

		scoreTxt.scale.x = 1.08;

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
		else if (noteDiff > NoteBase.safeHitbox * 0.28)
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

		boyfriend.animation.play(Character.singNotes[notesLength][note.ID], true);
		boyfriend.canDance = false;
		boyfriend.holdTimer = 0;

		comboGrp.noteHit(note.skin, rating, combos);
	}

	public function noteMiss(note:Note):Void
	{
		for (sound in playerVocals) sound.volume = 0;

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
		notes.cameras = [camHUD];
		add(notes);
		sustains = new FlxTypedGroup();
		sustains.cameras = [camHUD];
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
				skinFile.notes = skinFile.notes.filter(item -> NoteBase.names[notesLength].contains(item.note));
				storedSkins[curSkin] = skinFile;
			}
			else skinFile = storedSkins[curSkin];

			if (note.skin == null) note.skin = curSkin;

			final info = skinFile.notes[NoteBase.names[notesLength].indexOf(note.name)];
			final spr:Note = new Note(note, skinFile, info, this, false);
			spr.ID = NoteBase.names[notesLength].indexOf(spr.name);
			if (spr.length > 0) spr.sustain.ID = NoteBase.names[notesLength].indexOf(spr.name);
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
		strumlineManager.cameras = [camHUD];
		add(strumlineManager);

		opponentStrum = new StrumLine(curSkin, notesLength, strumFile, chartData.current.opponent, OPPONENT);
		opponentStrum.ID = 0;
		opponentStrum.y = 50;
		strumlineManager.add(opponentStrum);
		for (note in opponentStrum) strumline.add(note);

		noteSplashes = new FlxTypedGroup();
		noteSplashes.cameras = [camHUD];
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
				case 4: 
					FlxG.sound.play('assets/sounds/play/${chartData.current.strumline}/intro3.ogg', 0.6);
				case 3: 
					FlxG.sound.play('assets/sounds/play/${chartData.current.strumline}/intro2.ogg', 0.6);
				case 2: 
					FlxG.sound.play('assets/sounds/play/${chartData.current.strumline}/intro1.ogg', 0.6);
				case 1: 
					FlxG.sound.play('assets/sounds/play/${chartData.current.strumline}/introGo.ogg', 0.6);
				case 0: 
					startSong();
					conductor.onBeatUpdate.remove(count);
			}
		});
	}

	private function setupSong():Void
	{
		events = [];
		for (event in chartData.events) events.push(event);

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

	private function set_botplay(newValue:Bool):Bool 
	{
		for (note in strumline) if (note.parent.type == PLAYER) note.parent.botplay = newValue;
		return botplay = newValue;
	}
}
